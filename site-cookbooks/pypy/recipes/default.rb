#
# Cookbook Name:: pypy
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
def install_pypy(source, file, build_dir, prefix)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/pypy"
  end

  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
    set -e
    tar xf #{file}
    cp -r #{build_dir} #{prefix}
    EOH
    not_if "test -e #{prefix}/bin/pypy"
  end
end

install_pypy(
  'https://bitbucket.org/pypy/pypy/downloads/',
  'pypy-2.1-linux64.tar.bz2',
  'pypy-2.1',
  '/usr/local/pypy-2.1')
