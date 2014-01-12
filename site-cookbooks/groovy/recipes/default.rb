#
# Cookbook Name:: groovy
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "unzip" do
  action :install
end

def install_groovy(source, file, dir, prefix)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/groovy"
  end

  bash "install-#{dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]

    code <<-EOH
      set -e

      unzip #{file}
      cp -r #{dir} #{prefix}
    EOH

    not_if "test -e #{prefix}/bin/groovy"
  end
end

install_groovy('http://dist.groovy.codehaus.org/distributions/', 'groovy-binary-2.2.1.zip', 'groovy-2.2.1', '/usr/local/groovy-2.2.1')
