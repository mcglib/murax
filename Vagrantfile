# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
ram = "2048"
cpu = "2"
hostname = "xlirap.library.mcgill.ca"
ip = "132.206.197.218"
box = "mcgill/rhel7"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = box
  config.vm.box_version = "7.4.0"
  config.ssh.forward_agent = true

  hostname, *aliases = hostname
  config.vm.hostname = hostname
  www_aliases = ["www.#{hostname}"] + aliases.map { |host| "www.#{host}"  }


  # Needed for synced folders
  if not Vagrant.has_plugin? "vagrant-vbguest"
     puts "vagrant-vbguest missing, please install: vagrant plugin install vagrant-vbguest"
     exit 1
  end
  #
  if not Vagrant.has_plugin? "vagrant-hostmanager"
      puts "vagrant-hostnamanger missing, please install: vagrant plugin install vagrant-hostmanager"
      exit 1
  else
      config.hostmanager.enabled = true
      config.hostmanager.manage_host = true
      config.hostmanager.manage_guest = true
      config.hostmanager.ignore_private_ip = false
      config.hostmanager.include_offline = true
      config.hostmanager.aliases = aliases + www_aliases
  end

  config.vm.synced_folder "./", "/storage/www/murax"




  config.vm.define "lirap" do |d|
    d.vm.host_name = hostname
    d.vm.network :public_network, ip: ip, bridge: 'eth0'
    d.vm.provider "virtualbox" do |v|
      v.memory = ram
      v.cpus = cpu
      v.customize ["modifyvm", :id, "--name", hostname]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
    end

    ### For development
    #d.vm.network :forwarded_port, guest: 3000, host: 3000 # Rails
    #d.vm.network :forwarded_port, guest: 8983, host: 8983 # Solr
    #d.vm.network :forwarded_port, guest: 8984, host: 8984 # Fedora
    #d.vm.network :forwarded_port, guest: 8888, host: 8888 # Jasmine Tests

    if Vagrant.has_plugin?('vagrant-registration')
      # For full config options, see: https://github.com/strzibny/vagrant-registration
      config.registration.org = 'McGill_University'
      config.registration.name = 'intranet-vagrant.localdomain'
      config.registration.activationkey = 'vagrant-el7'
    end
    # Check our system locale -- make sure it is set to UTF-8
    # This also means we need to run 'dpkg-reconfigure' to avoid "unable to re-open stdin" errors (see http://serverfault.com/a/500778)
    # For now, we have a hardcoded locale of "en_US.UTF-8"
    locale = "en_US.UTF-8"
    #d.vm.provision :shell, :inline => "echo 'Setting locale to UTF-8 (#{locale})...' && locale | grep 'LANG=#{locale}' > /dev/null || update-locale --reset LANG=#{locale} && dpkg-reconfigure -f noninteractive locales"

    # Turn off annoying console bells/beeps in Ubuntu (only if not already turned off in /etc/inputrc)
    #d.vm.provision :shell, :inline => "echo 'Turning off console beeps...' && grep '^set bell-style none' /etc/inputrc || echo 'set bell-style none' >> /etc/inputrc"

    # Turn on SSH forwarding (so that 'vagrant ssh' has access to your local SSH keys, and you can use your local SSH keys to access GitHub, etc.)
    d.ssh.forward_agent = true

    # Prevent annoying "stdin: is not a tty" errors from displaying during 'vagrant up'
    # See also https://github.com/mitchellh/vagrant/issues/1673#issuecomment-28288042
    d.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"


   # Ansible provisioner.
   ansible_dir = "ansible"
   config.vm.provision "ansible" do |ansible|
      ansible.playbook = "#{ansible_dir}/site.yml"
      ansible.limit = 'all'
      ansible.config_file = "#{ansible_dir}/ansible.cfg"
      ansible.extra_vars = {
          deploy_local: "yes"
      }
   end
  end
end
