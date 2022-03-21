# read key/value pairs from .env file.
env_file = {}
File.open('.env', 'r') do |file|
  file.each_line do |line|

    # skip comments
    next if line.start_with?('#')

    # skip empty lines
    next if line.chomp.empty?

    # split key/value pairs
    line_data = line.split('=')

    #if value starts & ends with a " then remove the quotes
    if line_data[1].to_s[0] == '"' && line_data[1].to_s[-2] == '"' then
      line_data[1] = line_data[1].to_s.chomp[1..-2]

    #if value starts & ends with a ' then remove the quotes
    elsif line_data[1].to_s[0] == "'" && line_data[1].to_s[-2] == "'" then
      line_data[1] = line_data[1].to_s.chomp[1..-2]

    end

    # add key/value pair to environment variables
    env_file[line_data[0]] = line_data[1].to_s.chomp
  end
end

# Vagrant Machine Configuration
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/focal64"
    config.vm.disk :disk, size: env_file['MACHINE_DISKSIZE'], primary: true
    config.vm.hostname = env_file['SITE_URL']
    config.vm.network "private_network", ip: env_file['MACHINE_IP']
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
        vb.cpus = env_file['MACHINE_CPUS']
        vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
        vb.memory = env_file['MACHINE_MEMORY']
        vb.gui = false
    end

end