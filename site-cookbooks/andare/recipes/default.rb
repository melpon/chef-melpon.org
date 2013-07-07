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

git '/home/andare/cpprefjp/site' do
  repository 'https://github.com/cpprefjp/site.git'
  action :sync
  user 'andare'
  group 'andare'
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
