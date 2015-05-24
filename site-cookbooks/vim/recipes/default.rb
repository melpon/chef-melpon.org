#
# Cookbook Name:: vim
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{
  mercurial
  gettext
  libncurses5-dev
  libacl1-dev
  libgpm-dev
}.each do |pc|
  package pc do
    action :install
  end
end

def install_vim(repo, branch, build_dir, prefix)
  bash "install-vim #{build_dir}" do
    user "root"
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
      set -ex
      hg clone #{repo} #{build_dir}
      cd #{build_dir}
      hg pull
      hg update -r #{branch}
      ./configure --with-features=huge --prefix=#{prefix}
      make
      make install
      cd ../
      rm -r #{build_dir}
    EOH
    not_if "test -e #{prefix}/bin/vim"
  end
end

install_vim(
  'https://vim.googlecode.com/hg/',
  'v7-4-729',
  'vim-7.4.729',
  '/usr/local/vim-7.4.729')

