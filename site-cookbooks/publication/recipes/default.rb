#
# Cookbook Name:: publication
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'haskell'
include_recipe 'git'

user 'publication' do
  action :create
  home '/home/publication'
  supports :manage_home => true
  shell '/bin/bash'
end

bash 'add path to publication' do
  action :run

  code <<-SH
    su - publication -c "
    echo 'export PATH=\\$HOME/.cabal/bin:\\$PATH' >> .profile
    "
  SH

  not_if "su - publication -c \"grep -q '.cabal/bin' '.profile'\""
end

bash 'install cabal-dev to publication' do
  action :run

  code <<-SH
  su - publication -c '
  cabal update
  cabal install cabal-dev
  '
  SH

  not_if "su - publication -c 'test -e .cabal/bin/cabal-dev'"
end

git '/home/publication/publication' do
  repository 'git://github.com/melpon/publication.git'
  action :sync
  user 'publication'
  group 'publication'
end

bash 'install publication' do
  action :run

  code <<-SH
  su - publication -c '
  cd publication/site
  cabal-dev install yesod-platform-1.2.4.2 --force-reinstalls
  cabal-dev install
  '
  SH

  not_if "su - publication -c 'test -e publication/site/cabal-dev/bin/publication'"
end

bash 'run publication' do
  action :nothing
  user 'root'
  code 'start publication'
end

cookbook_file '/etc/init/publication.conf' do
  user 'root'
  group 'root'
  mode '0644'

  notifies :run, 'bash[run publication]', :immediately
end
