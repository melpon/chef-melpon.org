#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'ruby_build'

ruby_build_ruby "1.9.3-p0" do
  action      :install
  prefix_path "/usr/local/ruby-1.9.3-p0"
end

ruby_build_ruby "2.0.0-p247" do
  action      :install
  prefix_path "/usr/local/ruby-2.0.0-p247"
end
