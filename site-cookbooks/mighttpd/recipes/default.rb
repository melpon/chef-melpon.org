#
# Cookbook Name:: mighttpd
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
user "mighttpd" do
  action :create
  home "/home/mighttpd"
  supports :manage_home => true
  shell "/bin/bash"
end

bash "install mighttpd" do
  action :run

  code <<-SH
  su - mighttpd -c '
  cabal update
  cabal install mighttpd2
  '
  SH

  not_if "su - mighttpd -c 'test -e .cabal/bin/mighty'"
end

cookbook_file "/etc/init/mighttpd.conf" do
  action :create

  user 'root'
  group 'root'
  mode '0644'
end

bash "run mighttpd" do
  action :nothing
  user "root"
  code "start mighttpd"
end

cookbook_file "/home/mighttpd/mighttpd.server.conf" do
  user 'mighttpd'
  group 'mighttpd'
  mode '0644'

  notifies :run, "bash[run mighttpd]", :immediately
end

cookbook_file "/home/mighttpd/mighttpd.server.route" do
  action :create

  user 'mighttpd'
  group 'mighttpd'
  mode '0644'
end

