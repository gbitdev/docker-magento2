#!/usr/bin/env bash

. /opt/bitnami/base/functions

# gosu bitnami $WORKDIR/bin/magerun2 dev:theme:list

CONFIG_PATH=$WORKDIR/dev/tools/frontools/config

if [ -z $THEME ]
then
    warn "THEME variable empty"
else
    THEME_PATH=$(find app/design/frontend -iname $(echo "${THEME}" | cut -d/ -f2));
    
    if [ -z $THEME_PATH ]
    then
        warn "Can't find theme path"
    else
        gosu bitnami cp $WORKDIR/$THEME_PATH/themes.json $CONFIG_PATH/themes.json && \
        info "themes.json coppied"
    fi
    
    THEME_ID=$(gosu bitnami $WORKDIR/bin/magerun2 dev:theme:list --format=csv | grep "${THEME}" | cut -d, -f1);
    if [ -z $THEME_ID ]
    then
        warn "Can't find theme_id"
    else
        gosu bitnami $WORKDIR/bin/magerun2 config:store:set design/theme/theme_id "${THEME_ID}" && \
        gosu bitnami $WORKDIR/bin/magerun2 cache:flush && \
        gosu bitnami $WORKDIR/bin/magerun2 cache:clean && \
        info "Custom theme setted to $THEME"
    fi
fi
