FROM bitnami/node:12 as node

FROM bitnami/magento:2.4.0

COPY --from=node /opt/bitnami/node /opt/bitnami/node

WORKDIR /opt/bitnami/magento/htdocs

ENV COMPOSER_MEMORY_LIMIT=-1 \
    PATH="/bitnami/magento/htdocs/bin:/opt/bitnami/node/bin:$PATH" \
    WORKDIR=/bitnami/magento/htdocs \
    MAGENTO_HOST=magento.local \
    LANGUAGE="" \
    TIMEZONE="" \
    DEFAULT_CURRENCY="" \
    VARNISH_HOST="" \
    REDIS_HOST="" \
    REDIS_PORT_NUMBER="" \
    AMQP_HOST="" \
    AMQP_PORT_NUMBER="" \
    AMQP_USER="" \
    AMQP_PASSWORD="" \
    ENABLE_MODULES="" \
    DISABLE_MODULES="" \
    SAMPLE_DATA="" \
    THEME="Snowdog/alpaca" \
    magento.root=${WORKDIR}

RUN install_packages unzip git nano bzip2 mlocate less jq && \
    npm install gulp-cli -g && \
    mkdir -p /bitnami/magento/htdocs/frontools && \
    curl https://files.magerun.net/n98-magerun2.phar -o/opt/bitnami/magento/htdocs/bin/magerun2 && \
    mkdir -p ${WORKDIR}/dev/app/{code,design} 
# && \
# curl https://code.stripe.com/magento/stripe-magento2-1.7.1.tgz -o ${WORKDIR}/dev/stripe-magento2.tgz && \
# tar xf ${WORKDIR}/dev/stripe-magento2.tgz -C ${WORKDIR}/dev

USER bitnami

COPY --chown=1000:1 composer /home/bitnami/.composer

ARG ALPACA_VERSION=1.7.0

RUN ln -s /home/bitnami/.composer /opt/bitnami/magento/htdocs/var/composer_home && \
    composer global require hirak/prestissimo && \
    # composer config repositories.StripeIntegration_Payments path ./dev/app/code/StripeIntegration/Payments && \
    composer require --update-no-dev \
    cloudflare/cloudflare-magento \
    # snowdog/module-alpaca-packages \
    magepal/magento2-gmailsmtpapp \
    # magepal/magento2-googletagmanager \
    # mailchimp/mc-magento2 \
    # smile/elasticsuite \
    # snowdog/module-bullet-points \
    # snowdog/module-category-attributes \
    snowdog/module-menu \
    # snowdog/module-product-attribute-description \
    # snowdog/module-shipping-latency \
    # snowdog/module-wishlist-unlocker \
    snowdog/theme-frontend-alpaca=$ALPACA_VERSION \
    # webshopapps/module-matrixrate \
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
    mageplaza/module-gdpr \
    mageplaza/module-reports \
    mageplaza/module-sitemap  \
    mageplaza/module-smtp \
    outeredge/magento-structured-data-module \
    # stripe/module-payments \
    yireo/magento2-webp2 
    # && ln -s /bitnami/magento/htdocs/frontools /opt/bitnami/magento/htdocs/dev/tools/frontools

COPY --chown=1000:1 themes.json /opt/bitnami/magento/htdocs/dev/tools/frontools/config/themes.json

RUN cd /opt/bitnami/magento/htdocs/vendor/snowdog/frontools && \
    yarn && gulp setup

USER root

COPY rootfs /

RUN sed -i 's/print0/print0 | sort -z/' /post-init.sh && \
    cp /post-init.sh /post-restore.sh && \
    chmod +x /post-init.sh /post-restore.sh && \
    sed -i 's/docker-entrypoint-init.d/docker-entrypoint-restore.d/' /post-restore.sh && \
    sed -i 's/\/bitnami\/magento\/.user_scripts_initialized/\/.restored/' /post-restore.sh && \
    sed -i 's/Custom scripts/Custom restore scripts/' /post-restore.sh && \
    sed -i 's/Custom scripts/Custom init scripts/' /post-init.sh && \
    sed -i 's/\/post-init.sh/\/post-init.sh \n . \/post-restore.sh /' /app-entrypoint.sh && \
    find /opt/bitnami/magento/htdocs -type d -print0 | xargs -0 chmod 775 && \
    find /opt/bitnami/magento/htdocs -type f -print0 | xargs -0 chmod 664 && \
    find /opt/bitnami/magento/htdocs ! -user bitnami -print0 | xargs -0 chown -R bitnami:daemon

WORKDIR ${WORKDIR}