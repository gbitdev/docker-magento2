#!/usr/bin/env bash

# Regenerate code
rm -rf $WORKDIR/generated/code && \
$WORKDIR/bin/magento setup:upgrade  && \
$WORKDIR/bin/magento setup:di:compile  && \
echo "Upgrade & compile complete"

gulp -f tools/gulpfile.esm.js setup && gulp -f tools/gulpfile.esm.js babel styles svg || echo "Problem with Fontools" 

magerun2 setup:static-content:deploy -t $THEME -t 'Magento/backend' -f pl_PL en_US && \
echo "Static deploy complete"