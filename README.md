# Shopware Vagrant box

## What it does?
Create a Debian jessie based Virtualbox VM, installs Shopware with a few helper tools.

### Requirements
- Linux, Mac
- New setup requires php-curl for composer or composer pre-installed
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
6. Call URL project.name.dev.domain.com/ to start Shopware installation (unnecessary steps removed)

> **[Documentation wiki for more information](https://gitlab.com/xf-/shopware-vagrant/wikis/home)**

### Credentials
> Remote connection configured root & shopware

- http://project.name.dev.domain.com/phpMyAdmin
- User: root
- Password: password

##### Database
- User: shopware
- Password: password
- Database: shopware

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
- PHP - ioncube, composer, xdebug, phpunite, phpcs
- Shopware console proxy
- zsh with grml
- github sources (Webgrind, Rouncubemail, phpMyAdmin, OpCacheGUI)
- webgrind - Xdebug profiler gui http://project.name.dev.domain.com/webgrind
- phpMyAdmin
- Opcache Stats (2 different tools)
    * Opcache http://project.name.dev.domain.com/opcache-dashboard.php
    * OpCacheGUI http://project.name.dev.domain.com/OpCacheGUI
- Catch mails - All mails are forwarded to development@localhost


### Warning
- Puppet MySQL module is patched to use MariaDB in Debian.

### Support
- [Issues & Questions](https://gitlab.com/xf-/shopware-vagrant/)
- [Documentation wiki](https://gitlab.com/xf-/shopware-vagrant/wikis/home)
- Directly via freenode Shopware IRC - username xaver

### Powered by
- Crafted with love by [Onedrop](https://1drop.de/)
- based on [FluidTYPO3 Vagrant](https://github.com/FluidTYPO3/FluidTYPO3-Vagrant/)

### License
The GNU General Public License can be found at http://www.gnu.org/copyleft/gpl.html<br />
Please respect different licences in all used projects.
