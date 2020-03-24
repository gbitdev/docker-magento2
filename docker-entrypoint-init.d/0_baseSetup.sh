#!/usr/bin/env bash

gosu bitnami $WORKDIR/bin/magento config:set currency/options/allow PLN,USD && \
gosu bitnami $WORKDIR/bin/magento config:set currency/options/base PLN && \
gosu bitnami $WORKDIR/bin/magento config:set currency/options/default PLN && \
gosu bitnami $WORKDIR/bin/magento config:set currency/options/allow PLN && \
gosu bitnami $WORKDIR/bin/magento config:set general/locale/code pl_PL && \
gosu bitnami $WORKDIR/bin/magento config:set general/locale/timezone Europe/Warsaw && \
echo "Currency and locale setted"