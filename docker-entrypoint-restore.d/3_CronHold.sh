#!/usr/bin/env bash

. /opt/bitnami/base/functions

mv /opt/bitnami/magento/conf/cron /opt/bitnami/magento/conf/cron.bak || true

warn "Cron disabled :]"