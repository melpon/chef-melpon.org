#
# Cookbook Name:: ghc
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package 'haskell-platform' do
  action :install
end

# link libgmp.so.3
bash "/usr/lib/libgmp.so.3" do
  user 'root'

  code <<-EOH
  set -e
  ln -s /usr/lib/libgmp.so.10 /usr/lib/libgmp.so.3
  EOH
  not_if "test -e /usr/lib/libgmp.so.3"
end

def install_ghc(source, file, build_dir, prefix)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/ghc"
  end

  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
    set -e
    tar -xf #{file}
    cd #{build_dir}
    ./configure --prefix=#{prefix}
    make install
    EOH
    not_if "test -e #{prefix}/bin/ghc"
  end
end

def install_haskell_platform(source, file, build_dir, prefix, ghc, ghc_pkg)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/cabal"
  end

  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
    set -e
    tar -xf #{file}
    cd #{build_dir}
    ./configure --prefix=#{prefix} --with-ghc=#{ghc} --with-ghc-pkg=#{ghc_pkg}
    make install
    EOH
    not_if "test -e #{prefix}/bin/cabal"
  end
end

install_ghc(
  'http://www.haskell.org/ghc/dist/7.6.3/',
  'ghc-7.6.3-x86_64-unknown-linux.tar.bz2',
  'ghc-7.6.3',
  '/usr/local/ghc-7.6.3')

install_haskell_platform(
  'http://lambda.haskell.org/platform/download/2013.2.0.0/',
  'haskell-platform-2013.2.0.0.tar.gz',
  'haskell-platform-2013.2.0.0',
  '/usr/local/ghc-7.6.3',
  '/usr/local/ghc-7.6.3/bin/ghc',
  '/usr/local/ghc-7.6.3/bin/ghc-pkg')

install_ghc(
  'http://www.haskell.org/ghc/dist/7.8.3/',
  'ghc-7.8.3-x86_64-unknown-linux-deb7.tar.bz2',
  'ghc-7.8.3',
  '/usr/local/ghc-7.8.3')
