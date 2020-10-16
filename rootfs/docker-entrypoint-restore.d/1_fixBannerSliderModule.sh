#!/bin/bash

. /opt/bitnami/base/functions

gosu bitnami sed -i 's/$locations =/if (empty($slider->getLocation())) continue;\n$locations =/' ${WORKDIR}/vendor/mageplaza/module-banner-slider/Observer/AddBlock.php && \
info "MagePlaza Banner Slider fixed"
