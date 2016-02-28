class ssl {

	exec { 'cert':
		command => "openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout /etc/ssl/server.key -out /etc/ssl/server.crt -subj '/CN=${fqdn}/O=Shopware vagrant test/C=SW'",
		onlyif  => "test `openssl x509 -in /etc/ssl/server.crt -noout -subject | tail -n 1 | grep -c '/CN=${fqdn}/'` -eq 0"
	}

}
