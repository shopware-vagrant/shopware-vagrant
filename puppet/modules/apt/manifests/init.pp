class apt {

	exec { 'dotdeb-key':
		command => 'wget -qO - http://www.dotdeb.org/dotdeb.gpg | apt-key add -',
		onlyif  => 'test `apt-key list | grep -c "4096R/89DF5277"` -eq 0',
	}

	exec { 'mariadb-key':
		command => 'apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db',
		onlyif  => 'test `apt-key list | grep -c "1024D/1BB943DB"` -eq 0',
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
		command => 'apt-get update',
		require => [File['/etc/apt/apt.conf.d/05cacher'], File['/etc/apt/sources.list'], Exec['dotdeb-key'], Exec['mariadb-key']],
	}

	exec { 'apt-upgrade':
		command => 'apt-get dist-upgrade -y --force-yes',
		timeout => 0,
	}

	file { '/etc/apt/sources.list.d/puppetlabs.list':
		ensure => absent,
		before => Exec['apt-update'],
	}

	Exec['apt-update'] -> Exec['apt-upgrade'] -> Package <| |>

}
