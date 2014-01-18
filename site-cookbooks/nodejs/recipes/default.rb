#
# Cookbook Name:: nodejs
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

def install_nodejs(source, file, build_dir, prefix, flags)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source
    mode "0644"
    action :create_if_missing
    not_if "test -e #{prefix}/bin/node"
  end

  bash "install-nodejs #{build_dir}" do
    user "root"
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
      set -e
      tar -xf #{file}
      cd #{build_dir}
      ./configure --prefix=#{prefix} #{flags}
      make
      make install
    EOH
    not_if "test -e #{prefix}/bin/node"
  end
end

install_nodejs(
  'http://nodejs.org/dist/v0.10.24/node-v0.10.24.tar.gz',
  'node-v0.10.24.tar.gz',
  'node-v0.10.24',
  '/usr/local/node-0.10.24',
  '')
