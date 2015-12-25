#
# Cookbook Name:: java-run
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
directory '/usr/local/java-run/bin/' do
  action :create
  owner 'root'
  group 'root'
  recursive true
end

cookbook_file '/usr/local/java-run/bin/run.sh' do
  user 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/usr/local/java-run/bin/run8.sh' do
  user 'root'
  group 'root'
  mode '0755'
end
