#!/usr/bin/env bash

. /opt/bitnami/base/functions

# Regenerate code
rm -rf $WORKDIR/generated/code && \
gosu bitnami $WORKDIR/bin/magento setup:upgrade  && \
gosu bitnami $WORKDIR/bin/magento setup:di:compile  && \
info "Upgrade & compile complete"

gosu bitnami gulp -f tools/gulpfile.esm.js setup && gulp -f tools/gulpfile.esm.js babel styles svg && info "Theme files compiled" 
gosu bitnami gulp -f tools/gulpfile.esm.js setup && gulp -f tools/gulpfile.esm.js babel --prod && info "JS minified" 

gosu bitnami $WORKDIR/bin/magerun2 setup:static-content:deploy -t $THEME -t 'Magento/backend' -f pl_PL en_US && \
info "Static deploy complete"