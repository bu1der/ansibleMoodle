# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "centos/7"
RAM = "512"
AM_RAM = "1024"
DB_NETWORK = "192.168.56.20"
NETWORK = "192.168.56."
LB_NETWORK = "192.168.56.10"
AM_NETWORK = "192.168.56.5"
NODE_COUNT = 2

Vagrant.configure("2") do |config|

    config.vm.define "dataBaseMoodle" do |dataBaseMoodle|
      dataBaseMoodle.vm.box = BOX_IMAGE
      dataBaseMoodle.vm.hostname = "dataBaseMoodle"
      dataBaseMoodle.vm.provision "shell", path: "scenarioDatabase.sh"
      dataBaseMoodle.vm.provider "virtualbox" do |vb|
        vb.memory = RAM
      end
      dataBaseMoodle.vm.network :private_network, ip: DB_NETWORK
    end

    (1..NODE_COUNT).each do |i|
      config.vm.define "webServer#{i}" do |webServer|
        webServer.vm.box = BOX_IMAGE
        webServer.vm.hostname = "webServer#{i}"
        webServer.vm.provider "virtualbox" do |vb|
          vb.memory = RAM
        end
        webServer.vm.network :private_network, ip: "#{NETWORK}"+"#{i + 10}"
        if i==1
          webServer.vm.provision "shell", path: "scenarioWebserverOne.sh"
        else
          webServer.vm.provision "shell", path: "scenarioWebserverNext.sh"
        end
      end
    end

    config.vm.define "loadBalancer" do |loadBalancer|
      loadBalancer.vm.box = BOX_IMAGE
      loadBalancer.vm.hostname = "loadBalancer"
      loadBalancer.vm.provider "virtualbox" do |vb|
        vb.memory = RAM
      end
      loadBalancer.vm.network :private_network, ip: LB_NETWORK
    end

    config.vm.define "ansibleMaster" do |ansibleMaster|
      ansibleMaster.vm.box = BOX_IMAGE
      ansibleMaster.vm.hostname = "ansibleMaster"
      ansibleMaster.vm.network :private_network, ip: AM_NETWORK
      ansibleMaster.vm.provider "virtualbox" do |vb|
        vb.memory = AM_RAM
      end
      ansibleMaster.vm.provision "file", source: ".vagrant/machines/loadBalancer/virtualbox/private_key", destination: "~/.ssh/#{LB_NETWORK}.pem"
      ansibleMaster.vm.provision "shell", path: "ansibleMaster.sh"
    end
end