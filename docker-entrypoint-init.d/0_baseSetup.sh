#!/usr/bin/env bash

gosu bitnami $WORKDIR/bin/magento config:set currency/options/allow $DEFAULT_CURRENCY,USD && \
gosu bitnami $WORKDIR/bin/magento config:set currency/options/base $DEFAULT_CURRENCY && \
gosu bitnami $WORKDIR/bin/magento config:set currency/options/default $DEFAULT_CURRENCY && \
gosu bitnami $WORKDIR/bin/magento config:set currency/options/allow $ALLOW_CURRECIES && \
gosu bitnami $WORKDIR/bin/magento config:set general/locale/code $LOCALE && \
gosu bitnami $WORKDIR/bin/magento config:set general/locale/timezone $TIMEZONE && \
gosu bitnami $WORKDIR/bin/magento config:set system/backup/functionality_enabled 1 && \
# TODO: Add env SESSION_LIFETIME
gosu bitnami $WORKDIR/bin/magento config:set admin/security/session_lifetime 3600 && \
echo "Base settings changed"