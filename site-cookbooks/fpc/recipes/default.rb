#
# Cookbook Name:: fpc
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
def install_fpc(source, file, build_dir, prefix, installer)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/fpc"
  end

  bash "extract-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
    set -e
    tar -xf #{file}
    EOH
    not_if "test -e #{prefix}/bin/fpc"
  end

  cookbook_file "#{Chef::Config[:file_cache_path]}/#{build_dir}/#{installer}" do
    user 'root'
    group 'root'
    mode '0755'
    not_if "test -e #{prefix}/bin/fpc"
  end

  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
    set -e
    tar -xf #{file}
    cd #{build_dir}
    ./#{installer} #{prefix}
    EOH
    not_if "test -e #{prefix}/bin/fpc"
  end
end

install_fpc(
  'http://downloads.sourceforge.net/project/freepascal/Linux/2.6.2/',
  'fpc-2.6.2.x86_64-linux.tar',
  'fpc-2.6.2.x86_64-linux',
  '/usr/local/fpc-2.6.2',
  'install-2.6.2.sh')
