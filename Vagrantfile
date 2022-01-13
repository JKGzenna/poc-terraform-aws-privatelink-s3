# -*- mode: ruby -*-
# vi: set ft=ruby :

$install_terraform = <<SCRIPT
TERRAFORM_VERSION=0.12.3
apt-get install unzip
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
rm -f terraform*
terraform --version
SCRIPT

Vagrant.configure("2") do |config|
	# https://app.vagrantup.com/bento/boxes/ubuntu-18.04
	config.vm.box 									= "bento/ubuntu-18.04"
	config.hostmanager.enabled 			= true
	config.hostmanager.manage_host 	= true
	config.hostmanager.manage_guest = true

	config.vm.define "node1", primary: true do |node1|
		node1.vm.hostname = 'node1'
		node1.vm.network :private_network, ip: "192.168.99.101"
		node1.vm.provider :virtualbox do |v|
			v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			v.customize ["modifyvm", :id, "--memory", 3000]
			v.customize ["modifyvm", :id, "--name", "node1"]
			v.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
		end
    node1.vm.provision :shell, inline: $install_terraform
    node1.vm.provision "file", source: "~/.ssh", destination: "$HOME/.ssh"
    node1.vm.provision "shell", inline: "chmod 400 /home/vagrant/.ssh/*"
    node1.vm.provision "file", source: "~/.aws", destination: "$HOME/.aws"
    node1.vm.provision "shell", inline: "chmod 400 /home/vagrant/.aws/*"
	end
end
