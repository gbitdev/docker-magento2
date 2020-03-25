#!/usr/bin/env bash

. /opt/bitnami/base/functions

gosu bitnami $WORKDIR/bin/magerun2 sampledata:deploy && \
info "Sample data deployed 🚀"
