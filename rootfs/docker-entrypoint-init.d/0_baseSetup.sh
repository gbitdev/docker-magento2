#!/usr/bin/env bash

. /opt/bitnami/base/functions

chmod +x ${WORKDIR}/bin/magerun2 && \
info "ls -l ${WORKDIR}/bin/magerun2"

gosu bitnami $WORKDIR/bin/magento setup:store-config:set --use-secure-admin 1

info PHP memory limit is setted to $(php -r "echo ini_get('memory_limit').PHP_EOL;")

gosu bitnami bash -c 'cd /bitnami/magento/htdocs/vendor/snowdog/frontools && yarn && gulp setup'

# if [ -z $DEFAULT_CURRENCY ]
# then
#   warn "DEFAULT_CURRENCY variable empty"
# else
#   CURRENT_CURRENCY=$(gosu bitnami $WORKDIR/bin/magento config:set currency/options/base)
  
#   if [[ "$CURRENT_CURRENCY == $DEFAULT_CURRENCY" ]]
#     info "Default currency already OK"
#   then
#     info "Currency options are $(gosu bitnami $WORKDIR/bin/magento config:set currency/options)"
#     info "DEFAULT_CURRENCY: $DEFAULT_CURRENCY"

#     gosu bitnami $WORKDIR/bin/magento config:set currency/options/allow $DEFAULT_CURRENCY,USD && \
#     gosu bitnami $WORKDIR/bin/magento config:set currency/options/base $DEFAULT_CURRENCY && \
#     gosu bitnami $WORKDIR/bin/magento config:set currency/options/default $DEFAULT_CURRENCY && \
#     gosu bitnami $WORKDIR/bin/magento config:set currency/options/allow $ALLOW_CURRECIES && \
#     info "Currency setted"
#   fi
# fi

# LOCALE=$(gosu bitnami $WORKDIR/bin/magento config:set general/locale)

# if [ -z $LANGUAGE ]
# then
#   warn "LANGUAGE variable empty"
# else
#   gosu bitnami $WORKDIR/bin/magento config:set general/locale/code $LANGUAGE && \
#   info "Locale setted to $LANGUAGE"
# fi

# if [ -z $TIMEZONE ]
# then
#   warn "TIMEZONE variable empty"
# else
#   gosu bitnami $WORKDIR/bin/magento config:set general/locale/timezone $TIMEZONE && \
#   info "Timezone setted to $TIMEZONE"
# fi

# gosu bitnami $WORKDIR/bin/magerun2 dev:symlinks 1 && \
# info "Symlinks functionality enabled"

# gosu bitnami $WORKDIR/bin/magento config:set system/backup/functionality_enabled 1 && \
# info "DB backup functionality enabled"

# SESSION_LIFETIME=3600
# gosu bitnami $WORKDIR/bin/magento config:set admin/security/session_lifetime $SESSION_LIFETIME && \
# info "Admin session lifetime setted to $SESSION_LIFETIME"
