FROM bitnami/node:12 as node

FROM bitnami/magento:latest

COPY --from=node /opt/bitnami/node /opt/bitnami/node

ARG WORKDIR=/opt/bitnami/magento/htdocs

ENV COMPOSER_MEMORY_LIMIT=-1 \
    WORKDIR=${WORKDIR} \
    PATH="${WORKDIR}/bin:/opt/bitnami/node/bin:$PATH" \
    LOCALE='pl_PL' \
    DEFAULT_CURRENCY='PLN' \
    ALLOW_CURRECIES='PLN' \
    TIMEZONE='Europe/Warsaw' \
    THEME=Alpaca

WORKDIR ${WORKDIR}

RUN install_packages unzip git nano bzip2 mlocate less && \
    npm install gulp-cli -g && \
    curl https://files.magerun.net/n98-magerun2.phar -o ${WORKDIR}/bin/magerun2 && \
    mkdir -p ${WORKDIR}/dev/app/{code,design} && \
    curl https://code.stripe.com/magento/stripe-magento2-1.7.1.tgz -o ${WORKDIR}/dev/stripe-magento2.tgz && \
    tar xf ${WORKDIR}/dev/stripe-magento2.tgz -C ${WORKDIR}/dev

COPY --chown=1000:1000 ./bin/* ${WORKDIR}/bin/

USER bitnami

COPY --chown=1000:1 composer ${WORKDIR}/var/composer_home/

RUN composer global require hirak/prestissimo && \
    composer config repositories.StripeIntegration_Payments path ./dev/app/code/StripeIntegration/Payments && \
    composer require --update-no-dev \
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
    # stripe/module-payments \
    yireo/magento2-webp2 \
    && ln -s /bitnami/magento/htdocs/frontools ${WORKDIR}/dev/tools/frontools

COPY --chown=1000:1 themes.json ${WORKDIR}/dev/tools/frontools/config/themes.json

RUN cd ${WORKDIR}/vendor/snowdog/frontools && \
    yarn && gulp setup

USER root

COPY docker-entrypoint-init.d /docker-entrypoint-init.d
COPY docker-entrypoint-restore.d /docker-entrypoint-restore.d

RUN cp /post-init.sh /post-restore.sh && \
    chmod +x /post-init.sh /post-restore.sh && \
    sed -i 's/docker-entrypoint-init.d/docker-entrypoint-restore.d/' /post-restore.sh && \
    sed -i 's/.user_scripts_initialized/.restored/' /post-restore.sh && \
    sed -i 's/Custom scripts/Custom restore scripts/' /post-restore.sh && \
    sed -i 's/Custom scripts/Custom init scripts/' /post-init.sh && \
    sed -i 's/\/post-init.sh/\/post-init.sh \n . \/post-restore.sh /' /app-entrypoint.sh && \
    find /opt/bitnami/magento/htdocs -type d -print0 | xargs -0 chmod 775 && \
    find /opt/bitnami/magento/htdocs -type f -print0 | xargs -0 chmod 664 && \
    find /opt/bitnami/magento/htdocs ! -user bitnami -print0 | xargs -0 chown -R bitnami:daemon && \
    chmod +x /opt/bitnami/magento/htdocs/bin/*
