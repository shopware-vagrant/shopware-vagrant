#!/bin/bash
WEB_PATH=$1
# Load tmpfs mount AFTER nfs
mounts=( "/var/cache" "/web/cache" )
for mount in "${mounts[@]}"
 do
  if ! grep -q "${WEB_PATH}${mount}" /proc/mounts ; then
    sudo mount -t tmpfs none ${WEB_PATH}${mount}
  fi
done

# Return IP(s) from the VM
echo -e '================================='
ip addr | grep 'state UP' -A2 | grep 'inet ' | tail -n +2 | awk '{print "IP:\t"$2}'
echo -e "Frontend:\thttp://`hostname -f`"
echo -e "Backend:\thttp://`hostname -f`/backend"
echo -e '================================='

if [ -f ${WEB_PATH}/bin/console ]; then
  chmod +x ${WEB_PATH}/bin/console
  if ! ${WEB_PATH}/bin/console | grep -q SQLSTATE; then
    echo -e 'Generate grunt config ...'
    cd ${WEB_PATH}
    ./bin/console sw:generate:attributes
    ./bin/console sw:theme:dump:configuration
    echo -e 'Start grunt with your shop ID: cd themes; grunt --shopId 1'
  else
    echo -e "No database found. A database is needed to run grunt"
  fi
fi
