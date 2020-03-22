#!/bin/bash

magerun2 module:disable \
    $MODULES_TO_DISABLE \
    $(magerun2 dev:module:list --format=csv | grep -e Adobe -e Amazon -e Temando -e Klarna -e Yotpo | awk -F ',' '{print $1}' | tr '\n' ' ') && \
echo "Modules disabled"