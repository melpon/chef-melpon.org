#
# Cookbook Name:: melpon-org
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'haskell'
include_recipe 'git'

user 'melpon-org' do
  action :create
  home '/home/melpon-org'
  supports :manage_home => true
  shell '/bin/bash'
end

bash 'add path to melpon-org' do
  action :run

  code <<-SH
    su - melpon-org -c "
    echo 'export PATH=\\$HOME/.cabal/bin:\\$PATH' >> .profile
    "
  SH

  not_if "su - melpon-org -c \"grep -q '.cabal/bin' '.profile'\""
end

bash 'install cabal-dev to melpon-org' do
  action :run

  code <<-SH
  su - melpon-org -c '
  cabal update
  cabal install cabal-dev
  '
  SH

  not_if "su - melpon-org -c 'test -e .cabal/bin/cabal-dev'"
end

git '/home/melpon-org/melpon-org' do
  repository 'git://github.com/melpon/melpon.org.git'
  action :sync
  enable_submodules true
  user 'melpon-org'
  group 'melpon-org'
end

bash 'install melpon-org' do
  action :run

  code <<-SH
  su - melpon-org -c '
  cd melpon-org/site
  cabal-dev install yesod-platform-1.2.5.2
  cabal-dev install
  '
  SH

  not_if "su - melpon-org -c 'test -e melpon-org/site/cabal-dev/bin/melpon-org'"
end

bash 'run melpon-org' do
  action :nothing
  user 'root'
  code 'start melpon-org'
end

cookbook_file '/etc/init/melpon-org.conf' do
  user 'root'
  group 'root'
  mode '0644'

  notifies :run, 'bash[run melpon-org]', :immediately
end
