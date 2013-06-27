#
# Cookbook Name:: wandbox
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "boost"
include_recipe "haskell"

case node['platform_family']
when "debian"
  package "libboost-system-dev"
end

package "git" do
  action :install
end

script "install cabal-dev" do
  action :run
  user node.wandbox.user
  group node.wandbox.group

  cwd node.wandbox.home
  environment Hash['HOME' => node.wandbox.home]

  interpreter "bash"

  code <<-SH
  cabal update
  cabal install cabal-dev
  SH
end

git node.wandbox.home + "/wandbox" do
  repository "git://github.com/melpon/wandbox.git"
  action :sync
  user node.wandbox.user
  group node.wandbox.group
end

script "make cattleshed" do
  action :run
  cwd node.wandbox.home + "/wandbox/cattleshed"
  user node.wandbox.user

  interpreter "bash"

  code <<-SH
  make
  SH
end

script "install kennel" do
  action :run
  cwd node.wandbox.home + "/wandbox/kennel"
  user node.wandbox.user

  interpreter "bash"

  code <<-SH
  cabal-dev install yesod-platform-1.0.0 --force-reinstalls
  cabal-dev install
  SH
end

script "run" do
  action :run
  user node.wandbox.user

  code <<-SH
  cd #{node.wandbox.home + "/wandbox/cattleshed"}
  nohup ./server.exe &
  cd #{node.wandbox.home + "/wandbox/kennel"}
  nohup ./dist/bin/kennel Production &
  SH
end
