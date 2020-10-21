#!/usr/bin/env bash

. /opt/bitnami/base/functions

if [ -d "$WORKDIR/app/code/Amasty/Mage24Fix" ]
then
  warn "Dir $WORKDIR/app/code/Amasty/Mage24Fix already exists"
else
  gosu bitnami mkdir -p $WORKDIR/app/code/Amasty
  gosu bitnami curl https://amasty.com/blog/wp-content/uploads/2020/07/module-mage24fix-master.zip -o $WORKDIR/app/code/Amasty/mage24fix.zip && \
  gosu bitnami unzip $WORKDIR/app/code/Amasty/mage24fix.zip -d $WORKDIR/app/code/Amasty/ && \
  gosu bitnami mv $WORKDIR/app/code/Amasty/module-mage24fix-master $WORKDIR/app/code/Amasty/Mage24Fix && \
  info "Mage24Fix installed"
fi