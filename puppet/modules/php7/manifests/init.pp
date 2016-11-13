class php7 {

	package { ['php7.0-cli', 'php7.0-apcu', 'php7.0-fpm', 'php7.0-mysqlnd', 'php7.0-zip', 'php7.0-mbstring', 'php7.0-gd', 'php7.0-intl', 'php7.0-mcrypt', 'php-pear', 'php7.0-imap', 'mcrypt', 'imagemagick', 'php7.0-curl', 'php7.0-tidy', 'php7.0-xmlrpc', 'php7.0-xsl', 'php7.0-dev', 'php7.0-common', 'php7.0-xdebug']:
		ensure => present,
	}

	file { '/var/log/php7.0/':
		ensure => 'directory',
		notify => Service['php7.0-fpm'],
	}

	service { 'php7.0-fpm':
		ensure  => running,
		require => Package['php7.0-fpm'],
	}

	file { '/etc/php/7.0/fpm/pool.d/www.conf':
		ensure => absent,
		require => [Package['php7.0-fpm'], File['/etc/php/7.0/fpm/pool.d/vagrant.conf']],
		notify => Service['php7.0-fpm'],
	}

	file { '/etc/php/7.0/fpm/pool.d/vagrant.conf':
		content => template('php7/php7.0-fpm.erb'),
		require => Package['php7.0-fpm'],
	}

	define php::augeas (
		$entry,
		$ensure = present,
		$target = '/etc/php/7.0/fpm/php.ini',
		$value = '',
	) {
		$changes = $ensure ? {
			present => ["set '${entry}' '${value}'"],
			absent => ["rm '${entry}'"],
		}
		augeas { "php_ini-${name}":
			incl    => $target,
			lens    => 'Php.lns',
			changes => $changes,
			notify  => Service['php7.0-fpm'],
			require => [Package['augeas-tools'], Package['php7.0-fpm']],
		}
	}

	php::augeas {
		'php-memorylimit':
			entry => 'PHP/memory_limit',
			value => '512M';
		'php-upload_max_filesize':
			entry => 'PHP/upload_max_filesize',
			value => '256M';
		'php-post_max_size':
			entry => 'PHP/post_max_size',
			value => '256M';
		'php-expose_php':
			entry => 'PHP/expose_php',
			value => 'off';
		'php-display_errors':
			entry => 'PHP/display_errors',
			value => 'On';
		'php-max_execution_time':
			entry => 'PHP/max_execution_time',
			value => '240';
		'php-open_basedir':
			entry => 'PHP/open_basedir',
			value => "${document_root}:/usr/share/php7.0:/usr/share/php:/tmp:/var/log:/usr/bin:/dev/urandom:/usr/local/bin";
		'php-upload_tmp_dir':
			entry => 'PHP/upload_tmp_dir',
			value => '/tmp';
		'php-session_save_path':
			entry => 'Session/session.save_path',
			value => '/tmp';
		'php-date_timezone':
			entry => 'Date/date.timezone',
			value => 'Europe/Berlin';
		'php-date_timezone-cli':
			entry  => 'Date/date.timezone',
			value  => 'Europe/Berlin',
			target => '/etc/php/7.0/cli/php.ini';
		'php-cgi_fix_pathinfo':
			entry => 'PHP/cgi.fix_pathinfo',
			value => '0';
		'xdebug-xdebug_max_nesting_level':
			entry  => 'xdebug/xdebug.max_nesting_level',
			value  => '1000',
			target => '/etc/php/7.0/mods-available/xdebug.ini';
		'xdebug-xdebug_remote_enable':
			entry  => 'xdebug/xdebug.remote_enable',
			value  => 'on',
			target => '/etc/php/7.0/mods-available/xdebug.ini';
		'xdebug-xdebug_remote_connect_back':
			entry  => 'xdebug/xdebug.remote_connect_back',
			value  => 'on',
			target => '/etc/php/7.0/mods-available/xdebug.ini';
		'xdebug-xdebug_profiler_enable_trigger':
			entry  => 'xdebug/xdebug.profiler_enable_trigger',
			value  => '1',
			target => '/etc/php/7.0/mods-available/xdebug.ini';
		'xdebug-zend_extension':
			entry  => 'xdebug/zend_extension',
			value  => 'xdebug.so',
			target => '/etc/php/7.0/mods-available/xdebug.ini';
		'apcu-apc:shm_size':
			entry  => 'apcu/apc.shm_size',
			value  => '512M',
			target => '/etc/php/7.0/mods-available/apcu.ini';
		'opcache-opcache:max_accelerated_files':
			entry  => 'opcache/max_accelerated_files',
			value  => '15000',
			target => '/etc/php/7.0/mods-available/opcache.ini';
		'opcache-opcache:memory_consumption':
			entry  => 'opcache/memory_consumption',
			value  => '128',
			target => '/etc/php/7.0/mods-available/opcache.ini';
	}

	exec { 'installPhpcs':
		command => 'pear install PHP_CodeSniffer',
		unless  => 'test -f /usr/bin/phpcs',
		require => Package['php-pear'],
	}

	exec { 'installPhpUnit':
		cwd     => '/usr/local/bin',
		command => 'wget https://phar.phpunit.de/phpunit.phar -O phpunit;
			chmod +x phpunit',
		unless  => 'test -f /usr/local/bin/phpunit',
		require => Package['php7.0-cli'],
	}

	exec { 'installComposer':
		cwd     => '/usr/local/bin',
		command => 'wget https://getcomposer.org/composer.phar -O composer;
			chmod +x composer',
		unless  => 'test -f /usr/local/bin/composer',
		require => Package['php7.0-cli'],
	}

}
