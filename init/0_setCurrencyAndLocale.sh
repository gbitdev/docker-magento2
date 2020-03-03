#!/usr/bin/env bash

$WORKDIR/bin/magento config:set currency/options/allow PLN,USD && \
$WORKDIR/bin/magento config:set currency/options/base PLN && \
$WORKDIR/bin/magento config:set currency/options/default PLN && \
$WORKDIR/bin/magento config:set currency/options/allow PLN && \
$WORKDIR/bin/magento config:set general/locale/code pl_PL && \
$WORKDIR/bin/magento config:set general/locale/timezone Europe/Warsaw && \
echo "Currency and locale setted"