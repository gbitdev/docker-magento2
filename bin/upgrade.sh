#!/usr/bin/env bash

$WORKDIR/bin/magento config:set currency/options/allow PLN,USD && \
$WORKDIR/bin/magento config:set currency/options/base PLN && \
$WORKDIR/bin/magento config:set currency/options/default PLN && \
$WORKDIR/bin/magento config:set currency/options/allow PLN && \
$WORKDIR/bin/magento config:set general/locale/code pl_PL && \
$WORKDIR/bin/magento config:set general/locale/timezone Europe/Warsaw && \
echo "Currency and locale setted"

THEME_ID=$($WORKDIR/bin/magerun2 dev:theme:list --format=csv | grep "${THEME}" | cut -d, -f1); test -n "${THEME_ID}" && \
$WORKDIR/bin/magerun2 config:store:set design/theme/theme_id "${THEME_ID}" && \
$WORKDIR/bin/magerun2 cache:flush && \
echo "Custom theme setted"

$WORKDIR/bin/magerun2 magerun2 dev:symlinks 1

# Disable unwanted modules
rm -rf $WORKDIR/generated/code && \
$WORKDIR/bin/magento module:disable \
Mageplaza_BetterPopup \
Klarna_Core Klarna_Ordermanagement Klarna_Kp \
Amazon_Core Amazon_Login Amazon_Payment \
$MODULES_TO_DISABLE \
Yotpo_Yotpo Temando_Shipping && \
echo "Modules disabled"

# Regenerate code
$WORKDIR/bin/magento setup:upgrade  && \
$WORKDIR/bin/magento setup:di:compile  && \
echo "Modules disabled"

gulp -f tools/gulpfile.esm.js setup && gulp -f tools/gulpfile.esm.js babel styles svg || echo "Problem with Fontools" 