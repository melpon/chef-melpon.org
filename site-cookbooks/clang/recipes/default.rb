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
    nice make -j2 > log 2>err
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

with_gcc='/usr/local/gcc-4.8.2'

def install_llvm_with_gcc(name, llvm_repo, clang_repo, crt_repo, prefix, with_gcc)
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
    export LD_LIBRARY_PATH=#{with_gcc}/lib64:$LD_LIBRARY_PATH
    CC=#{with_gcc}/bin/gcc CXX=#{with_gcc}/bin/g++ ../#{name}/configure --prefix=#{prefix} --enable-optimized --enable-assertions=no --enable-targets=host-only
    nice make -j2 > log 2>err
    sudo make install
    cd ../
    rm -r #{name}
    rm -r #{name}_build
    EOH
    not_if "test -e #{prefix}/bin/clang"
  end

  bash "generate run-clang #{name}" do
    code <<-EOH
      echo '#!/bin/sh
export LD_LIBRARY_PATH=#{with_gcc}/lib64:$LD_LIBRARY_PATH
#{prefix}/bin/clang++ "$@"
      ' > #{prefix}/bin/run-clang++.sh
      chmod +x #{prefix}/bin/run-clang++.sh
    EOH
    not_if "test -e #{prefix}/bin/run-clang++.sh"
  end
end

def install_libcxx_with_gcc(name, repo, prefix, llvm_path, with_gcc)
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
    export LD_LIBRARY_PATH=#{with_gcc}/lib64:$LD_LIBRARY_PATH
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


install_llvm_with_gcc(
    'llvm-3.6',
    'http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_360/final',
    'http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_360/final',
    'http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_360/final',
    '/usr/local/llvm-3.6',
    with_gcc)
install_llvm_with_gcc(
    'llvm-3.5',
    'http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_350/final',
    'http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_350/final',
    'http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_350/final',
    '/usr/local/llvm-3.5',
    with_gcc)
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

install_libcxx_with_gcc(
    'libcxx-3.6',
    'http://llvm.org/svn/llvm-project/libcxx/tags/RELEASE_360/final',
    '/usr/local/libcxx-3.6',
    '/usr/local/llvm-3.6',
    with_gcc)
install_libcxx_with_gcc(
    'libcxx-3.5',
    'http://llvm.org/svn/llvm-project/libcxx/tags/RELEASE_350/final',
    '/usr/local/libcxx-3.5',
    '/usr/local/llvm-3.5',
    with_gcc)
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
