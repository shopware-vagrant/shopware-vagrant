class network {

	exec { 'hostname':
		command => "hostnamectl set-hostname ${fqdn};
			echo '${fqdn}' > /etc/hostname",
		unless => "test $(hostname -f) = ${fqdn}",
	}

}
