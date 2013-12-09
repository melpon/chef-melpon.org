#
# Cookbook Name:: clisp
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

def install_libsigsegv(source, file, build_dir, prefix)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/lib/libsigsegv.a"
  end

  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
    set -e
    tar -xf #{file}
    cd #{build_dir}
    CC='gcc -m32' ./configure --prefix=#{prefix}
    make
    make check
    make install
    EOH
    not_if "test -e #{prefix}/lib/libsigsegv.a"
  end
end

def install_clisp(source, file, build_dir, prefix)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/clisp"
  end

  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
    set -e
    tar -xf #{file}
    cd #{build_dir}
    cd src
    wget  http://sourceforge.net/p/clisp/bugs/_discuss/thread/9285dfcc/22a6/attachment/uu -q -O - | patch -p0
    sed -i "s/ac_subst_vars='\(.*\)/ac_subst_vars='\1\nhost_cpu_instructionset/" configure
    sed -i 's/ld -r/\\$(LD) -r/' makemake.in
    cd ..
    CC='gcc -m32' LD='ld -melf_i386' ./configure --prefix=#{prefix} --cbc build --with-libsigsegv-prefix=#{prefix}
    make install -C build
    EOH
    not_if "test -e #{prefix}/bin/clisp"
  end
end

install_libsigsegv(
  'http://ftp.gnu.org/pub/gnu/libsigsegv',
  'libsigsegv-2.8.tar.gz',
  'libsigsegv-2.8',
  '/usr/local/clisp-2.49.0')

install_clisp(
  'http://ftp.gnu.org/pub/gnu/clisp/release/2.49/',
  'clisp-2.49.tar.bz2',
  'clisp-2.49',
  '/usr/local/clisp-2.49.0')
