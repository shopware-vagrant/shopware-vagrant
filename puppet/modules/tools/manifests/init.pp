class tools {

	exec { 'phpMyAdmin':
		command  => '/usr/bin/git clone --single-branch --depth 1 --branch STABLE https://github.com/phpmyadmin/phpmyadmin.git /usr/share/php/phpMyAdmin &',
		unless   => '/usr/bin/test -f /usr/share/php/phpMyAdmin/index.php',
		require  => Package['php5-common'],
	}

	exec { 'opcache-dashboard':
		cwd     => '/usr/share/php',
		command => '/usr/bin/wget https://raw.githubusercontent.com/carlosbuenosvinos/opcache-dashboard/master/opcache.php -O opcache-dashboard.php',
		unless  => '/usr/bin/test -f /usr/share/php/opcache-dashboard.php',
		require => Package['php5-common'],
	}

	exec { 'OpCacheGUI':
		command  => '/usr/bin/git clone --single-branch --depth 1 --branch master https://github.com/PeeHaa/OpCacheGUI.git /usr/share/php/OpCacheGUI',
		unless   => '/usr/bin/test -f /usr/share/php/OpCacheGUI/index.php',
		require  => Package['php5-common'],
	}

	file { '/usr/share/php/OpCacheGUI/init.example.php':
		content => template('tools/opcachegui.erb'),
		require => Exec['OpCacheGUI'],
	}

	exec { 'webgrind':
		command  => '/usr/bin/git clone --single-branch --depth 1 --branch master https://github.com/jokkedk/webgrind.git /usr/share/php/webgrind &',
		unless   => '/usr/bin/test -f /usr/share/php/webgrind/index.php',
		require  => Package['php5-common'],
	}

	file { '/usr/local/bin/dot':
		ensure  => 'link',
		target  => '/usr/bin/dot',
		require => Package['graphviz'],
	}

	exec { 'roundcubemail':
		command  => '/usr/bin/git clone --single-branch --depth 1 --branch master https://github.com/roundcube/roundcubemail.git /usr/share/php/roundcubemail',
		unless   => '/usr/bin/test -f /usr/share/php/roundcubemail/index.php',
		require  => Package['php5-common'],
	}

	mysql::db { 'roundcube':
		user     => 'roundcube',
		password => 'password',
		host     => 'localhost',
		grant    => ['all'],
		charset  => 'utf8',
		require  => File['/root/.my.cnf'],
	}

	exec { 'roundcube-sql-import':
		command => '/usr/bin/mysql -u roundcube -ppassword roundcube < /usr/share/php/roundcubemail/SQL/mysql.initial.sql',
		require => [Exec['roundcubemail'], Mysql::Db['roundcube']],
		onlyif  => '/usr/bin/test ! -e /usr/share/php/roundcubemail/config/config.inc.php',
	}

	file { '/usr/share/php/roundcubemail/config/config.inc.php':
		content => template('tools/roundcubemail.config.erb'),
		require => Exec['roundcube-sql-import'],
	}

	file { ['/usr/share/php/roundcubemail/temp', '/usr/share/php/roundcubemail/logs']:
		mode    => '0777',
		require => Exec['roundcubemail'],
	}

}
