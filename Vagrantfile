# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty32'

  config.vm.network 'forwarded_port', guest: 80, host: 8080
  config.vm.network 'forwarded_port', guest: 8080, host: 8090
  config.vm.network 'forwarded_port', guest: 4567, host: 4567

  config.vm.provider 'virtualbox' do |vb|
    #   vb.gui = true
    vb.memory = '1024'
  end

  config.vm.provision 'shell', privileged: false, inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y git libcurl3-dev libxml2-dev libpq-dev
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
    rvm install 2.6.7
    gem install bundler
  SHELL
end
