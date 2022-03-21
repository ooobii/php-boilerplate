eval(File.read(".env"), binding)
Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/focal64"
    config.vm.disk :disk, size:"10GB", primary: true
    config.vm.hostname = "php-boilerplate"
    config.vm.network "private_network", ip: "192.168.56.100"
    config.vm.network :forwarded_port, guest: 80, host: 8080

    config.vm.synced_folder "src", "/var/www/code"

    if Vagrant::Util::Platform.windows? then
        config.vm.provision "shell", 
            path: "build\\provision-vm.sh",
            env: {
              "USE_VAGRANT": "1"
            }
    else
        config.vm.provision "shell", 
            path: "build/provision-vm.sh",
            env: {
              "USE_VAGRANT": "1"
            }
    end

    config.vm.provider "virtualbox" do |vb|
        vb.cpus = 2
        vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
        vb.memory = "1024"
        vb.gui = false
    end

end