FROM bitnami/node:12 as node

FROM bitnami/magento:latest

COPY --from=node /opt/bitnami/node /opt/bitnami/node

ARG WORKDIR=/opt/bitnami/magento/htdocs

ENV COMPOSER_MEMORY_LIMIT=-1 \
    WORKDIR=${WORKDIR} \
    PATH="${WORKDIR}/bin:/opt/bitnami/node/bin:$PATH" \
    THEME=

WORKDIR ${WORKDIR}

RUN install_packages unzip git nano bzip2 mlocate less && \
    npm install gulp-cli -g && \
    curl https://files.magerun.net/n98-magerun2.phar -o ${WORKDIR}/bin/magerun2

# RUN sed -i 's/128M/-1/g' /opt/bitnami/php/lib/php.ini && \
#     sed -i 's/768M/-1/g' /opt/bitnami/php/conf/php.ini && \
#     sed -i 's/768M/-1/g' /root/.nami/components/com.bitnami.magento/main.js && \
#     sed -i 's/756M/-1/g' /opt/bitnami/apache/conf/vhosts/htaccess/magento-htaccess.conf && \
#     sed -i 's/756M/-1/g' /opt/bitnami/magento/htdocs/.user.ini

# RUN php -r "echo ini_get('memory_limit').PHP_EOL;"

COPY --chown=1000:1000 ./bin/* ${WORKDIR}/bin/

USER bitnami

COPY --chown=1000:1 composer /home/bitnami/.composer

RUN composer global require hirak/prestissimo && \
    composer config repositories.Dialcom_Przelewy vcs https://gitlab.com/gbitdev-ecommerce/magento/magento2-platnosci24-extension.git && \
    composer require \
    cloudflare/cloudflare-magento \
    snowdog/theme-frontend-alpaca \
    snowdog/module-alpaca-components \
    snowdog/frontools \
    snowdog/module-menu \
    snowdog/language-pl_pl \
    magefan/module-blog \
    magefan/module-blog-comments-recaptcha \
    magefan/module-rocketjavascript \
    magefan/module-lazyload  \
    magefan/module-login-as-customer \
    mageplaza/magento-2-seo-extension \
    mageplaza/magento-2-social-login \
    mageplaza/magento-2-product-slider \
    mageplaza/module-banner-slider \
    mageplaza/module-better-popup \
    mageplaza/module-gdpr \
    mageplaza/module-reports \
    mageplaza/module-sitemap  \
    mageplaza/module-smtp \
    # outeredge/magento-structured-data-module \
    przelewy24/dialcom_przelewy && \
    ln -s /bitnami/magento/htdocs/frontools ${WORKDIR}/dev/tools/frontools

COPY --chown=1000:1 themes.json ${WORKDIR}/dev/tools/frontools/config/themes.json

RUN cd ${WORKDIR}/vendor/snowdog/frontools && \
    yarn && gulp setup

USER root

#RUN find /opt/bitnami/magento/htdocs -type d -print0 | xargs -0 chmod 775 && \
#    find /opt/bitnami/magento/htdocs -type f -print0 | xargs -0 chmod 664 && \
RUN chmod +x /opt/bitnami/magento/htdocs/bin/* && \
    chown -R bitnami:daemon /opt/bitnami/magento/htdocs
