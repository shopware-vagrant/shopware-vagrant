# Shopware Vagrant box

## What it does?
Create a Debian jessie based Virtualbox VM, installs shopware with a few helper tools.

### Requirements
- Linux, Mac
- New setup requires php-{gd,curl} for composer
- For installation Internet connection with enough broadband
- We only test with Virtualbox
- Running local nfs-server

## Quick-start
1. Checkout this Repository.
2. Take a look in Configuration.sample.yaml and change settings
    1. Change private vagrant box ip (change second last block), example 172.23.25.23
    2. Change vagrant box domain
3. ```vagrant up```
4. Select a repository or setup a new instance
5. Enter your administrator password for nfs mount or hosts update
6. Call URL project.name.dev.domain.com/ to start shopware installation (unnecessary steps removed)
8. (Optional) After setup to use grunt assign or save setting in a theme or ```vagrant reload```

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
- Hostmanager uses domain form Configuration.yaml
- VB-Guest installer
- Nginx 1.8.x with php-fpm
- MariaDB 10.1
- Postfix + Dovecot (IMAP for mail-tests)
- zsh with grml
- github sources (Webgrind, Rouncubemail, phpMyAdmin, OpCacheGUI)
- webgrind - Xdebug profiler gui http://project.name.dev.domain.com/webgrind
- phpMyAdmin
- Opcache Stats (2 different tools)
    * Opcache http://project.name.dev.domain.com/opcache-dashboard.php
    * OpCacheGUI http://project.name.dev.domain.com/OpCacheGUI
- roundcubemail http://project.name.dev.domain.com/webmail - All mails are forwarded to development@localhost
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

#### Grunt & Browsersync
Grunt output is available in a screen session named grunt. Accessible via `vagrant ssh -c 'screen -r grunt'` and can be closed via `Ctrl-A` and `Ctrl-D`
Port 3001 to get Browser GUI

### Shopware console proxy
Use Shopware console via `./utils/console` proxy and pass all arguments you want. Without an argument the help appears.

### FAQ

#### How long takes a new instance?
- Depends on a lot of factors.
  - HDD/SSD speed
  - Internet connection
  - Vagrant box cache
  - Composer caches
- Fresh ```vagrant up``` normally around 10 to 15 min

#### Why are encrypted disks not supported?
- NFS does not support encrypted host storage as mount.

#### Why do I need local php?
- Composer cache can be used (including token handling form github)

#### Why is there a copy of Configuration.sample.yaml?
- Configuration.yaml is excluded from git.

#### What should i do if a red error appears in provisioning?
- Try to run ```vagrant provision```. If it can't be resolved, report an issue.

#### Startup stops at "Mounting NFS shared folders..."
- Clear vagrant entries from ```/etc/exports```

#### Why is the database already imported?
- Git ships no complete dump. Deltas needs to de applied.

#### Is Windows supported as host?
- No! A lot stuff could go wrong including bash script, nfs.

#### How to debug vagrant and puppet?
- Enable puppetDebug in Configuration.yaml and vagrant supports argument --debug (a lot of output).

#### How do i access VM from a different device (e.g. mobile testing)?
- You need to enable network bridge in Configuration.yaml and a working DHCP server in your local network. Don't forget hosts entries.

#### Hostmanager or vgbuest has an issue
- Update your vagrant plugins ```vagrant plugin update```

#### Puppet provision fails with ```Could not set 'directory' on ensure: No such file or directory @ dir_s_mkdir```
- Nfs has a problem. Most times it is enough to stop nfs and ```vagrant reload```.


### Warning
- Puppet MySQL module is patched to use MariaDB in Debian.


## Install required software
### Archlinux
> pacman -S php php-gd vagrant virtualbox net-tools nfs-utils

Enable gd.so afterwards - required by shopware composer.

### Debian
> apt-get install virtualbox vagrant php5-cli php5-gd php5-curl

Recommended is virtualbox v5+ and required vagrant v1.8+

### Powered by
- Crafted with love by [Onedrop](https://1drop.de/)
- based on [FluidTYPO3 Vagrant](https://github.com/FluidTYPO3/FluidTYPO3-Vagrant/)

### License
The GNU General Public License can be found at http://www.gnu.org/copyleft/gpl.html<br />
Please respect separated licences in all used projects.
