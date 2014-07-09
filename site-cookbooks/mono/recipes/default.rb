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


def install_mono_2_6_7(source, file, build_dir, prefix)
  package 'libglib2.0-dev' do
    action :install
  end

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
    nice make
    make install
    EOH
    not_if "test -e #{prefix}/bin/mono"
  end

  bash "locate-compile-#{build_dir}" do
    code <<-EOH
      echo '#!/bin/sh
export MONO_SHARED_DIR=/tmp
#{prefix}/bin/gmcs "$@"' > #{prefix}/bin/gmcs-custom
      chmod +x #{prefix}/bin/gmcs-custom
    EOH
    not_if "test -e #{prefix}/bin/gmcs-custom"
  end

  bash "locate-run-#{build_dir}" do
    code <<-EOH
      echo '#!/bin/sh
export MONO_SHARED_DIR=/tmp
#{prefix}/bin/mono --aot=full "$@"
#{prefix}/bin/mono --full-aot "$@"' > #{prefix}/bin/mono-custom
      chmod +x #{prefix}/bin/mono-custom
    EOH
    not_if "test -e #{prefix}/bin/mono-custom"
  end

  bash "run-full-aot-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
      find #{prefix}/lib -name '*.dll' | grep -v I18N | while read line; do
        #{prefix}/bin/mono --aot=full $line
      done
      touch #{prefix}/bin/full-aot-completed
    EOH
    not_if "test -e #{prefix}/bin/full-aot-completed"
  end
end

install_mono_2_6_7(
  'http://download.mono-project.com/sources/mono/',
  'mono-2.6.7.tar.bz2',
  'mono-2.6.7',
  '/usr/local/mono-2.6.7')
