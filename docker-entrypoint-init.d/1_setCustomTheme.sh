#!/usr/bin/env bash

THEME_ID=$(gosu bitnami $WORKDIR/bin/magerun2 dev:theme:list --format=csv | grep "${THEME}" | cut -d, -f1); test -n "${THEME_ID}" && \
gosu bitnami $WORKDIR/bin/magerun2 config:store:set design/theme/theme_id "${THEME_ID}" && \
gosu bitnami $WORKDIR/bin/magerun2 cache:flush && \
gosu bitnami $WORKDIR/bin/magerun2 dev:symlinks 1 && \
echo "Custom theme setted"