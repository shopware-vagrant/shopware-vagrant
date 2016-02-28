Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/local/bin/', '/usr/sbin/' ] }

class { '::mysql::server':
	root_password    => 'password',
	override_options => {
		mysqld => {
			bind-address => '0.0.0.0',
			innodb_buffer_pool_instances => '1',
			query_cache_size => '128M',
			query_cache_limit => '4M',
			join_buffer_size => '2M'
		}
	},
	restart          => true,
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
