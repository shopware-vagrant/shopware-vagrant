#!/bin/bash
WEB_PATH=$1
cd ${WEB_PATH}
if [ ! -f ./www/shopware.php ]; then
  echo "Frist Step: You need a shopware instace in your www folder"
  echo "Provide your repository e.g. git@gitlab.com:company/your-shopware5.git"
  echo "Leave empty to get current 5.1 Shopware branch from github (requires local apache ant)"
  echo "Project will be cloned into www. Includes no database"
  echo "This step deletes content from www (Crtl-c to stop)"
  read -e -p "Enter url: " REPOSITORY
  if [  "$REPOSITORY" != "" ]; then
    rm -rf ./www
    git clone ${REPOSITORY} ./www
    mkdir -p ./www/html
  else
    rm -rf ./www
    git clone --single-branch --branch 5.1 git@github.com:shopware/shopware.git ./www
    cd www
    git checkout v5.1.1
    touch FIRST_RUN
    mkdir -p ./html
    cd build
    ant build-unit
    cd ../recovery/common
    ${WEB_PATH}/www/composer.phar install
    rm -f ${WEB_PATH}/www/composer.phar
  fi
fi
