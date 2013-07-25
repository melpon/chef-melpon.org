#
# Cookbook Name:: perl
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

def install_perl(source, file, build_dir, prefix)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/perl"
  end

  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
    tar -xf perl-5.18.0.tar.gz
    cd #{build_dir}
    ./Configure -des -Dprefix=#{prefix}
    make
    make install

    cd ../
    rm -r #{build_dir}
    EOH
    not_if "test -e #{prefix}/bin/perl"
  end
end

install_perl('http://www.cpan.org/src/5.0/', 'perl-5.18.0.tar.gz', 'perl-5.18.0', '/usr/local/perl-5.18.0')
