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
with_cron_sh = '/home/heads/with_cron.sh'

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
    set -x
    has_error=0
    cd #{build_dir}
    for line in `ls *.sh -1`; do
      ./$line > /tmp/heads_cron_$line 2>&1
      if [ $? -ne 0 ]; then
        has_error=1
      fi
    done
    exit $has_error
  SH
end

file with_cron_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
    #{build_sh} > /tmp/heads_cron 2>&1
    if [ $? -ne 0 ]; then
        cat /tmp/heads_cron
    fi
  SH
end

# build heads every day
cron 'update_heads' do
  action :create
  minute '1'
  hour '0'
  command with_cron_sh
  mailto node['email']
end
