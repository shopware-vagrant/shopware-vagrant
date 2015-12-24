class mail {

	package { ['postfix', 'dovecot-imapd']:
		ensure => present
	}

	user { 'development':
		ensure     => present,
		shell      => '/bin/sh',
		password   => 'password',
		groups     => 'mail',
		managehome => true,
	}

	file { ['/home/development/mail']:
		ensure  => 'directory',
		owner   => 'development',
		group   => 'mail',
		require => User['development'],
	}

	file { '/etc/postfix/recipient_canonical_map':
		ensure  => present,
		content => '/./ development@localhost ',
		require => Package['postfix'],
	}

	exec { 'addPosfixConfig':
		command => '/usr/sbin/postconf -e "recipient_canonical_classes = envelope_recipient" && /usr/sbin/postconf -e "recipient_canonical_maps = regexp:/etc/postfix/recipient_canonical_map"',
		require => File['/etc/postfix/recipient_canonical_map'],
		notify  => Service['postfix'],
		onlyif  => '/usr/bin/test `grep -c "recipient_canonical_" /etc/postfix/main.cf` -lt 2'
	}

	service { 'postfix':
		ensure  => running,
		require => Package['postfix'],
	}

	file { '/etc/dovecot/users':
		ensure  => present,
		content => 'development:{PLAIN}password:1001:8::/home/development:userdb_mail=mbox:~/mail:INBOX=/var/mail/%u',
		require => Package['dovecot-imapd'],
	}

	file { '/etc/dovecot/conf.d/auth-system.conf.ext':
		content => template('mail/auth-system.conf.ext.erb'),
		require => File['/etc/dovecot/users'],
		notify  => Service['dovecot'],
	}

	service { 'dovecot':
		ensure  => running,
		require => Package['dovecot-imapd'],
	}

}
