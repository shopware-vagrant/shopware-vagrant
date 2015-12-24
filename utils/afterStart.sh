#!/bin/sh
WEB_PATH=$1
# Load tmpfs mount AFTER nfs
sudo mount -t tmpfs none ${WEB_PATH}/var/cache
sudo mount -t tmpfs none ${WEB_PATH}/web/cache

# Return IP(s) from the VM
echo '================================='
ip addr | grep 'state UP' -A2 | grep 'inet ' | tail -n +2 | awk '{print "IP:\t"$2}'
echo "Frontend:\thttp://`hostname -f`"
echo "Backend:\thttp://`hostname -f`/backend"
echo '================================='

if [ -f ${WEB_PATH}/bin/console ]; then
  chmod +x ${WEB_PATH}/bin/console
  if ! ${WEB_PATH}/bin/console | grep -q SQLSTATE; then
    echo 'Generate grunt config ...'
    cd ${WEB_PATH}
    ./bin/console sw:generate:attributes
    ./bin/console sw:theme:dump:configuration
    echo 'Start grunt with your shop ID: cd themes; grunt --shopId 1'
  else
    echo "No database found. A database is needed to run grunt"
  fi
fi
