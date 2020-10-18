#!/bin/bash

. /opt/bitnami/base/functions

if [ -z "$MODULES_TO_INSTALL" ]
then
    gosu bitnami $WORKDIR/bin/magento module:disable \
        $MODULES_TO_DISABLE
        # $(magerun2 dev:module:list --format=csv | grep -e Magento_TwoFactorAuth -e Adobe -e Amazon -e Temando -e Klarna -e Yotpo | awk -F ',' '{print $1}' | tr '\n' ' ') && \
fi
info "Modules Disabled"

if [ -z "$MODULES_TO_INSTALL" ]
then
    warn "Nothing to install"
else
    gosu bitnami /opt/bitnami/php/bin/composer require --update-no-dev \
        $MODULES_TO_INSTALL && \
    info "Modules Installed"
fi

if [ -z "$MODULES_TO_ENABLE" ]
then
    warn "Nothing to enable"
else
    gosu bitnami $WORKDIR/bin/magento module:enable \
        $MODULES_TO_ENABLE && \
    info "Modules Enabled"
fi
