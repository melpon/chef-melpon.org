#
# Cookbook Name:: mpidl-web
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
user 'mpidl-web' do
  action :create
  home '/home/mpidl-web'
  supports :manage_home => true
  shell '/bin/bash'
end

bash 'add path to mpidl-web' do
  action :run

  code <<-SH
    su - mpidl-web -c "
    echo 'export PATH=\\$HOME/.cabal/bin:\\$PATH' >> .profile
    "
  SH

  not_if "su - mpidl-web -c \"grep -q '.cabal/bin' '.profile'\""
end

bash 'install cabal-dev to mpidl-web' do
  action :run

  code <<-SH
  su - mpidl-web -c '
  cabal update
  cabal install cabal-dev
  '
  SH

  not_if "su - mpidl-web -c 'test -e .cabal/bin/cabal-dev'"
end

git '/home/mpidl-web/mpidl-web' do
  repository 'git://github.com/melpon/mpidl-web.git'
  action :sync
  enable_submodules true
  user 'mpidl-web'
  group 'mpidl-web'
end

bash 'install mpidl-web' do
  action :run

  code <<-SH
  su - mpidl-web -c '
  cd mpidl-web/site
  cabal-dev install yesod-platform-1.2.4.2 --force-reinstalls
  cabal-dev install
  '
  SH

  not_if "su - mpidl-web -c 'test -e mpidl-web/site/cabal-dev/bin/mpidl-web'"
end

bash 'run mpidl-web' do
  action :nothing
  user 'root'
  code 'start mpidl-web'
end

cookbook_file '/etc/init/mpidl-web.conf' do
  user 'root'
  group 'root'
  mode '0644'

  notifies :run, 'bash[run mpidl-web]', :immediately
end
