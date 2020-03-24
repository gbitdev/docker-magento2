#!/bin/bash

. /opt/bitnami/base/functions

sed -i 's/128M/-1/g' /opt/bitnami/php/conf/php.ini && \
sed -i 's/768M/-1/g' /opt/bitnami/php/conf/php.ini && \
sed -i 's/768M/-1/g' /root/.nami/components/com.bitnami.magento/main.js && \
sed -i 's/756M/-1/g' /opt/bitnami/apache/conf/vhosts/htaccess/magento-htaccess.conf && \
sed -i 's/756M/-1/g' /opt/bitnami/magento/htdocs/.user.ini && \

warn PHP memory value setted to $(php -r "echo ini_get('memory_limit').PHP_EOL;")
info "PHP uncaged :]"