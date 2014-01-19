#
# Cookbook Name:: coffee-script
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
def install_coffee_script(prefix, commit, npm)
  bash "install coffee-script #{commit}" do
    action :run
    code <<-SH
      set -ex
      git clone https://github.com/jashkenas/coffee-script.git #{prefix}
      cd #{prefix}
      git checkout #{commit}
      #{npm} install
    SH
    not_if "test -e #{prefix}/bin/coffee"
  end
end

install_coffee_script(
  '/usr/local/coffee-script-1.6.3',
  'refs/tags/1.6.3',
  '/usr/local/node-0.10.24/bin/npm')
