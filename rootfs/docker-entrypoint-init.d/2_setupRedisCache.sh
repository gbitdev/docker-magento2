#!/usr/bin/env bash

. /opt/bitnami/base/functions

if [ -z "$REDIS_HOST" ]
then
  warn "REDIS_HOST variable empty"
else
  gosu bitnami $WORKDIR/bin/magento setup:config:set -n --cache-backend=redis --cache-backend-redis-server=$REDIS_HOST  --cache-backend-redis-password=$REDIS_PASSWORD  --cache-backend-redis-db=0 && \
  gosu bitnami $WORKDIR/bin/magento setup:config:set -n --page-cache=redis    --page-cache-redis-server=$REDIS_HOST     --page-cache-redis-password=$REDIS_PASSWORD     --page-cache-redis-db=1 && \
  gosu bitnami $WORKDIR/bin/magento setup:config:set -n --session-save=redis  --session-save-redis-host=$REDIS_HOST     --session-save-redis-password=$REDIS_PASSWORD   --session-save-redis-log-level=3 --session-save-redis-db=2 && \
  info "Redis cache enabled 🚀"
fi

