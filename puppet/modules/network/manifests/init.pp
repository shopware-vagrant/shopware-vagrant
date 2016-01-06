class network {

	exec { 'hostname':
		command => "/usr/bin/hostnamectl set-hostname ${fqdn}",
	}

}
