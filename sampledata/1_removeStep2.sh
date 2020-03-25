#!/usr/bin/env bash

. /opt/bitnami/base/functions

echo "" > /docker-entrypoint-init.d/2_setupRedisCache.sh && \
echo "" > /docker-entrypoint-init.d/2_setupVarnishCache.sh && \
info "Redis and Varnish configuration holded ❌"