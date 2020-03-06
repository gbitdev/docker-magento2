#!/usr/bin/env bash

# Generate Varnish config file
[ -f /bitnami/varnish/varnish.vcl ] || (gosu bitnami $WORKDIR/bin/magento varnish:vcl:generate --backend-host=magento --backend-port=80 --export-version=6 --output-file=/bitnami/varnish/varnish.vcl && echo "Varnish config generated")

# Active Varnish cache

gosu bitnami $WORKDIR/bin/magento config:set --scope=default --scope-code=0 system/full_page_cache/caching_application 2 && \
gosu bitnami $WORKDIR/bin/magento setup:config:set -n --http-cache-hosts=varnish && \
gosu bitnami rm -rf $WORKDIR/var/page_cache/* && \
echo "Varnish cache enabled"
