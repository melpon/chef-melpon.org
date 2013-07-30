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
  cd wandbox/kennel/static
  ln -s ../../submodules/ace-builds/src-min ace
  cd ../
  cabal-dev install yesod-platform-1.2.3 --force-reinstalls
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

bash 'make cattleshed' do
  action :run

  code <<-SH
  su - wandbox -c '
  cd wandbox/cattleshed
  ./configure
  make
  '
  SH

  not_if "su - wandbox -c 'test -e wandbox/cattleshed/src/server.exe'"
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

cron 'kill_cattleshed_processes' do
  action :create
  minute '*'
  command "ps -u wandbox --no-headers -o '\\%p \\%x \\%a' | grep 'prog.exe' | grep -v ' 00:00:' | awk '{ print $1;}' | xargs kill -KILL"
end

