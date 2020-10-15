#!/bin/bash

. /opt/bitnami/base/functions

gosu bitnami $WORKDIR/bin/magerun2 module:disable \
    $MODULES_TO_DISABLE \
    $(magerun2 dev:module:list --format=csv | grep -e Adobe -e Amazon -e Temando -e Klarna -e Yotpo | awk -F ',' '{print $1}' | tr '\n' ' ') && \
info "Modules disabled"

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
    gosu bitnami $WORKDIR/bin/magerun2 module:enable \
        $MODULES_TO_ENABLE && \
    info "Modules Enabled"
fi
