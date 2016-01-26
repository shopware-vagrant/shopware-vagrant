VAGRANTFILE_API_VERSION = '2'
Vagrant.require_version '>= 1.8'

require 'readline'
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
required_plugins = %w(vagrant-hostmanager vagrant-vbguest)
plugin_installed = false
required_plugins.each do |plugin|
	unless Vagrant.has_plugin?(plugin)
	 buf = Readline.readline("Install required vagrant plugin #{plugin} [yes]: ", true)
	 if buf == 'yes' || buf == ''
			system "vagrant plugin install #{plugin}"
			plugin_installed = true
   else
		 fail Vagrant::Errors::VagrantError.new, "You need vagrant plugin #{plugin}"
	 end
	end
end

# If new plugins installed, restart Vagrant process
if plugin_installed === true
	exec "vagrant #{ARGV.join' '}"
end

shopwareVersion = configuration['Shopware']['version'] ||= '5.1'
patchBrowsersync = configuration['Shopware']['patchBrowsersync']

unless system("
		if [ #{ARGV[0]} = 'up' -o #{ARGV[0]} = 'reload' ]; then
			#{File.dirname(__FILE__)}/utils/beforeStart.sh #{File.dirname(__FILE__)} #{shopwareVersion} #{patchBrowsersync}
		fi
	")
	fail Vagrant::Errors::VagrantError.new, "Please take a look at README.md for more informations and try again"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	if Vagrant::Util::Platform.windows?
		fail Vagrant::Errors::VagrantError.new, "No windows support!"
	end

	config.vm.box = 'debian/jessie64'
	config.vm.hostname = configuration['VirtualMachine']['domain'] ||= 'dev.fluidtypo3.org'
	config.hostmanager.enabled = true
	config.hostmanager.manage_host = true
	config.hostmanager.ignore_private_ip = false
	config.hostmanager.include_offline = true
	if configuration['VirtualMachine']['aliases'] ||= false
		config.hostmanager.aliases = configuration['VirtualMachine']['aliases']
	end


	# Activate if your box need to be available in local network
	if configuration['VirtualMachine']['networkBridge'] ||= false
		config.vm.network 'public_network'
	end

	# Change ip: '172.23.23.23' to run more than one VM or replace it with type: 'dhcp' if you need
	config.vm.network 'private_network', ip: configuration['VirtualMachine']['ip'] ||= '172.23.42.42'

	#Disable default mount
	config.vm.synced_folder '.', '/vagrant', :disabled => true
	config.vm.synced_folder 'utils', '/vagrant', type: 'nfs'

	config.vm.synced_folder configuration['Mount']['from'] ||= 'www', '/var/www',
		id: 'shopware', type: 'nfs', mount_options: ['rw', 'vers=3', 'udp', 'noatime', 'actimeo=1']

	config.vm.provision :hostmanager, :run => 'always'

	config.vm.provider 'virtualbox' do |vb|
		vb.gui = configuration['VirtualMachine']['gui'] ||= false

		# Use VBoxManage to customize the VM. For example to change memory:
		vb.customize ['modifyvm', :id, '--memory', configuration['VirtualMachine']['memory'] ||= '2048']
		vb.customize ['modifyvm', :id, '--cpus', configuration['VirtualMachine']['cpus'] ||= '2']
		vb.customize ['modifyvm', :id, '--groups', configuration['VirtualMachine']['group'] ||= '/Vagrant/shopware']
		vb.customize ['modifyvm', :id, '--ioapic', 'on']

		vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
		vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
	end

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
				:browsersync => patchBrowsersync,
				:operatingsystem => 'Debian',
				:osfamily => 'Debian',
				:osversion => 'jessie',
				:ip_address => configuration['VirtualMachine']['ip'] ||= '172.23.42.42'
		}
	end
	config.vm.provision 'after-start', type: 'shell', path: 'utils/afterStart.sh', args: ['/var/www', "#{patchBrowsersync}"],  :privileged => false, :run => 'always'

end
