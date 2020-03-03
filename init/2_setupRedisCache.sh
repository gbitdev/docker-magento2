#!/usr/bin/env bash

gosu bitnami $WORKDIR/bin/magento setup:config:set -n --cache-backend=redis --cache-backend-redis-server=redis  --cache-backend-redis-password=$REDIS_PASSWORD  --cache-backend-redis-db=0 && \
gosu bitnami $WORKDIR/bin/magento setup:config:set -n --page-cache=redis    --page-cache-redis-server=redis     --page-cache-redis-password=$REDIS_PASSWORD     --page-cache-redis-db=1 && \
gosu bitnami $WORKDIR/bin/magento setup:config:set -n --session-save=redis  --session-save-redis-host=redis     --session-save-redis-password=$REDIS_PASSWORD   --session-save-redis-log-level=3 --session-save-redis-db=2 && \
echo "Redis cache enabled"