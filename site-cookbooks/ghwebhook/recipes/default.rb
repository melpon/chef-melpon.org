#
# Cookbook Name:: ghwebhook
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
user 'ghwebhook' do
  action :create
  home '/home/ghwebhook'
  supports :manage_home => true
  shell '/bin/bash'
end

sudo 'ghwebhook' do
  user      'ghwebhook'
  runas     'ALL'
  nopasswd  true
end

git '/home/ghwebhook/ghwebhook' do
  repository 'git://github.com/melpon/ghwebhook.git'
  action :sync
  user 'ghwebhook'
  group 'ghwebhook'
end

bash 'run ghwebhook' do
  action :nothing
  user 'root'
  code 'start ghwebhook'
end

cookbook_file '/etc/init/ghwebhook.conf' do
  user 'root'
  group 'root'
  mode '0644'

  notifies :run, 'bash[run ghwebhook]', :immediately
end
