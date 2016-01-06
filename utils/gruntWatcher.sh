#!/bin/bash
function grunt_reload {
  cd /var/www/
  ./bin/console sw:theme:dump:configuration >/dev/null
  cd /var/www/themes
  killall grunt 2>/dev/null
  for configs in ../web/cache/config_*.json ; do
    shopid=`expr match "${configs}" '.*\config_\([0-9]*\)\.json'`
    nohup grunt --shopId ${shopid} >/dev/null 2>&1 &
  done
}
grunt_reload
sudo tail -n 0 -f /var/log/nginx/access.log | while read LOGLINE
do
   [[ "${LOGLINE}" == *"POST /backend/Theme/"* ]] || [[ "${LOGLINE}" == *"POST /backend/theme/"* ]] && grunt_reload
done
