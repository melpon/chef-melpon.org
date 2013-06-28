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

bash "initialize cabal" do
  action :run

  code <<-SH
  su - #{node.haskell.user}
  cabal update
  SH

  not_if "test -d #{node.haskell.home}/.cabal/"
end

bash "add path to cabal" do
  action :run
  user node.haskell.user

  code <<-SH
    echo 'export PATH=$HOME/.cabal/bin:$PATH' >> #{node.haskell.home + '/.profile'}
  SH

  not_if "grep -q '.cabal/bin' #{node.haskell.home + '/.profile'}"
end
