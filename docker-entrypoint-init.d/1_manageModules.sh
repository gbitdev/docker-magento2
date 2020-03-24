#!/bin/bash

gosu bitnami $WORKDIR/bin/magerun2 module:disable \
    $MODULES_TO_DISABLE \
    $(magerun2 dev:module:list --format=csv | grep -e Adobe -e Amazon -e Temando -e Klarna -e Yotpo | awk -F ',' '{print $1}' | tr '\n' ' ') && \
echo "Modules disabled"

gosu bitnami /opt/bitnami/php/bin/composer require --update-no-dev \
    stripe/module-payments
    $MODULES_TO_INSTALL && \
echo "Modules Installed"

if [ -z "$MODULES_TO_ENABLE" ]
then
    echo "Nothing to enable"
else
    gosu bitnami $WORKDIR/bin/magerun2 module:enable \
        $MODULES_TO_ENABLE && \
    echo "Modules Enabled"
end