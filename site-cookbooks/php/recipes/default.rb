#
# Cookbook Name:: php
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

def install_php(source, file, build_dir, prefix, flags)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source
    mode "0644"
    action :create_if_missing
    not_if "test -e #{prefix}/bin/php"
  end

  bash "install-php #{build_dir}" do
    user "root"
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
    set -e
    tar xf #{file}
    cd #{build_dir}
    ./configure --prefix=#{prefix} #{flags} > /dev/null
    make
    make install
    EOH
    not_if "test -e #{prefix}/bin/php"
  end
end

install_php(
  'http://us2.php.net/get/php-5.5.6.tar.gz/from/jp1.php.net/mirror',
  'php-5.5.6.tar.gz',
  'php-5.5.6',
  '/usr/local/php-5.5.6',
  '')
