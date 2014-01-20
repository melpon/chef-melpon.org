#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package 'nginx' do
  action :install
end

cookbook_file '/etc/nginx/nginx.conf' do
  user 'root'
  group 'root'
  mode '0644'
end

cookbook_file '/etc/nginx/conf.d/default.conf' do
  user 'root'
  group 'root'
  mode '0644'
end

service 'nginx' do
  action [:enable, :start]
end
