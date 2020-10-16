'use strict';

const _ = require('lodash');
const handlerSelector = require('./lib/handlers/selector');
const volumeFunctions = require('./lib/volume')($app);
const componentFunctions = require('./lib/component')($app);
const networkFunctions = require('./lib/network')($app);

const php = $modules['com.bitnami.php'];

$app.helpers.magerunCli = function (command, webServerHandler, options) {
	options = _.defaults(options || {}, { args: [''] });
	const opts = [''];
	const cli = 'magerun2';
	const args = _.flatten([command].concat(opts).concat(options.args));
	php.execute(cli, args, {
		cwd: $file.join($app.installdir, 'htdocs', 'bin'),
		uid: $os.findUser(webServerHandler.user).id,
		gid: $os.findGroup(webServerHandler.group).id,
	});
};

$app.postInstallation = function () {
	const webServerHandler = handlerSelector.getHandler('webServer', 'apache', {
		cwd: $app.installdir,
	});
	webServerHandler.setInstallingPage();
	webServerHandler.start();

	const databaseHandler = handlerSelector.getHandler(
		'database',
		{
			variation: 'mariadb',
			name: $app.databaseName,
			user: $app.databaseUser,
			password: $app.databasePassword,
			host: $app.databaseServerHost,
			port: $app.databaseServerPort,
		},
		{ cwd: $app.installdir }
	);

	if ($os.userExists($app.systemUser)) {
		const previousGroups = $os.getUserGroups($app.systemUser);
		$os.runProgram('usermod', ['-g', webServerHandler.group, $app.systemUser]);
		_.forEach(previousGroups, (value) => {
			$os.runProgram('usermod', ['-G', value, $app.systemUser]);
		});
	} else {
		$os.addUser($app.systemUser, { gid: webServerHandler.group });
	}

	if ($app.setPermissionsBeforeInstall === 'yes') {
		// In container we use chmod/chown at Docker build time. In Multi-tier
		// we need to set this at initialization time
		const ownershipOptions = {};
		ownershipOptions.owner = $os.findUser('bitnami', {
			throwIfNotFound: false,
		})
			? 'bitnami'
			: $os.getUsername($os.getUid());
		ownershipOptions.group = $os.findGroup(webServerHandler.group, {
			throwIfNotFound: false,
		})
			? webServerHandler.group
			: $os.getGroupname($os.getGid());
		componentFunctions.configurePermissions(
			$file.join($app.installdir, 'htdocs'),
			{
				mod: { directory: '775', file: '664' },
				...ownershipOptions,
			}
		);
		componentFunctions.configurePermissions(
			$file.join($app.installdir, 'htdocs/bin/magento'),
			{
				mod: { file: '775' },
				...ownershipOptions,
			}
		);
		// HACK: the function above does not change the owner.
		// As we will delete the nami logic soon I will leave it like this
		$os.runProgram('chown', [
			'-R',
			`${ownershipOptions.owner}:${ownershipOptions.group}`,
			$file.join($app.installdir, 'htdocs'),
		]);
	}

	const appDomain = networkFunctions.getURL($app.host, {
		port: $app.externalHttpPort,
		pathname: '/',
	});
	const appSSLDomain = networkFunctions.getURL($app.host, {
		protocol: 'https',
		port: $app.externalHttpsPort,
		pathname: '/',
	});

	$app.info('Preparing PHP environment...');
	php.configure({
		memory_limit: $app.phpMemoryLimit,
		max_execution_time: '300',
		always_populate_raw_post_data: '-1',
		upload_tmp_dir: php.tmpDir,
		'session.save_path': php.tmpDir,
	});
	$app.info('Preparing webserver environment...');
	webServerHandler.module('rewrite_module').activate();
	webServerHandler.addAppVhost($app.name, {
		type: 'php',
		documentRoot: $file.join($app.installdir, 'htdocs'),
	});

	if (!volumeFunctions.isInitialized($app.persistDir)) {
		$app.helpers.validateInputs();

		$app.info('Preparing Magento environment...');
		$os.runProgram(
			'find',
			`${$file.join(
				$app.installdir,
				'htdocs'
			)} -name .htaccess -print0 | xargs -0 chmod 664`
		);
		databaseHandler.checkConnection();
		$app.info('Installing Magento...');
		const installationSettings = [
			'--base-url',
			appDomain,
			'--backend-frontname',
			$app.adminUri,
			'--db-host',
			`${databaseHandler.connection.host}:${databaseHandler.connection.port}`,
			'--db-name',
			databaseHandler.connection.name,
			'--db-user',
			databaseHandler.connection.user,
			'--db-password',
			databaseHandler.connection.password,
			'--admin-firstname',
			$app.firstName,
			'--admin-lastname',
			$app.lastName,
			'--admin-email',
			$app.email,
			'--admin-user',
			$app.username,
			'--admin-password',
			$app.password,
			'--language',
			!!$app.language ? $app.language : 'en_US',
			'--currency',
			!!$app.currency ? $app.currency : 'USD',
			'--timezone',
			!!$app.timezone ? $app.timezone : 'America/Los_Angeles',
			'--use-secure',
			'1',
			'--base-url-secure',
			appSSLDomain,
			'--use-secure-admin',
			$app.useSecureAdmin === 'yes' ? '1' : '0',
			'--elasticsearch-host',
			$app.elasticsearchServerHost,
			'--elasticsearch-port',
			$app.elasticsearchServerPort,
		];
		if ($app.redisServerHost === '' || $app.redisServerPort === '') {
		} else {
			installationSettings.push(
				'--session-save',
				'redis',
				'--session-save-redis-host',
				$app.redisServerHost,
				'--session-save-redis-port',
				$app.redisServerport,
				'--cache-backend',
				'redis',
				'--cache-backend-redis-server',
				$app.redisServerHost,
				'--cache-backend-redis-port',
				$app.redisServerport,
				'--page-cache',
				'redis',
				'--page-cache-redis-server',
				$app.redisServerHost,
				'--page-cache-redis-port',
				$app.redisServerport
			);
		}
		if ($app.amqpServerHost === '') {
		} else {
			installationSettings.push(
				'--amqp-host',
				$app.amqpServerHost,
				'--amqp-port',
				$app.amqpServerPort,
				'--amqp-user',
				$app.amqpServerUser,
				'--amqp-password',
				$app.amqpServerPassword
			);
		}
		if ($app.enableModules === '') {
		} else {
			installationSettings.push('--enable-modules');
			$app.enableModules
				.split(' ')
				.forEach((m) => installationSettings.push(m));
		}
		if ($app.disableModules === '') {
		} else {
			installationSettings.push('--disable-modules');
			$app.disableModules
				.split(' ')
				.forEach((m) => installationSettings.push(m));
		}
		if ($app.useSampleData === '') {
		} else {
			installationSettings.push('--use-sample-data');
		}
		$app.helpers.magentoCli('setup:install', webServerHandler, {
			args: installationSettings,
		});
		if ($app.mode !== 'default') {
			$app.info(`Deploying to ${$app.mode} mode...`);
			if ($app.mode === 'production') {
				$app.warn('This will take a while');
			}
			$app.helpers.magentoCli('deploy:mode:set', webServerHandler, {
				args: $app.mode,
			});
		}
		$app.helpers.magentoCli('module:disable', webServerHandler, {
			args: 'Magento_TwoFactorAuth',
		});
		$app.helpers.magentoCli('cache:flush', webServerHandler);
		if (
			$app.elasticsearchServerHost === '' ||
			$app.elasticsearchServerPort === ''
		) {
			$app.warn(
				'MySQL search is deprecated, please consider using Elasticsearch instead'
			);
		} else {
			const catalogSearchSettings = [
				['catalog/search/engine', 'elasticsearch6'],
				['catalog/search/enable_eav_indexer', '1'],
				[
					'catalog/search/elasticsearch6_server_hostname',
					$app.elasticsearchServerHost,
				],
				[
					'catalog/search/elasticsearch6_server_port',
					$app.elasticsearchServerPort,
				],
				['catalog/search/elasticsearch6_index_prefix', 'magento2'],
				['catalog/search/elasticsearch6_enable_auth', '0'],
				['catalog/search/elasticsearch6_server_timeout', '15'],
			];
			// $app.info(
			// 	`Waiting for Elasticsearch at ${$app.elasticsearchServerHost}:${$app.elasticsearchServerPort}`
			// );
			// networkFunctions.waitForService(
			// 	$app.elasticsearchServerHost,
			// 	$app.elasticsearchServerPort
			// );
			$app.info('Configuring Elasticsearch...');
			catalogSearchSettings.forEach(function (setting) {
				$app.helpers.magentoCli('config:set', webServerHandler, {
					args: setting,
				});
			});
			$app.helpers.magentoCli('cache:clean', webServerHandler);
		}

		// $app.helpers.magerunCli('dev:theme:list --format=csv', webServerHandler);

		// const themeList = $app.helpers.magerunCli('dev:theme:list --format=csv', webServerHandler)

		// $app.info('themeList: ' + themeList);

		const customSettings = [
			['config:set', 'system/backup/functionality_enabled', '1'],
			['config:set', 'admin/security/session_lifetime', '3600'],
			// ['config:store:set', 'design/theme/theme_id', '1'],
		];

		$app.info('Configuring additional settings...');

		customSettings.forEach(function (setting) {
			$app.helpers.magentoCli(setting[0], webServerHandler, {
				args: [setting[1], setting[2]],
			});
		});

		if ($app.skipReindex === 'yes') {
			$app.info('Skipping reindex');
		} else {
			$app.info('Reindexing...');
			$app.helpers.magentoCli('indexer:reindex', webServerHandler);
		}
		$app.info('Flushing cache...');
		$app.helpers.magentoCli('cache:flush', webServerHandler);
		$app.info('Cleaning up cache folders after installing');
		_.each(['cache/*', 'page_cache/*', 'session/*'], (cache) => {
			$file.delete($file.join('htdocs', 'var', cache));
		});
		volumeFunctions.prepareDataToPersist($app.dataToPersist);
	} else {
		$app.info('Preparing Magento environment...');
		databaseHandler.checkConnection();
		volumeFunctions.restorePersistedData($app.dataToPersist);
	}
	componentFunctions.createExtraConfigurationFiles({
		type: 'cron',
		path: $app.cronFile,
		params: {
			runAs: $app.systemUser,
			cronJobs: [
				{
					command: `${$file.join(php.binDir, 'php')} ${$file.join(
						$app.installdir,
						'htdocs',
						'bin',
						'magento'
					)} cron:run`,
					cronTime: '* * * * *',
				},
				{
					command: `${$file.join(php.binDir, 'php')} ${$file.join(
						$app.installdir,
						'htdocs',
						'update',
						'cron.php'
					)}`,
					cronTime: '* * * * *',
				},
				{
					command:
						`${$file.join(php.binDir, 'php')} ` +
						`${$file.join(
							$app.installdir,
							'htdocs',
							'bin',
							'magento'
						)} setup:cron:run`,
					cronTime: '* * * * *',
				},
			],
		},
	});
	webServerHandler.removeInstallingPage();
	webServerHandler.stop();
	componentFunctions.configurePermissions(
		[
			{
				path: $file.join($app.installation.root, 'php/tmp'),
				mod: '775',
			},
			{
				path: $app.persistDir,
				user: $app.systemUser,
				group: webServerHandler.group,
				mod: { directory: '2775', file: '664' },
			},
			{
				path: $file.join('htdocs', 'bin', 'magento'),
				mod: '770',
			},
		],
		{ followInnerSymLinks: true }
	);
	componentFunctions.printProperties({
		Username: $app.username,
		'Site URL': appDomain,
		'Admin URL': appDomain.concat($app.adminUri),
	});
};

$app.exports = {
	configureHost: $app.helpers.configureHost,
};
