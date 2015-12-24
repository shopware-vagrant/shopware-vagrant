class apt {

	exec { 'dotdeb-key':
		command => '/usr/bin/wget -qO - http://www.dotdeb.org/dotdeb.gpg | /usr/bin/apt-key add -',
		onlyif  => '/usr/bin/test `/usr/bin/apt-key list | /bin/grep -c "4096R/89DF5277"` -eq 0',
	}

	exec { 'mariadb-key':
		command => '/usr/bin/apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db',
		onlyif  => '/usr/bin/test `/usr/bin/apt-key list | /bin/grep -c "1024D/1BB943DB"` -eq 0',
	}

	if ($apt_proxy != '') {
		file { '/etc/apt/apt.conf.d/05cacher':
			content => "Acquire::http { Proxy \"$apt_proxy\"; };",
		}
	} else {
		file { '/etc/apt/apt.conf.d/05cacher':
			ensure => absent,
		}
	}

	file { '/etc/apt/sources.list':
		content => template('apt/sources.erb'),
	}

	exec { 'apt-update':
		command => '/usr/bin/apt-get update',
		require => [File['/etc/apt/apt.conf.d/05cacher'], File['/etc/apt/sources.list'], Exec['dotdeb-key'], Exec['mariadb-key']],
	}

	exec { 'apt-upgrade':
		command => '/usr/bin/apt-get dist-upgrade -y --force-yes',
		timeout => 0,
	}

	file { '/etc/apt/sources.list.d/puppetlabs.list':
		ensure => absent,
		before => Exec['apt-update'],
	}

	Exec['apt-update'] -> Exec['apt-upgrade'] -> Package <| |>

}
