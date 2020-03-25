#!/usr/bin/env bash

. /opt/bitnami/base/functions

# Regenerate code
rm -rf $WORKDIR/generated/code && \
gosu bitnami $WORKDIR/bin/magento setup:upgrade  && \
gosu bitnami $WORKDIR/bin/magento setup:di:compile  && \
info "Upgrade & compile complete"

gosu bitnami gulp -f tools/gulpfile.esm.js setup && info "Gulp stup complete"
gosu bitnami gulp -f tools/gulpfile.esm.js babel && info "Theme JS files compiled" &
gosu bitnami gulp -f tools/gulpfile.esm.js styles && info "Theme CSS files compiled" &
gosu bitnami gulp -f tools/gulpfile.esm.js svg && info "Theme SVG files compiled" &
gosu bitnami gulp -f tools/gulpfile.esm.js babel --prod && info "JS minified" 

gosu bitnami $WORKDIR/bin/magerun2 setup:static-content:deploy -t $THEME -t 'Magento/backend' -f pl_PL en_US && \
info "Static files deploy complete"