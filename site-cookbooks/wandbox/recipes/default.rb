#
# Cookbook Name:: wandbox
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'git'

user 'wandbox' do
  action :create
  home '/home/wandbox'
  supports :manage_home => true
  shell '/bin/bash'
end

git '/home/wandbox/wandbox' do
  repository 'git://github.com/melpon/wandbox.git'
  action :sync
  enable_submodules true
  user 'wandbox'
  group 'wandbox'
end



######################
# for kennel
######################

include_recipe 'haskell'

bash 'add path to wandbox' do
  action :run

  code <<-SH
    su - wandbox -c "
    echo 'export PATH=\\$HOME/.cabal/bin:\\$PATH' >> .profile
    "
  SH

  not_if "su - wandbox -c \"grep -q '.cabal/bin' '.profile'\""
end

bash 'install cabal-dev to wandbox' do
  action :run

  code <<-SH
  su - wandbox -c '
  cabal update
  cabal install cabal-dev
  '
  SH

  not_if "su - wandbox -c 'test -e .cabal/bin/cabal-dev'"
end

bash 'install kennel' do
  action :run

  code <<-SH
  su - wandbox -c '
  cd wandbox/kennel
  cabal-dev install yesod-platform-1.2.5.2 --force-reinstalls
  cabal-dev install
  '
  SH

  not_if "su - wandbox -c 'test -e wandbox/kennel/cabal-dev/bin/kennel'"
end

bash 'run kennel' do
  action :nothing
  user 'root'
  code 'start kennel'
end

cookbook_file '/etc/init/kennel.conf' do
  user 'root'
  group 'root'
  mode '0644'

  notifies :run, 'bash[run kennel]', :immediately
end


######################
# for cattleshed
######################

include_recipe 'boost'
include_recipe 'realpath'

package 'libcap-dev' do
  action :install
end

package 'libcap2-bin' do
  action :install
end

bash 'make cattleshed' do
  action :run

  code <<-SH
  su - wandbox -c '
  cd wandbox/cattleshed
  ./configure --with-boost=/usr/local/boost-1.47.0
  make
  '
  SH

  not_if "su - wandbox -c 'test -e /usr/local/cattleshed/bin/cattleshed'"
end

bash 'run cattleshed' do
  action :nothing
  user 'root'
  code 'source /etc/profile && start cattleshed LD_LIBRARY_PATH=$LD_LIBRARY_PATH'
end

cookbook_file '/etc/init/cattleshed.conf' do
  user 'root'
  group 'root'
  mode '0644'

  notifies :run, 'bash[run cattleshed]', :immediately
end


######################
# for kennel2
######################

bash 'install cppcms' do
  action :run
  cwd Chef::Config[:file_cache_path]

  code <<-SH
    set -ex

    rm -rf cppcms || true
    mkdir cppcms
    cd cppcms

    git clone https://github.com/melpon/cppcms source

    mkdir build
    cd build
    cmake ../source/ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/cppcms -DDISABLE_SHARED=ON -DDISABLE_FCGI=ON -DDISABLE_SCGI=ON -DDISABLE_ICU_LOCALE=ON -DDISABLE_TCPCACHE=ON
    make
    make install
  SH
  not_if "test -e /usr/local/cppcms"
end

bash 'install cppdb' do
  action :run
  cwd Chef::Config[:file_cache_path]

  code <<-SH
    set -ex

    rm -rf cppdb || true
    mkdir cppdb
    cd cppdb

    git clone https://github.com/melpon/cppdb source

    mkdir build
    cd build
    cmake ../source/ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/cppdb -DDISABLE_MYSQL=ON -DDISABLE_PQ=ON -DDISABLE_ODBC=ON
    make
    make install
  SH
  not_if "test -e /usr/local/cppdb"
end

bash 'install kennel2' do
  action :run

  code <<-SH
    set -ex
    su - wandbox -c '
      set -ex
      cd wandbox/kennel2
      git clean -xdqf
      autoreconf -i
      ./configure --prefix=/usr/local/kennel2 --with-cppcms=/usr/local/cppcms --with-cppdb=/usr/local/cppdb
      make
    '
    cd /home/wandbox/wandbox/kennel2
    make install
  SH

  not_if "test -e /usr/local/kennel2"
end

cookbook_file '/etc/init/kennel2.conf' do
  user 'root'
  group 'root'
  mode '0644'
end


