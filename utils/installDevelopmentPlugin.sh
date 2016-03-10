#!/usr/bin/env bash
rm -rf www/engine/Shopware/Plugins/Community/Backend/XfVagrantDevelopment
git clone https://github.com/shopware-vagrant/shopware-vagrant-plugin.git www/engine/Shopware/Plugins/Community/Backend/XfVagrantDevelopment
./utils/console sw:plugin:refresh
./utils/console 'sw:plugin:install --activate XfVagrantDevelopment'
