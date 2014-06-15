#
# Cookbook Name:: erlang
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

source = 'http://www.erlang.org/download/'
build_dir = 'otp_src_17.0'
file = 'otp_src_17.0.tar.gz'
prefix = '/usr/local/erlang-17.0'

remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
  source source + file
  mode '0644'
  action :create_if_missing
  not_if "test -e #{prefix}/bin/escript"
end

bash "install-erlang-17.0" do
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
