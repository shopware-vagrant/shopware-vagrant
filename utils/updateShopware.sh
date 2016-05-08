#!/usr/bin/env bash
TARGET_VERSION=$(grep -oP 'version: v[\d\.]+' Configuration.yaml | grep -oP '[\d\.]+')

if ! [ -x "$(command -v unzip)" ] ; then
  echo 'Unzip need'
fi

cd ./www/
read -e -p "Target Version: " -i "${TARGET_VERSION}" TARGET_VERSION
if [  "$TARGET_VERSION" == "" ]; then
  exit 1
fi
echo -e '[1/7] Get download link'
wget -q http://community.shopware.com/Downloads_cat_448.html -O /tmp/update.html
echo -e '[2/7] Download update package'
wget -q --show-progress --progress=bar $( grep -o "http://releases.s3.shopware.com.s3.amazonaws.com/update_${TARGET_VERSION}_.*.zip" /tmp/update.html ) -O update_${TARGET_VERSION}.zip
echo -e '[3/7] Extract update package into tmp'
unzip -qq -o update_${TARGET_VERSION}.zip
rm update_${TARGET_VERSION}.zip
echo -e '[5/7] Start update script'
vagrant ssh -c "php /var/www/recovery/update/index.php"
echo -e '[6/7] Remove update assets'
rm -rf ./update-assets
echo -e '[7/7] Patch Grunt'
patch -p1 < ../utils/provision/browersync.patch
echo -e '\033[1mFINISHED!\033[0m'
