#
# Cookbook Name:: sqlite
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
def install_sqlite3(source, file, build_dir, prefix, flags)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/sqlite3"
  end

  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
      set -e

      tar xf #{file}
      cd #{build_dir}

      autoconf
      ./configure --prefix=#{prefix} #{flags}

      make
      make install
    EOH

    not_if "test -e #{prefix}/bin/sqlite3"
  end
end

install_sqlite3('http://www.sqlite.org/2013/', 'sqlite-autoconf-3080100.tar.gz', 'sqlite-autoconf-3080100', '/usr/local/sqlite-3.8.1', '')
