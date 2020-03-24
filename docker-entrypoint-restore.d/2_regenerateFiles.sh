#!/usr/bin/env bash

# Regenerate code
rm -rf $WORKDIR/generated/code && \
gosu bitnami $WORKDIR/bin/magento setup:upgrade  && \
gosu bitnami $WORKDIR/bin/magento setup:di:compile  && \
echo "Upgrade & compile complete"

gosu bitnami gulp -f tools/gulpfile.esm.js setup && gulp -f tools/gulpfile.esm.js babel styles svg && echo "Theme files compiled" 
gosu bitnami gulp -f tools/gulpfile.esm.js setup && gulp -f tools/gulpfile.esm.js babel --prod && echo "JS minified" 

gosu bitnami $WORKDIR/bin/magerun2 setup:static-content:deploy -t $THEME -t 'Magento/backend' -f pl_PL en_US && \
echo "Static deploy complete"