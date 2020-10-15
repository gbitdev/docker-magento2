#!/usr/bin/env bash

. /opt/bitnami/base/functions

CRON_FILE_PATH=/opt/bitnami/magento/conf/

mv $CRON_FILE_PATH/cron $CRON_FILE_PATH/cron.bak || true
touch $CRON_FILE_PATH/cron

warn "Cron disabled :]"
