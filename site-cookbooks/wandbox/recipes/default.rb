#
# Cookbook Name:: wandbox
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
user node.travis_build_environment.user do
  action :create
  home node.travis_build_environment.home
  supports :manage_home => true
  shell "/bin/bash"
end

include_recipe "boost"
include_recipe "haskell"

ruby_block "insert_line" do
  block do
    file = Chef::Util::FileEdit.new(node.travis_build_environment.home + "/.bashrc")
    file.insert_line_if_no_match("/.cabal\\/bin/", "export PATH=$HOME/.cabal/bin:$PATH")
    file.write_file
  end
end

package "git" do
  action :install
end

script "install yesod" do
  action :run
  user node.travis_build_environment.user
  group node.travis_build_environment.group

  cwd node.travis_build_environment.home
  environment Hash['HOME' => node.travis_build_environment.home]

  interpreter "bash"

  code <<-SH
  cabal update
  cabal install yesod-platform-1.0.0 --force-reinstalls
  SH
end

git node.travis_build_environment.home + "/wandbox" do
  repository "git://github.com/melpon/wandbox.git"
  action :sync
  user node.travis_build_environment.user
  group node.travis_build_environment.group
end

script "make cattleshed" do
  action :run
  cwd node.travis_build_environment.home + "/wandbox/cattleshed"
  user node.travis_build_environment.user
  group node.travis_build_environment.group

  interpreter "bash"

  code <<-SH
  make
  SH
end

script "install kennel" do
  action :run
  cwd node.travis_build_environment.home + "/wandbox/kennel"
  user node.travis_build_environment.user
  group node.travis_build_environment.group

  interpreter "bash"

  code <<-SH
  cabal install
  SH
end

script "run" do
  action :run
  user node.travis_build_environment.user
  group node.travis_build_environment.group

  code <<-SH
  cd #{node.travis_build_environment.home + "/wandbox/cattleshed"}
  nohup ./server.exe &
  cd #{node.travis_build_environment.home + "/wandbox/kennel"}
  nohup ./dist/bin/kennel Production &
  SH
end
