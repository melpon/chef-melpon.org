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

package "git" do
  action :install
end

bash "install cabal-dev" do
  action :run

  code <<-SH
  su - #{node.wandbox.user} -c '
  cabal update
  cabal install cabal-dev
  '
  SH

  not_if "su - #{node.wandbox.user} -c 'test -e .cabal/bin/cabal-dev'"
end

git node.wandbox.home + "/wandbox" do
  repository "git://github.com/melpon/wandbox.git"
  action :sync
  user node.wandbox.user
  group node.wandbox.group
end

bash "make cattleshed" do
  action :run

  code <<-SH
  su - #{node.wandbox.user} -c '
  cd wandbox/cattleshed
  make || make || make || make || make
  '
  SH

  not_if "su - #{node.wandbox.user} -c 'test -e wandbox/cattleshed/server.exe'"
end

bash "install kennel" do
  action :run

  code <<-SH
  su - #{node.wandbox.user} -c '
  source ~/.bashrc
  cd wandbox/kennel
  cabal-dev install yesod-platform-1.0.0 --force-reinstalls
  cabal-dev install
  '
  SH

  not_if "su - #{node.wandbox.user} -c 'test -e wandbox/kennel/cabal-dev/bin/kennel'"
end

#script "run" do
#  action :run
#  user node.wandbox.user
#
#  code <<-SH
#  cd #{node.wandbox.home + "/wandbox/cattleshed"}
#  nohup ./server.exe &
#  cd #{node.wandbox.home + "/wandbox/kennel"}
#  nohup ./dist/bin/kennel Production &
#  SH
#end
