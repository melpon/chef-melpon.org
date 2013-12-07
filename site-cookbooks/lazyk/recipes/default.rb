#
# Cookbook Name:: lazyk
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

def install_lazyk(prefix)
  cookbook_file "#{Chef::Config[:file_cache_path]}/lazy.cpp" do
    user 'root'
    group 'root'
    mode '0644'
    not_if "test -e #{prefix}/bin/lazyk"
  end

  bash "install-lazyk" do
    user 'root'
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
      set -ex
      mkdir -p #{prefix}/bin
      g++ lazy.cpp -o #{prefix}/bin/lazyk
    EOH
    not_if "test -e #{prefix}/bin/lazyk"
  end
end

install_lazyk('/usr/local/lazyk')
