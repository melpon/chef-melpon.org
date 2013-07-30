#
# Cookbook Name:: mono
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

def install_mono(source, file, build_dir, prefix)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/mono"
  end

  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
    set -e
    tar -xf #{file}
    cd #{build_dir}
    ./configure --prefix=#{prefix} --disable-nls
    make
    make install
    EOH
    not_if "test -e #{prefix}/bin/mono"
  end
end

install_mono(
  'http://download.mono-project.com/sources/mono/',
  'mono-3.2.0.tar.bz2',
  'mono-3.2.0',
  '/usr/local/mono-3.2.0')
