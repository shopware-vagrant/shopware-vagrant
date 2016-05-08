#!/usr/bin/env bash
echo -e 'This script will remove Shopware git, initial a new git with master and develop branch and push it. Includes .gitignore update. ~ 38MB upload'
read -e -p "Enter origin url: " REPOSITORY

cat << EOF > .gitignore
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
./Icon?
ehthumbs.db
Thumbs.db

!vendor/

# SASS/SCSS cache
.sass-cache/
node_modules

# PhpStorm-Project
/.idea/

# Composer
/composer.phar

# User installed plugins
/engine/Shopware/Plugins/Community/

# Userconfigurations
/config.php
/config_*.php

# Caches/Proxies
/tests/Shopware/TempFiles/*
!/tests/Shopware/TempFiles/.gitkeep
/var/cache/*
!/var/cache/.htaccess
!/var/cache/clear_cache.sh
/web/cache/*
!/web/cache/.gitkeep

# Log files
/var/log/*
!/var/log/.htaccess


# User provided content
/media/
!/media/.htaccess

/files/documents/*
!/files/documents/.htaccess
/files/downloads/*
!/files/downloads/.gitkeep

# Snippet exports
/snippetsExport/

# Needed for vagrantbox nginx package
/html/

!**/.gitkeep

themes/grunt.log
themes/Gruntfile.js.orig
EOF
rm -rf .git
git init
git add .
git commit -m '[TASK] Initial commit'
git checkout -b develop
git remote add origin ${REPOSITORY}
git push origin --all
