class shopware {

	package { ['nodejs']:
		ensure => present,
	}

	exec { 'install-grunt':
		cwd     => '/usr/bin/',
		command => 'ln -sf nodejs node;
			npm install -g grunt-cli',
		require => [Package['nodejs']],
		unless  => 'test -f /usr/local/bin/grunt',
	}

	exec { 'install-grunt-local':
		cwd     => "${document_root}/themes",
		command => "mkdir -p /home/vagrant/node_modules;
			ln -sf /home/vagrant/node_modules ${document_root}/themes/node_modules;
			npm install",
		require => [Exec['install-grunt']],
		unless  => 'test -e /home/vagrant/node_modules/grunt/',
	}

	exec { 'generate-md5':
		cwd     => "${document_root}",
		command => 'find engine/Shopware/ -type f -name "*.php" -printf "engine/Shopware/%P\n" | xargs -I {} md5sum {} > engine/Shopware/Components/Check/Data/Files.md5sums',
		unless  => "test -f engine/Shopware/Components/Check/Data/Files.md5sums",
	}

	exec { 'patch-install':
		cwd => "${document_root}",
		command => 'patch -p0 < /vagrant/provision/install.patch',
		onlyif  => 'test `grep -c "config_development.php" recovery/install/config/production.php` -eq 0',
	}

	if $browsersync {
		exec { 'patch-browsersync':
			cwd     => "${document_root}",
			command => 'patch -p0 < /vagrant/provision/browersync.patch',
			onlyif  => 'test `grep -c "browserSync" themes/Gruntfile.js` -eq 0',
			before  => Exec['install-grunt-local'],
		}
	}

	exec { 'set-version':
		cwd => "${document_root}",
		command => 'sed -i "s/___VERSION___/`git describe --abbrev=0 --tags | sed \'s/v//g\'`/g;s/___VERSION_TEXT___//g;s/___REVISION___/`php -r \'echo date("YmdHm",$argv[1]);\' $(git log -n1 --format="%at")`/g" engine/Shopware/Application.php recovery/install/data/version',
		onlyif  => 'test `grep -c "___VERSION___" engine/Shopware/Application.php` -ne 0',
		require => [Package['php7.0-cli'], Package['git']]
	}

	mysql::db { 'shopware':
		ensure   => 'present',
		user     => 'shopware',
		password => 'password',
		host     => 'localhost',
		grant    => ['all'],
		charset  => 'utf8',
	}

	mysql_user { "shopware@%":
		ensure        => present,
		password_hash => mysql_password("password"),
		require       => [Mysql::Db['shopware']],
	}

	mysql_grant { 'shopware@%/shopware.*':
		ensure     => 'present',
		options    => ['GRANT'],
		privileges => ['ALL'],
		table      => 'shopware.*',
		user       => 'shopware@%',
		require    => [Mysql::Db['shopware']],
	}

	mysql_user { "root@%":
		ensure        => present,
		password_hash => mysql_password("password"),
		require       => [Mysql::Db['shopware']],
	}

	mysql_grant { "root@%/*.*":
		user       => 'root@%',
		privileges => "all",
		table      => '*.*',
		require    => Mysql_user["root@%"],
	}

	exec { 'installDB':
		cwd     => "${document_root}",
		command => "${document_root}/bin/console sw:database:setup -q --steps=drop,create,import,setupShop;
			${document_root}/bin/console sw:generate:attributes;
			${document_root}/bin/console sw:snippets:to:db --include-plugins;
			rm ${document_root}/recovery/install/data/dbsetup.lock",
		require => [Exec['installIonCube'], Mysql_user["shopware@%"], Mysql_grant["shopware@%/shopware.*"]],
		onlyif  => 'test -e recovery/install/data/dbsetup.lock',
	}

	exec{ 'installIonCube':
		command => 'wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz;
			tar xf ioncube_loaders_lin_x86-64.tar.gz -C /usr/local/;
			rm ioncube_loaders_lin_x86-64.tar.gz',
		unless  => 'test -f /usr/local/ioncube/ioncube_loader_lin_7.0.so',
		require => [Package['php7.0-fpm'], Package['wget']]
	}

	file { '/etc/php/7.0/mods-available/ioncube.ini':
		content => "; priority=05\nzend_extension=/usr/local/ioncube/ioncube_loader_lin_7.0.so",
		ensure  => present,
		require => [Exec['installIonCube']]
	}

	file { ["${document_root}/config_development.php", "${document_root}/config.php"]:
		content => template('shopware/config.erb')
	}

	exec { 'enableIonCube':
		command => 'ln -sf /etc/php/7.0/mods-available/ioncube.ini /etc/php/7.0/fpm/conf.d/05-ioncube.ini && ln -sf /etc/php/7.0/mods-available/ioncube.ini /etc/php/7.0/cli/conf.d/05-ioncube.ini',
		require => [ File['/etc/php/7.0/mods-available/ioncube.ini']],
		notify  => Service['php7.0-fpm'],
		unless  => 'php -i | grep -q "ionCube Loader"',
	}

	file { [
		"${document_root}/web",
		"${document_root}/web/cache",
		"${document_root}/var",
		"${document_root}/var/cache",
		"${document_root}/var/log",
		"${document_root}/files",
		"${document_root}/files/documents",
		"${document_root}/files/downloads",
		"${document_root}/media",
		"${document_root}/media/archive",
		"${document_root}/media/image",
		"${document_root}/media/image/thumbnail",
		"${document_root}/media/music",
		"${document_root}/media/pdf",
		"${document_root}/media/unknown",
		"${document_root}/media/video",
		"${document_root}/media/temp",
		"${document_root}/engine",
		"${document_root}/engine/Shopware",
		"${document_root}/engine/Shopware/Plugins",
		"${document_root}/engine/Shopware/Plugins/Community",
		"${document_root}/engine/Shopware/Plugins/Community/Frontend",
		"${document_root}/engine/Shopware/Plugins/Community/Core",
		"${document_root}/engine/Shopware/Plugins/Community/Backend"
	]:
		ensure => directory,
	}

}
