#
# Cookbook Name:: heads
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
build_sh = '/home/heads/build.sh'
build_dir = '/home/heads/build'

user 'heads' do
  action :create
  home '/home/heads'
  supports :manage_home => true
  shell '/bin/bash'
end

directory build_dir do
  user 'root'
  group 'root'
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
    set -ex
    cd #{build_dir}
    ls *.sh -1 | while read line; do
      ./$line
    done
  SH
end

# build heads every day
cron 'update_heads' do
  action :create
  minute '1'
  hour '0'
  command build_sh
  mailto node['email']
end
