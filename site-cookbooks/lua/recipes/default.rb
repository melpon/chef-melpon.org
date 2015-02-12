#
# Cookbook Name:: lua
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
def install_lua(source, file, build_dir, prefix)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/lua"
  end

  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
      set -e

      tar xf #{file}
      cd #{build_dir}

      sed -e 's|^INSTALL_TOP=.*|INSTALL_TOP= #{prefix}|' Makefile > Makefile.tmp
      mv Makefile.tmp Makefile

      make linux
      make install
    EOH

    not_if "test -e #{prefix}/bin/lua"
  end
end

install_lua('http://www.lua.org/ftp/', 'lua-5.2.2.tar.gz', 'lua-5.2.2', '/usr/local/lua-5.2.2')
install_lua('http://www.lua.org/ftp/', 'lua-5.3.0.tar.gz', 'lua-5.3.0', '/usr/local/lua-5.3.0')

