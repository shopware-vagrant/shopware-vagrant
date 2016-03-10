#!/bin/bash
function grunt_reload {
  cd /var/www/
  ./bin/console sw:theme:dump:configuration
  cd /var/www/themes
  killall grunt 2>/dev/null
  rm -f grunt.log
  for configs in ../web/cache/config_*.json ; do
    shopid=`expr match "${configs}" '.*\config_\([0-9]*\)\.json'`
    grunt --shopId ${shopid} >> grunt.log &
  done
}
grunt_reload
sudo tail -n 0 -f /var/log/nginx/access.log | while read LOGLINE
do
   [[ "${LOGLINE}" == *"POST /backend/Theme/"* ]] || [[ "${LOGLINE}" == *"POST /backend/theme/"* ]] || [[ "${LOGLINE}" == *"POST /backend/PluginInstaller/"* ]] || [[ "${LOGLINE}" == *"GET /recovery/install/index.php/finish/"* ]]  || [[ "${LOGLINE}" == *"GET /backend/grunt/reload/"* ]] && grunt_reload
done
