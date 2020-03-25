#!/bin/bash

gosu bitnami sed -i 's/$locations =/if (empty($slider->getLocation())) continue;\n$locations =/' vendor/mageplaza/module-banner-slider/Observer/AddBlock.php && \
info "MagePlaza Banner Slider fixed"