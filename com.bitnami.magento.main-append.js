/**
 * TOP section
 */

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

/**
 * Install section
 */
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
	$app.enableModules.split(' ').forEach((m) => installationSettings.push(m));
}
if ($app.disableModules === '') {
} else {
	installationSettings.push('--disable-modules');
	$app.disableModules.split(' ').forEach((m) => installationSettings.push(m));
}
if ($app.useSampleData === 'yes') {
} else {
	installationSettings.push('--use-sample-data', 1);
}
/**
 * Configure section
 */
$app.helpers.magerunCli('dev:theme:list', webServerHandler, {
	args: ['--format=csv'],
});

const themeList = $app.helpers.magerunCli('dev:theme:list', webServerHandler, {
	args: ['--format=csv'],
});

$app.info('themeList: ' + themeList);

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
