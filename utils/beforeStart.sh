#!/bin/bash
WEB_PATH=$1
SHOPWARE_VERSION=$2
cd ${WEB_PATH}
if [ ! -f ./www/shopware.php ]; then
  echo -e "You need a shopware instace in your www folder"
  echo -e "Provide your repository e.g. git@gitlab.com:company/your-shopware5.git \e[1mOR\e[0m"
  echo -e "leave it empty to get defined Shopware version (Configuration.yaml) from github (requires php)."
  echo -e "Project will be cloned into www."
  echo -e "This step deletes content from www. (Crtl-c to stop)"
  read -e -p "Enter url: " REPOSITORY
  if [  "$REPOSITORY" != "" ]; then
    rm -rf ./www
    git clone ${REPOSITORY} ./www
    mkdir -p ./www/html
  else
    if ! [ -x "$(command -v php)" ]; then
      echo -e "\e[0;37m\e[41mYou need to install shopware composer and php with gd and curl\e[0m"
      exit 1
    fi
    if ! php -i | grep -q 'GD Support' || ! php -i | grep -q 'cURL support' ; then
      echo -e "\e[0;37m\e[41mPhp extensions gd and curl missing or not enabled\e[0m"
      exit 1
    fi
    rm -rf ./www
    git clone --single-branch --branch ${SHOPWARE_VERSION} --depth 1 https://github.com/shopware/shopware.git ./www
    cd www
    COMPOSER=composer
    if ! [ -x "$(command -v composer)" ] ; then
      php -r "readfile('https://getcomposer.org/installer');" | php
      COMPOSER=${WEB_PATH}/www/composer.phar
    fi
    mkdir -p ./html
    ${COMPOSER} install --no-interaction --optimize-autoloader
    cd ./recovery/common
    ${COMPOSER} install --no-interaction --optimize-autoloader
    VERSION=`git describe --abbrev=0 --tags`
    REVISION=`date +"%Y%d%m%H%M"`
    sed -i "s/___VERSION___/${VERSION//v}/g;s/___VERSION_TEXT___//g;s/___REVISION___/${REVISION}/g" ${WEB_PATH}/www/engine/Shopware/Application.php ${WEB_PATH}/www/recovery/install/data/version
    touch ${WEB_PATH}/www/recovery/install/data/dbsetup.lock
    rm -f ${WEB_PATH}/www/composer.phar
  fi
fi
