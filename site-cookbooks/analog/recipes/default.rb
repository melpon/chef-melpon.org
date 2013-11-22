#
# Cookbook Name:: analog
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package 'analog'

link '/var/cache/analog/images' do
  to '/usr/share/analog/images'
end

cookbook_file '/etc/analog.cfg' do
  user 'root'
  group 'root'
  mode '0644'
end

# update report every hour
cron 'update_report' do
  action :create
  minute '0'
  command 'analog'
end
