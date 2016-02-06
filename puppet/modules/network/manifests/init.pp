class network {

	exec { 'hostname':
		command => "/usr/bin/hostnamectl set-hostname ${fqdn}; /bin/echo '${fqdn}' > /etc/hostname",
		unless => "/usr/bin/test $(hostname -f) = ${fqdn}",
	}

}
