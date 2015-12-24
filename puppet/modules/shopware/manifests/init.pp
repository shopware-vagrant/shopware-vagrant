class shopware {

	package { ['npm']:
		ensure => present,
	}

	exec { 'install-grunt':
		command => '/bin/ln -sf /usr/bin/nodejs /usr/bin/node && /usr/bin/npm install -g grunt-cli',
		require => [Package['npm']],
	}

	exec { 'install-grunt-local':
		cwd => '/var/www/themes',
		command => '/usr/bin/npm install',
		require => [Exec['install-grunt']]
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
		cwd     => '/var/www/',
		command => '/usr/bin/mysql -u shopware -ppassword shopware < _sql/install/latest.sql && ./build/ApplyDeltas.php --username="shopware" --password="password" --host="localhost" --dbname="shopware" --mode=install && ./bin/console sw:snippets:to:db && rm -f /var/www/FIRST_RUN',
		require => [Exec['installIonCube'], Mysql_user["shopware@%"], Mysql_grant["shopware@%/shopware.*"]],
		onlyif  => '/usr/bin/test -e /var/www/FIRST_RUN ',
	}

	exec{ 'installIonCube':
		command => '/usr/bin/wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && /bin/tar xf ioncube_loaders_lin_x86-64.tar.gz -C /usr/local/ && rm ioncube_loaders_lin_x86-64.tar.gz',
		unless  => '/usr/bin/test -f /usr/local/ioncube/ioncube_loader_lin_5.6.so',
		require => [Package['php5-fpm'], Package['wget']],
		notify  => Service['php5-fpm'],
	}

	file { '/etc/php5/mods-available/ioncube.ini':
		content => "; priority=05\nzend_extension=/usr/local/ioncube/ioncube_loader_lin_5.6.so",
		ensure  => present,
		require => Exec['installPhpXdebug'],
	}

	file { "${document_root}/config.php":
		content => template('shopware/config.erb')
	}

	exec { 'enableIonCube':
		command => '/usr/sbin/php5enmod ioncube',
		require => [ File['/etc/php5/mods-available/ioncube.ini']],
		notify  => Service['php5-fpm'],
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
