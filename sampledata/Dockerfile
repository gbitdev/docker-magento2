FROM registry.gitlab.com/gbitdev/magento2:2.3.3-simple

ENV MAGENTO_MODE='production' \
    MODULES_TO_DISABLE='magefan/module-rocketjavascript \
                        magefan/module-lazyload  \
                        mageplaza/magento-2-product-slider \
                        mageplaza/module-banner-slider \
                        mageplaza/module-better-popup \
                        mageplaza/module-reports \
                        mageplaza/module-sitemap  \
                        mageplaza/module-smtp'

COPY sampledata/1_removeStep2.sh /docker-entrypoint-init.d/

USER bitnami

RUN bin/magento sampledata:deploy
# RUN composer require --update-no-dev \
#     magento/module-bundle-sample-data \
#     magento/module-widget-sample-data \
#     magento/module-theme-sample-data \
#     magento/module-catalog-sample-data \
#     magento/module-customer-sample-data \
#     magento/module-cms-sample-data  \
#     magento/module-catalog-rule-sample-data \
#     magento/module-sales-rule-sample-data \
#     magento/module-review-sample-data \
#     magento/module-tax-sample-data \
#     magento/module-sales-sample-data \
#     magento/module-grouped-product-sample-data \
#     magento/module-downloadable-sample-data \
#     magento/module-msrp-sample-data \
#     magento/module-configurable-sample-data \
#     magento/module-product-links-sample-data \
#     magento/module-wishlist-sample-data \
#     magento/module-swatches-sample-data \
#     magento/module-offline-shipping-sample-data
#     magento/sample-data-media

USER root
