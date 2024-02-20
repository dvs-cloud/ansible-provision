Vagrant.configure("2") do |config|

  config.vm.define "ubuntu-focal",primary: true do |instance|
    instance.vm.network :private_network, type: "dhcp", docker_network__internal: true
    instance.vm.network "forwarded_port", id: "ssh", host: 2222, guest: 22
    instance.vm.provider "docker" do |d, override|
      d.image = "dvscloud/vagrant:ubuntu-focal"
      d.remains_running = true
      d.has_ssh = true
      d.privileged = true
    end
    instance.vm.provision "ansible" do |ansible|
      # ansible.galaxy_role_file = 'requirements.yml'
      ansible.playbook = "./playbook-new.yml"
    #   ansible.vault_password_file = "~/.ansible/.vault-pass"
      # ansible.skip_tags = "workaround,debug"
      ansible.tags = "base"
      ansible.verbose = "v"
      ansible.extra_vars = {
        ansible_python_interpreter: "/usr/bin/python3",
        local_install: true
      }
    end
  end

end