#
# Cookbook Name:: clang
# Recipe:: clang-head
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

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/clang'
build_sh = build_home + '/build/clang.sh'
llvm_prefix = '/usr/local/llvm-head'
libcxx_prefix = '/usr/local/libcxx-head'

llvm_repo = 'http://llvm.org/svn/llvm-project/llvm/trunk'
cfe_repo = 'http://llvm.org/svn/llvm-project/cfe/trunk'
rt_repo = 'http://llvm.org/svn/llvm-project/compiler-rt/trunk'
libcxx_repo = 'http://llvm.org/svn/llvm-project/libcxx/trunk'

with_gcc='/usr/local/gcc-4.8.2'

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -ex

  export LD_LIBRARY_PATH=#{with_gcc}/lib64:$LD_LIBRARY_PATH

  su - #{build_user} -c '
    set -ex

    export LD_LIBRARY_PATH=#{with_gcc}/lib64:$LD_LIBRARY_PATH

    LLVM_SOURCE="#{build_dir}/llvm-source"
    LLVM_BUILD="#{build_dir}/llvm-build"

    # checkout llvm-head
    rm -rf $LLVM_SOURCE || true
    mkdir -p $LLVM_SOURCE
    svn co #{llvm_repo} $LLVM_SOURCE
    svn co #{cfe_repo} $LLVM_SOURCE/tools/clang
    svn co #{rt_repo} $LLVM_SOURCE/projects/compiler-rt

    # clean llvm-head
    rm -rf $LLVM_BUILD || true
    mkdir -p $LLVM_BUILD
    cd $LLVM_BUILD

    # build llvm-head
    CC=#{with_gcc}/bin/gcc CXX=#{with_gcc}/bin/g++ $LLVM_SOURCE/configure --prefix=#{llvm_prefix} --enable-optimized --enable-assertions=no --enable-targets=host-only --enable-clang-static-analyzer --with-gcc-toolchain=#{with_gcc}
    nice make -j2
  '
  cd #{build_dir}/llvm-build
  make install

  echo '#!/bin/sh
export LD_LIBRARY_PATH=#{with_gcc}/lib64:$LD_LIBRARY_PATH
#{llvm_prefix}/bin/clang++ "$@"
  ' > #{llvm_prefix}/bin/run-clang++.sh
  chmod +x #{llvm_prefix}/bin/run-clang++.sh

  su - #{build_user} -c '
    set -ex

    export LD_LIBRARY_PATH=#{with_gcc}/lib64:$LD_LIBRARY_PATH

    LIBCXX_SOURCE="#{build_dir}/libcxx-source"
    LIBCXX_BUILD="#{build_dir}/libcxx-build"

    # update libcxx-head
    rm -rf $LIBCXX_SOURCE || true
    svn co #{libcxx_repo} $LIBCXX_SOURCE

    # clean libcxx-head
    rm -rf $LIBCXX_BUILD || true
    mkdir -p $LIBCXX_BUILD
    cd $LIBCXX_BUILD

    # build libcxx-head
    CC=#{llvm_prefix}/bin/clang CXX=#{llvm_prefix}/bin/clang++ cmake -G "Unix Makefiles" -DLIBCXX_CXX_ABI=libsupc++ -DLIBCXX_LIBSUPCXX_INCLUDE_PATHS="/usr/include/c++/4.6;/usr/include/c++/4.6/x86_64-linux-gnu" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=#{libcxx_prefix} $LIBCXX_SOURCE
    nice make -j2
  '
  cd #{build_dir}/libcxx-build
  make install
  SH
end

# test building
bash 'test building clang-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{llvm_prefix}/bin/clang"
end
