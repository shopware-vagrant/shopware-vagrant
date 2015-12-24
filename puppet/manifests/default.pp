class { '::mysql::server':
	root_password    => 'password',
	override_options => {
		mysqld => { bind-address => '0.0.0.0' }
	},
	restart          => true,
}

$override_options = {
	'mysqld' => {
		'bind-address' => '',
	}
}

include apt
include defaultpackage
include network
include shell
include ssl
include nginx
include php5
include mail
include tools
include shopware
