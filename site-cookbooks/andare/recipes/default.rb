#
# Cookbook Name:: andare
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'git'

user 'andare' do
  action :create
  home '/home/andare'
  supports :manage_home => true
  shell '/bin/bash'
end

python_virtualenv '/home/andare/venv' do
  interpreter 'python2.7.3'
  owner 'andare'
  group 'andare'
  action :create
end

git '/home/andare/andare' do
  repository 'git@github.com:cpprefjp/andare.git'
  action :sync
  user 'andare'
  group 'andare'
end

git '/home/andare/cpprefjp/site' do
  repository 'git@github.com:cpprefjp/site.git'
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
