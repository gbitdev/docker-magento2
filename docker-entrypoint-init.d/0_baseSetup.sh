#!/usr/bin/env bash

. /opt/bitnami/base/functions

sed -i 's/128M/-1/g' /opt/bitnami/php/conf/php.ini && \
sed -i 's/768M/-1/g' /opt/bitnami/php/conf/php.ini && \
sed -i 's/768M/-1/g' /root/.nami/components/com.bitnami.magento/main.js && \
sed -i 's/756M/-1/g' /opt/bitnami/apache/conf/vhosts/htaccess/magento-htaccess.conf && \
sed -i 's/756M/-1/g' /opt/bitnami/magento/htdocs/.user.ini && \
info PHP memory limit setted to $(php -r "echo ini_get('memory_limit').PHP_EOL;")

gosu bitnami $WORKDIR/bin/magento config:set currency/options/allow $DEFAULT_CURRENCY,USD && \
gosu bitnami $WORKDIR/bin/magento config:set currency/options/base $DEFAULT_CURRENCY && \
gosu bitnami $WORKDIR/bin/magento config:set currency/options/default $DEFAULT_CURRENCY && \
gosu bitnami $WORKDIR/bin/magento config:set currency/options/allow $ALLOW_CURRECIES && \
info "Currencies setted"

gosu bitnami $WORKDIR/bin/magento config:set general/locale/code $LOCALE && \
info "Locale setted to $LOCALE"

gosu bitnami $WORKDIR/bin/magento config:set general/locale/timezone $TIMEZONE && \
info "Timezone setted to $TIMEZONE"

gosu bitnami $WORKDIR/bin/magerun2 dev:symlinks 1 && \
info "Symlinks functionality enabled"

gosu bitnami $WORKDIR/bin/magento config:set system/backup/functionality_enabled 1 && \
info "DB backup functionality enabled"

SESSION_LIFETIME=3600
gosu bitnami $WORKDIR/bin/magento config:set admin/security/session_lifetime $SESSION_LIFETIME && \
info "Admin session lifetime setted to $SESSION_LIFETIME"