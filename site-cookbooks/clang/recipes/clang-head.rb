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

llvm_prefix = '/usr/local/llvm-head'
build_user = 'clangbuilder'
build_home = '/home/' + build_user
build_sh = build_home + '/build.sh'
build_clang = build_home + '/clang'
build_clang_dir = build_home + '/clang_build'

build_libcxx = build_home + '/libcxx'
build_libcxx_dir = build_home + '/libcxx_build'
libcxx_prefix = '/usr/local/libcxx-head'

user build_user do
  action :create
  home build_home
  supports :manage_home => true
  shell '/bin/bash'
end

subversion "svn LLVM head" do
  action :sync
  destination build_clang
  repository 'http://llvm.org/svn/llvm-project/llvm/trunk'
  user build_user
  group build_user
end

subversion "svn Clang head" do
  action :sync
  destination "#{build_clang}/tools/clang"
  repository 'http://llvm.org/svn/llvm-project/cfe/trunk'
  user build_user
  group build_user
end

subversion "svn Compiler-RT head" do
  action :sync
  destination "#{build_clang}/projects/compiler-rt"
  repository 'http://llvm.org/svn/llvm-project/compiler-rt/trunk'
  user build_user
  group build_user
end

subversion "svn libcxx-head" do
  action :sync
  destination build_libcxx
  repository 'http://llvm.org/svn/llvm-project/libcxx/trunk'
  user build_user
  group build_user
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -e

  # update llvm-head
  cd #{build_clang}
  sudo -u #{build_user} svn update
  cd #{build_clang}/tools/clang
  sudo -u #{build_user} svn update
  cd #{build_clang}/projects/compiler-rt
  sudo -u #{build_user} svn update

  # clean llvm-head
  sudo -u #{build_user} rm -rf #{build_clang_dir}
  sudo -u #{build_user} mkdir #{build_clang_dir}
  cd #{build_clang_dir}

  # build llvm-head
  sudo -u #{build_user} #{build_clang}/configure --prefix=#{llvm_prefix} --enable-optimized --enable-assertions=no --enable-targets=host-only
  sudo -u #{build_user} nice make -j2
  make install


  # update libcxx-head
  cd #{build_libcxx}
  sudo -u #{build_user} svn update

  # clean libcxx-head
  sudo -u #{build_user} rm -rf #{build_libcxx_dir}
  sudo -u #{build_user} mkdir #{build_libcxx_dir}
  cd #{build_libcxx_dir}

  # build libcxx-head
  sudo -u #{build_user} CC=#{llvm_prefix}/bin/clang CXX=#{llvm_prefix}/bin/clang++ cmake -G "Unix Makefiles" -DLIBCXX_CXX_ABI=libsupc++ -DLIBCXX_LIBSUPCXX_INCLUDE_PATHS="/usr/include/c++/4.6;/usr/include/c++/4.6/x86_64-linux-gnu" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=#{libcxx_prefix} #{build_libcxx}
  sudo -u #{build_user} nice make -j2
  make install
  SH
end

# build clang-head every day
cron 'update_clang_head' do
  action :create
  minute '0'
  hour '5'
  command build_sh
end

# test building
bash 'test building clang-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{llvm_prefix}/bin/clang"
end
