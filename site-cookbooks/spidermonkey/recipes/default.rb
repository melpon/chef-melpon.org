#
# Cookbook Name:: spidermonkey
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
def install_spidermonkey(source, file, build_dir, prefix, binname, flags)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source
    mode "0644"
    action :create_if_missing
    not_if "test -e #{prefix}/bin/#{binname}"
  end

  bash "install-spidermonkey #{build_dir}" do
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
    not_if "test -e #{prefix}/bin/#{binname}"
  end
end

install_spidermonkey(
  'http://ftp.mozilla.org/pub/mozilla.org/js/mozjs-24.2.0.tar.bz2',
  'mozjs-24.2.0.tar.bz2',
  'mozjs-24.2.0/js/src',
  '/usr/local/mozjs-24.2.0',
  'js24',
  '')
