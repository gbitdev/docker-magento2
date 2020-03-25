#!/usr/bin/env bash

. /opt/bitnami/base/functions

gosu bitnami $WORKDIR/bin/magerun2 dev:theme:list

THEME_ID=$(gosu bitnami $WORKDIR/bin/magerun2 dev:theme:list --format=csv | grep "${THEME}" | cut -d, -f1); test -n "${THEME_ID}" && \
gosu bitnami $WORKDIR/bin/magerun2 config:store:set design/theme/theme_id "${THEME_ID}"
gosu bitnami $WORKDIR/bin/magerun2 cache:flush && \
gosu bitnami $WORKDIR/bin/magerun2 cache:clean 
if [ -z $THEME_ID ]
then
    warn "THEME variable not setted"
else
    info "Custom theme setted to $THEME"
fi
