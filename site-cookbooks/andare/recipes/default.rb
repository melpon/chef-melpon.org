#
# Cookbook Name:: andare
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'git'
include_recipe 'python'

user 'andare' do
  action :create
  home '/home/andare'
  supports :manage_home => true
  shell '/bin/bash'
end

ssh_known_hosts 'github.com' do
  hashed true
  user 'andare'
end

python_virtualenv '/home/andare/venv' do
  interpreter 'python2.7'
  owner 'andare'
  group 'andare'
  action :create
end

git '/home/andare/andare' do
  repository 'https://github.com/cpprefjp/andare.git'
  action :sync
  user 'andare'
  group 'andare'
end

directory '/home/andare/cpprefjp' do
  action :create
  owner 'andare'
  group 'andare'
end

bash 'git clone cpprefjp/site' do
  action :run
  code <<-SH
  set -e
  sudo su - andare -c '
  cd cpprefjp
  git clone https://github.com/cpprefjp/site.git
  cd site
  git branch fetched
  git reset --hard #{node['andare']['revision']}
  '
  SH
  not_if 'test -d /home/andare/cpprefjp/site/.git'
end

%w{
  django
  markdown
  pygments
  pygithub3
  requests
}.each do |pkg|
  python_pip pkg do
    virtualenv '/home/andare/venv'
  end
end

bash 'run andare' do
  action :nothing
  user 'root'
  code 'start andare'
end

cookbook_file '/etc/init/andare.conf' do
  user 'root'
  group 'root'
  mode '0644'

  notifies :run, 'bash[run andare]', :immediately
end
