VAGRANTFILE_API_VERSION = '2'
Vagrant.require_version '>= 1.8'

require 'yaml'

configuration = YAML.load(File.open(File.join(File.dirname(__FILE__), 'Configuration.sample.yaml'), File::RDONLY).read)
if File.file?File.join(File.dirname(__FILE__),'Configuration.yaml')
else
	require 'fileutils'
	FileUtils.cp(File.join(File.dirname(__FILE__),'Configuration.sample.yaml'),File.join(File.dirname(__FILE__),'Configuration.yaml'))
	puts('Configuration.yaml was missing. The Configuration.sample.yaml got copied')
end

begin
	configuration.merge!(YAML.load(File.open(File.join(File.dirname(__FILE__), 'Configuration.yaml'), File::RDONLY).read))
end

# Check for missing plugins
required_plugins = %w(vagrant-hostsupdater vagrant-vbguest)
plugin_installed = false
required_plugins.each do |plugin|
	unless Vagrant.has_plugin?(plugin)
		system "vagrant plugin install #{plugin}"
		plugin_installed = true
	end
end

# If new plugins installed, restart Vagrant process
if plugin_installed === true
	exec "vagrant #{ARGV.join' '}"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = 'debian/jessie64'

	config.vm.hostname = configuration['VirtualMachine']['domain'] ||= 'dev.fluidtypo3.org'
	config.hostsupdater.remove_on_suspend = true


	# Activate if your box need to be available in local network
	if configuration['VirtualMachine']['networkBridge'] ||= false
		config.vm.network 'public_network'
	end

	# Change ip: '172.23.23.23' to run more than one VM or replace it with type: 'dhcp' if you need
	config.vm.network 'private_network', ip: configuration['VirtualMachine']['ip'] ||= '172.23.23.23'

	#Disable default mount
	config.vm.synced_folder '.', '/vagrant', :disabled => true
	config.vm.synced_folder 'utils', '/vagrant'

	config.vm.synced_folder configuration['Mount']['from'] ||= 'www', '/var/www',
		id: 'shopware', type: 'nfs', mount_options: ['rw', 'vers=3', 'udp', 'noatime', 'actimeo=1']


	config.vm.provider 'virtualbox' do |vb|
		vb.gui = configuration['VirtualMachine']['gui'] ||= false

		# Use VBoxManage to customize the VM. For example to change memory:
		vb.customize ['modifyvm', :id, '--memory', configuration['VirtualMachine']['memory'] ||= '2048']
		vb.customize ['modifyvm', :id, '--cpus', configuration['VirtualMachine']['cpus'] ||= '2']
		vb.customize ['modifyvm', :id, '--ioapic', 'on']
	end

	system("
		if [ #{ARGV[0]} = 'up' -o #{ARGV[0]} = 'reload' ]; then
			#{File.dirname(__FILE__)}/utils/beforeStart.sh #{File.dirname(__FILE__)}
		fi
	")

	config.vm.provision 'fix-no-tty', type: 'shell' do |s|
		s.privileged = false
		s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

	config.vm.provision 'install-puppet', type: 'shell', inline: 'apt-get install --yes puppet &> /dev/null'

	config.vm.provision :puppet do |puppet|
		puppet.synced_folder_type = 'nfs'
		puppet.manifests_path = 'puppet/manifests'
		puppet.module_path    = 'puppet/modules'
		if configuration['VirtualMachine']['puppetDebug'] ||= false
			puppet.options = '--debug --verbose --hiera_config /vagrant/hiera.yaml'
		else
			puppet.options = '--hiera_config /vagrant/hiera.yaml'
		end
		puppet.facter = {
				:apt_proxy => configuration['VirtualMachine']['aptProxy'] ||= '',
				:document_root => '/var/www',
				:fqdn => configuration['VirtualMachine']['domain'] ||= 'project.dev.domain.com',
				:operatingsystem => 'Debian',
				:osfamily => 'Debian',
				:osversion => 'jessie',
				:ip_address => configuration['VirtualMachine']['ip'] ||= '172.42.42.42'
		}
	end
	config.vm.provision 'shell', path: 'utils/afterStart.sh', args: '/var/www',  :privileged => false, :run => 'always'
end
