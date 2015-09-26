#
# Cookbook Name:: erlang
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

def install_erlang(source, build_dir, file, prefix)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/escript"
  end

  bash "install-erlang-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
      set -ex
      tar xf #{file}
      cd #{build_dir}

      ./otp_build autoconf
      ./configure --prefix=#{prefix}
      nice make -j3
      make install
    EOH
    not_if "test -e #{prefix}/bin/escript"
  end
end

install_erlang(
    'http://www.erlang.org/download/',
    'otp_src_17.0',
    'otp_src_17.0.tar.gz',
    '/usr/local/erlang-17.0')
install_erlang(
    'http://www.erlang.org/download/',
    'otp_src_18.1',
    'otp_src_18.1.tar.gz',
    '/usr/local/erlang-18.1')
