#!/usr/bin/env bash
BASE=$PWD
cd ${BASE}/data/mariadb/data && sudo rm -rf * && umask 002
cd ${BASE}/data/magento
rm -rf ./.*
rm -rf ./htdocs/{app,code,pub,var}