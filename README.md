# Shopware Vagrant box

## What it does?
Create a Debian jessie based Virtualbox VM, installs shopware with a few helper tools.

### Requirements
- Linux, Mac
- New setup requires Apache Ant (php for composer)
- For installation Internet connection with enough broadband
- We only test with Virtualbox
- Running local nfs-server

## Quick-start
1. Checkout this Repository.
2. Take a look in Configuration.sample.yaml and change settings
    1. Change private vagrant box ip (change second last block), example 172.23.25.23
    2. Change vagrant box domain
3. ```vagrant up```
4. Select a repository or setup a new instance (apache ant locally required)
6. Enter your administrator password for nfs mount or hosts update
7. Call URL project.name.dev.domain.com/ to start shopware installation
8. (Optional) After setup to use grunt ```vagrant provision``` or ```vagrant reload```

### Credentials
##### MySQL (remote connection configured root & shopware)
- http://project.name.dev.domain.com/phpMyAdmin
- User: root
- Password: password

##### Database
- User: shopware
- Password: password

##### Mail
- http://project.name.dev.domain.com/webmail
- User: development
- Password: password

##### Vagrant shell
- User: vagrant
- Password: vagrant
- sudo su for root

### Features
- Hostupdater uses domain form Configuration.yaml
- VB-Guest installer
- Nginx 1.8.x with php-fpm
- MariaDB 10.1
- Postfix + Dovecot (IMAP for mail-tests)
- zsh with grml
- github sources (Webgrind, Rouncubemail, phpMyAdmin, OpCacheGUI)
- webgrind - Xdebug profiler gui http://project.name.dev.domain.com/webgrind
- phpMyAdmin
+ Opcache Stats (2 different tools)
    * Opcache http://project.name.dev.domain.com/opcache-dashboard.php
    * OpCacheGUI http://project.name.dev.domain.com/OpCacheGUI
+ roundcubemail http://project.name.dev.domain.com/webmail - All mails are send to development@localhost
    * Login via development Password password
- PHPunit for testing
- ioncube
- Composer


### Xdebug
Use a Firefox or Chrome extension to active debug or profiler

- [Firefox Addon - The easiest Xdebug](https://addons.mozilla.org/de/firefox/addon/the-easiest-xdebug)
- [Chrome Addon - Xdebug helper](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc)

#### phpStorm/IDEA remote listener
Activate in PhpStorm/IDEA ```Start Listening for PHP Debug Connections``` and turn the debug option in browser addon on. Define a breakpoint and reload the page.

#### Webgrind profiler
Activate the profiler function of the addon. Instead of a browser-extension ?XDEBUG_PROFILE as GET parameter is also possible.

### FAQ

#### Do we support Windows as host?
- No

#### How long takes a new instance?
- Depends on a lot of factors.
  - HDD/SSD speed
  - Internet connection
  - Base Debian jessie box already cached
  - Composer caches
```vagrant up``` 10 to 15 min

#### Why are encrypted disks not supported?
- NFS does not support encrypted host storage as mount.

#### Why do i need local Apache ant?
- Composer cache can be used (including token handling form github) and we need no Java with Apache Ant in every VM

#### Why is there a copy of Configuration.sample.yaml?
- Configuration.yaml is excluded from git.

#### What should i do if a red error appears in provisioning?
- Try to run ```vagrant provision```. If it can't be resolved, report an issue.

#### Startup stops at "Mounting NFS shared folders..."
- Clear vagrant entries from ```/etc/exports```

### Warning
- Puppet MySQL module is patched to use MariaDB in Debian


## Install required software
### Archlinux
```pacman -S apache-ant php vagrant virtualbox```

### Powered by
- developed from [Onedrop Solutions](https://1drop.de/)
- based on [FluidTYPO3 Vagrant](https://github.com/FluidTYPO3/FluidTYPO3-Vagrant/)

### License
The GNU General Public License can be found at http://www.gnu.org/copyleft/gpl.html<br />
Please respect separated licences in all used projects.
