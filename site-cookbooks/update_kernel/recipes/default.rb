#
# Cookbook Name:: update_kernel
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "reboot" do
  action :nothing
end

package "linux-image-3.8.0-26-generic" do
  action :install
  notifies :run, 'execute[reboot]', :immediately
end

