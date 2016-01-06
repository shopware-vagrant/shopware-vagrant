#!/bin/bash
WEB_PATH=$1
cd ${WEB_PATH}
if [ ! -f ./www/shopware.php ]; then
  echo -e "You need a shopware instace in your www folder"
  echo -e "Provide your repository e.g. git@gitlab.com:company/your-shopware5.git \e[1mOR\e[0m"
  echo -e "leave it empty to get current 5.1.x Shopware from github (requires local apache ant)."
  echo -e "Project will be cloned into www."
  echo -e "This step deletes content from www. (Crtl-c to stop)"
  read -e -p "Enter url: " REPOSITORY
  if [  "$REPOSITORY" != "" ]; then
    rm -rf ./www
    git clone ${REPOSITORY} ./www
    mkdir -p ./www/html
  else
    if ! [ -x "$(command -v ant)" ] || ! [ -x "$(command -v php)" ]; then
      echo -e "\e[0;37m\e[41mYou need to install shopware ant and php with gd and curl\e[0m"
      exit 1
    fi
    if ! php -i | grep -q 'GD Support' || ! php -i | grep -q 'cURL support' ; then
      echo -e "\e[0;37m\e[41mPhp extensions gd and curl missing or not enabled\e[0m"
      exit 1
    fi
    rm -rf ./www
    git clone --single-branch --branch v5.1.1 --depth 1 https://github.com/shopware/shopware.git ./www
    cd www
    touch FIRST_RUN
    mkdir -p ./html
    cd build
    ant build-cache-dir build-composer-install build-config
    cd ../recovery/common
    ${WEB_PATH}/www/composer.phar install
    rm -f ${WEB_PATH}/www/composer.phar
  fi
fi
