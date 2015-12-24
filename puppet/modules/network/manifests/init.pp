class network {

	host { $fqdn:
		ensure => present,
		ip     => '127.0.0.1',
	}

}
