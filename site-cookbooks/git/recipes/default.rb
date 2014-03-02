#
# Cookbook Name:: git
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package 'git' do
  action :install
end

package 'mercurial' do
  action :install
end

file '/etc/mercurial/hgrc' do
  user 'root'
  group 'root'
  content <<-SH
[extensions]
hgext.purge=
SH

end
