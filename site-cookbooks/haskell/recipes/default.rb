#
# Cookbook Name:: haskell
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
cookbook_file "/etc/profile.d/cabal.sh" do
  mode 0755
end

package "ghc" do
  action :install
end

user node.haskell.user do
  action :create
  home node.haskell.home
  supports :manage_home => true
end

script "initialize cabal" do
  interpreter "bash"
  user node.haskell.user
  cwd  node.haskell.home

  environment Hash['HOME' => node.haskell.home]

  code <<-SH
  cabal update
  SH

  # triggered by haskell-platform installation
  action :nothing
  # until http://haskell.1045720.n5.nabble.com/Cabal-install-fails-due-to-recent-HUnit-tt5715081.html#none is resolved :( MK.
  ignore_failure true
end

package "haskell-platform" do
  action :install

  notifies :run, resources(:script => "initialize cabal")
end
