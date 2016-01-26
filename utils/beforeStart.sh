#!/bin/bash
WEB_PATH=$1
SHOPWARE_VERSION=$2
PATCH_BROWSERSYNC=$3
cd ${WEB_PATH}
if [ ! -f ./www/shopware.php ]; then
  echo -e "You need a shopware instace in your www folder"
  echo -e "Provide your repository e.g. git@gitlab.com:company/your-shopware5.git \033[1mOR\033[0m"
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
      echo -e "\033[0;37m\033[41mYou need to install shopware composer and php with gd and curl\033[0m"
      exit 1
    fi
    if ! php -i | grep -q 'GD Support' || ! php -i | grep -q 'cURL support' ; then
      echo -e "\033[0;37m\033[41mPhp extensions gd and curl missing or not enabled\033[0m"
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
    if ! ${COMPOSER} config --global github-oauth.github.com >/dev/null 2>&1 ; then
      echo -e "Token is needed to avoid 50 request per hour limit. (Limit with token by 1000)"
      echo -e "Token can be generated on GitHub: https://github.com/settings/tokens/new?scopes=repo&description=Composer+on+`hostname`"
      read -e -s -p "Github token (hidden): " TOKEN
      ${COMPOSER} config --global github-oauth.github.com ${TOKEN}
    fi
    mkdir -p ./html
    ${COMPOSER} install --no-interaction --optimize-autoloader
    cd ./recovery/common
    ${COMPOSER} install --no-interaction --optimize-autoloader
    cd ${WEB_PATH}/www
    patch -p1 < ../utils/install.patch
    if [ "${PATCH_BROWSERSYNC}" == "true" ]; then
      patch -p1 < ../utils/browersync.patch
    fi
    VERSION=`git describe --abbrev=0 --tags`
    REVISION=`php -r 'echo date("YmdHm",$argv[1]);' $(git log -n1 --format="%at")`
    sed -i.bak "s/___VERSION___/${VERSION//v}/g;s/___VERSION_TEXT___//g;s/___REVISION___/${REVISION}/g" ${WEB_PATH}/www/engine/Shopware/Application.php ${WEB_PATH}/www/recovery/install/data/version
    touch recovery/install/data/dbsetup.lock
    rm -f composer.phar ${WEB_PATH}/www/engine/Shopware/Application.php.bak ${WEB_PATH}/www/recovery/install/data/version.bak
  fi
fi
