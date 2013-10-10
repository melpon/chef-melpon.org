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

llvm_repo = 'http://llvm.org/svn/llvm-project/llvm/trunk'
cfe_repo = 'http://llvm.org/svn/llvm-project/cfe/trunk'
rt_repo = 'http://llvm.org/svn/llvm-project/compiler-rt/trunk'
libcxx_repo = 'http://llvm.org/svn/llvm-project/libcxx/trunk'

user build_user do
  action :create
  home build_home
  supports :manage_home => true
  shell '/bin/bash'
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -e

  # checkout llvm-head
  sudo -u #{build_user} rm -rf #{build_clang} | true
  sudo -u #{build_user} mkdir #{build_clang}
  sudo -u #{build_user} svn co #{llvm_repo} #{build_clang}
  sudo -u #{build_user} svn co #{cfe_repo} #{build_clang}/tools/clang
  sudo -u #{build_user} svn co #{rt_repo} #{build_clang}/projects/compiler-rt

  # clean llvm-head
  sudo -u #{build_user} rm -rf #{build_clang_dir} | true
  sudo -u #{build_user} mkdir #{build_clang_dir}
  cd #{build_clang_dir}

  # build llvm-head
  sudo -u #{build_user} #{build_clang}/configure --prefix=#{llvm_prefix} --enable-optimized --enable-assertions=no --enable-targets=host-only
  sudo -u #{build_user} nice make -j2
  make install


  # update libcxx-head
  sudo -u #{build_user} rm -rf #{build_libcxx} | true
  sudo -u #{build_user} svn co #{libcxx_repo} #{build_libcxx}

  # clean libcxx-head
  sudo -u #{build_user} rm -rf #{build_libcxx_dir} | true
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
