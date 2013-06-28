#
# Cookbook Name:: haskell
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "ghc" do
  action :install
end

user node.haskell.user do
  action :create
  home node.haskell.home
  supports :manage_home => true
  shell "/bin/bash"
end

package "haskell-platform" do
  action :install
end

script "initialize cabal" do
  action :run
  interpreter "bash"

  code <<-SH
  su - #{node.haskell.user}
  cabal update
  SH

  not_if "test -d #{node.haskell.home}/.cabal/"
end

file node.haskell.home + "/.bashrc" do
  owner node.haskell.user
  group node.haskell.group
  action :create
  content "export PATH=$HOME/.cabal/bin:$PATH"
end
