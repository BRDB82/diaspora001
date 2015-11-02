Vagrant.configure(2) do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", 1024]
  end

  config.vm.box = "lazyfrosch/debian-8-jessie-amd64-puppet"
  config.vm.hostname = "diaspora"
  config.vm.network :forwarded_port, guest: 80, host: 8080

  config.vm.provision :shell, path: "provision.sh"
end
