#
# Cookbook Name:: yesodbookjp
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'haskell'
include_recipe 'git'

user 'yesodbookjp' do
  action :create
  home '/home/yesodbookjp'
  supports :manage_home => true
  shell '/bin/bash'
end

bash 'add path to yesodbookjp' do
  action :run

  code <<-SH
    su - yesodbookjp -c "
    echo 'export PATH=\\$HOME/.cabal/bin:\\$PATH' >> .profile
    "
  SH

  not_if "su - yesodbookjp -c \"grep -q '.cabal/bin' '.profile'\""
end

bash 'install cabal-dev to yesodbookjp' do
  action :run

  code <<-SH
  su - yesodbookjp -c '
  cabal update
  cabal install cabal-dev
  '
  SH

  not_if "su - yesodbookjp -c 'test -e .cabal/bin/cabal-dev'"
end

git '/home/yesodbookjp/yesodbookjp' do
  repository 'git://github.com/melpon/yesodbookjp.git'
  action :sync
  user 'yesodbookjp'
  group 'yesodbookjp'
end

bash 'install yesodbookjp' do
  action :run

  code <<-SH
  su - yesodbookjp -c '
  cd yesodbookjp
  cabal-dev install yesod-platform-1.0.0 --force-reinstalls
  cabal-dev install
  '
  SH

  not_if "su - yesodbookjp -c 'test -e yesodbookjp/cabal-dev/bin/yesodbookjp'"
end

bash 'run yesodbookjp' do
  action :nothing
  user 'root'
  code 'start yesodbookjp'
end

cookbook_file '/etc/init/yesodbookjp.conf' do
  user 'root'
  group 'root'
  mode '0644'

  notifies :run, 'bash[run yesodbookjp]', :immediately
end
