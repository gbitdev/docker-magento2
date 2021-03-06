#!/bin/bash

. /opt/bitnami/base/functions

# if [ -z "$MODULES_TO_INSTALL" ]
# then
#     warn "Nothing to install"
# else
#     gosu bitnami /opt/bitnami/php/bin/composer require --no-update \
#         $MODULES_TO_INSTALL && \
#     info "Modules Installed"
# fi

# if [ -z "$MODULES_TO_REMOVE" ]
# then
#     warn "Nothing to remove"
# else
#     gosu bitnami /opt/bitnami/php/bin/composer remove --no-update \
#         $MODULES_TO_REMOVE && \
#     info "Modules Removed"
# fi

DISABLE_LIST='Magento_TwoFactorAuth Adobe Amazon Temando Klarna Yotpo'
FILTER_LIST=''

DISABLE_LIST+=" $MODULES_TO_DISABLE"

for FILTER in $DISABLE_LIST
do
    FILTER_LIST+=" -e $FILTER"
done

gosu bitnami $WORKDIR/bin/magento module:disable \
    $(magerun2 dev:module:list --format=csv | grep -e $FILTER_LIST | awk -F ',' '{print $1}' | tr '\n' ' ') && \
info "Modules Disabled"

if [ -z $MODULES_TO_ENABLE ]
then
    warn "Nothing to enable"
else
    gosu bitnami $WORKDIR/bin/magento module:enable \
        $MODULES_TO_ENABLE && \
    info "Modules Enabled"
fi

# if [![ -z "$MODULES_TO_INSTALL" ] || ![ -z "$MODULES_TO_REMOVE" ]]
# then
#     gosu bitnami /opt/bitnami/php/bin/composer update --update-no-dev
# fi

if [![ -z $MODULES_TO_ENABLE ] || ![ -z $MODULES_TO_DISABLE ]]
then
    gosu bitnami $WORKDIR/bin/magento setup:upgrade && \
    gosu bitnami $WORKDIR/bin/magento setup:di:compile && \
    gosu bitnami $WORKDIR/bin/magento setup:static-content:deploy
fi

