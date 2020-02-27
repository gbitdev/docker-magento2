#!/bin/bash -e
echo "bitnami:testpass" | chpasswd
install_packages openssh-server
sed -i 's/#Port 22/Port 2002/g' /etc/ssh/sshd_config
service ssh start
exec /app-entrypoint.sh "$@"
