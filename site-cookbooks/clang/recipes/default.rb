#
# Cookbook Name:: clang
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'build-essential'
include_recipe 'python'

package "cmake" do
  action :install
end

package "subversion" do
  action :install
end

def install_llvm(name, llvm_repo, clang_repo, crt_repo, prefix)
  subversion "svn LLVM #{name}" do
    action :export
    destination "#{Chef::Config[:file_cache_path]}/#{name}"
    repository llvm_repo
    not_if "test -e #{prefix}/bin/clang"
  end

  subversion "svn Clang #{name}" do
    action :export
    destination "#{Chef::Config[:file_cache_path]}/#{name}/tools/clang"
    repository clang_repo
    not_if "test -e #{prefix}/bin/clang"
  end

  subversion "svn Compiler-RT #{name}" do
    action :export
    destination "#{Chef::Config[:file_cache_path]}/#{name}/projects/compiler-rt"
    repository crt_repo
    not_if "test -e #{prefix}/bin/clang"
  end

  bash "install #{name}" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
    set -e
    mkdir -p #{name}_build
    cd #{name}_build
    ../#{name}/configure --prefix=#{prefix} --enable-optimized --enable-assertions=no --enable-targets=host-only
    make -j2 > log 2>err
    sudo make install
    cd ../
    rm -r #{name}
    rm -r #{name}_build
    EOH
    not_if "test -e #{prefix}/bin/clang"
  end
end

def install_libcxx(name, repo, prefix, llvm_path)
  subversion "svn-#{name}" do
    action :export
    destination "#{Chef::Config[:file_cache_path]}/#{name}"
    repository repo
    not_if "test -e #{prefix}/lib/libc++.so"
  end

  bash "install-#{name}" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
    set -e
    mkdir #{name}_build
    cd #{name}_build
    CC=#{llvm_path}/bin/clang CXX=#{llvm_path}/bin/clang++ cmake -G "Unix Makefiles" -DLIBCXX_CXX_ABI=libsupc++ -DLIBCXX_LIBSUPCXX_INCLUDE_PATHS="/usr/include/c++/4.6;/usr/include/c++/4.6/x86_64-linux-gnu" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=#{prefix} ../#{name}
    make -j2 > log 2>err
    sudo make install
    cd ../
    rm -r #{name}
    rm -r #{name}_build
    EOH
  
    not_if "test -e #{prefix}/lib/libc++.so"
  end
end


install_llvm(
    'llvm-3.4',
    'http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_34/final',
    'http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_34/final',
    'http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_34/final',
    '/usr/local/llvm-3.4')
install_llvm(
    'llvm-3.3',
    'http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_33/final',
    'http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_33/final',
    'http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_33/final',
    '/usr/local/llvm-3.3')
install_llvm(
    'llvm-3.2',
    'http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_32/final',
    'http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_32/final',
    'http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_32/final',
    '/usr/local/llvm-3.2')
install_llvm(
    'llvm-3.1',
    'http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_31/final',
    'http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_31/final',
    'http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_31/final',
    '/usr/local/llvm-3.1')
install_llvm(
    'llvm-3.0',
    'http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_30/final',
    'http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_30/final',
    'http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_30/final',
    '/usr/local/llvm-3.0')

install_libcxx(
    'libcxx-3.4',
    'http://llvm.org/svn/llvm-project/libcxx/tags/RELEASE_34/final',
    '/usr/local/libcxx-3.4',
    '/usr/local/llvm-3.4')
install_libcxx(
    'libcxx-3.3',
    'http://llvm.org/svn/llvm-project/libcxx/tags/RELEASE_33/final',
    '/usr/local/libcxx-3.3',
    '/usr/local/llvm-3.3')
install_libcxx(
    'libcxx-3.0',
    'http://llvm.org/svn/llvm-project/libcxx/tags/RELEASE_30/final',
    '/usr/local/libcxx-3.0',
    '/usr/local/llvm-3.0')
