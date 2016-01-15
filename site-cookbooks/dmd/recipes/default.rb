#
# Cookbook Name:: dmd
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
def install_dmd(source, file, build_dir, prefix)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/linux/bin64/dmd"
  end

  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
      set -e

      rm -r #{build_dir} || true
      tar xf #{file}

      rm -r #{prefix} || true
      cp -r #{build_dir} #{prefix}
      rm -r #{build_dir}
    EOH

    not_if "test -e #{prefix}/linux/bin64/dmd"
  end
end

install_dmd('http://downloads.dlang.org/releases/2.x/2.069.2/', 'dmd.2.069.2.linux.tar.xz', 'dmd2', '/usr/local/dmd-2.069.2')
