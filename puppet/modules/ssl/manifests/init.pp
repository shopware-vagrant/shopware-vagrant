class ssl {

	exec { 'cert':
		command => "/usr/bin/openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout /etc/ssl/server.key -out /etc/ssl/server.crt -subj '/CN=${fqdn}/O=Shopware vagrant test/C=SW'",
		onlyif  => "/usr/bin/test `/usr/bin/openssl x509 -in /etc/ssl/server.crt -noout -subject | /usr/bin/tail -n 1 | /bin/grep -c '/CN=${fqdn}/'` -eq 0"
	}

}
