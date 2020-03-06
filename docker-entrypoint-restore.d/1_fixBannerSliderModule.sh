#!/bin/bash

sed -i 's/$locations =/if (empty($slider->getLocation())) continue;\n$locations =/' vendor/mageplaza/module-banner-slider/Observer/AddBlock.php && \
echo "MagePlaza Banner Slider fixed"