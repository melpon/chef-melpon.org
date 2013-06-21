#
# Cookbook Name:: haskell
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "haskell"
include_recipe "boost"

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
