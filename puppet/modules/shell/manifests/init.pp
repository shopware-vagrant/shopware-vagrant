class shell {

	package { 'zsh':
		ensure => present
	}

	define  setzsh {
		user { $title:
			ensure => present,
			shell  => '/usr/bin/zsh',
		}
	}

	setzsh { [ 'vagrant', 'root' ]:
		require => Package['zsh'],
	}

	exec { 'loadzshrc':
		cwd     => '/etc/zsh',
		command => '/usr/bin/wget -O /etc/zsh/zshrc http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc',
		require => Package['zsh'],
		onlyif  => '/usr/bin/test `/bin/grep -c "grml" /etc/zsh/zshrc` -eq 0'
	}

	file { '/home/vagrant/.zshrc':
		ensure  => present,
		source  => '/etc/zsh/zshrc',
		require => Package['zsh'],
	}

	file { '/home/vagrant/.zlogin':
		ensure  => present,
		content => 'cd /var/www',
		require => Package['zsh'],
	}

}
