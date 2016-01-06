class network {

	exec { 'hostname':
		command => "/usr/bin/hostnamectl set-hostname ${fqdn}",
		unless => "/usr/bin/test $(hostname -f) = ${fqdn}",
	}

}
