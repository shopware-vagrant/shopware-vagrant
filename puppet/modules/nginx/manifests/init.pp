class nginx {

	package { [ 'apache2-mpm-prefork', 'apache2-utils', 'apache2.2-bin', 'apache2.2-common', 'libapache2-mod-php5' ]:
		ensure => purged,
	}

	exec { 'nginxDir':
		command => '/bin/mkdir -p /etc/nginx/includes',
		unless  => '/usr/bin/test -e /etc/nginx/includes/',
	}

	package { [ 'nginx', 'nginx-full', 'nginx-common']:
		ensure  => latest,
		require => Exec['nginxDir'],
	}

	file { '/etc/nginx/includes/shopware.conf':
		content => template('nginx/shopware.erb'),
		require => [Package['nginx']],
		notify  => Service['nginx'],
	}

	file { '/etc/nginx/includes/tools.conf':
		content => template('nginx/tools.erb'),
		require => [Package['nginx']],
		notify  => Service['nginx'],
	}

	file { '/etc/nginx/sites-available/default':
		content => template('nginx/nginx.erb'),
		require => Package['nginx'],
		notify  => Service['nginx'],
	}

	file { '/etc/nginx/nginx.conf':
		content => template('nginx/nginx.conf.erb'),
		require => Package['nginx'],
		notify  => Service['nginx'],
	}

	service { 'nginx':
		ensure  => running,
		require => Package['nginx'],
	}

	file { "${document_root}/index.html":
		ensure  => absent,
		require => Package['nginx'],
	}

}
