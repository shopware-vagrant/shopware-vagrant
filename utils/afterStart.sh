#!/bin/bash
WEB_PATH=$1
PATCH_BROWSERSYNC=$2
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
ip addr | grep 'state UP' -A2 | grep 'inet ' | tail -n +2 | awk '{print "IP:\t\t"$2}'
echo -e "Frontend:\t\thttp://`hostname -f`"
echo -e "Backend:\t\thttp://`hostname -f`/backend"
if [ "${PATCH_BROWSERSYNC}" == "true" ]; then
  echo -e "Browsersync:\thttp://`hostname -f`:3001"
fi
echo -e '================================='

if [ -f ${WEB_PATH}/bin/console ]; then
  chmod +x ${WEB_PATH}/bin/console
  if ! ${WEB_PATH}/bin/console | grep -q SQLSTATE; then
    RUNNING_GRUNT_WATCHER=`pgrep -f '^SCREEN.*gruntWatcher.sh$' | wc -l`
    if [ ${RUNNING_GRUNT_WATCHER} -eq 0 ] ; then
      echo -e 'Grunt starts as screen in background'
      cd ${WEB_PATH}
      ./bin/console sw:generate:attributes
      screen -d -m -S grunt /vagrant/gruntWatcher.sh
      CACHEFOLDER=`ls var/cache | cat | grep production`
      mkdir -p var/cache/${CACHEFOLDER/production/development}
      cp -R var/cache/${CACHEFOLDER}/* var/cache/${CACHEFOLDER/production/development}/
    else
      echo -e "Screen gruntWatcher is already running"
    fi
  else
    echo -e "No database found. A database is needed to run grunt"
  fi
fi
