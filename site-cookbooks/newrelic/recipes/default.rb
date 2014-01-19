#
# Cookbook Name:: newrelic
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# insert license_key here.
license_key = ''

bash 'install newrelic' do
  user "root"
  code <<-EOH
    set -e
    echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list
    wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
    apt-get update
    apt-get install newrelic-sysmond
    nrsysmond-config --set license_key=#{license_key}
    /etc/init.d/newrelic-sysmond start
  EOH
  not_if "test -e /etc/apt/sources.list.d/newrelic.list"
end
