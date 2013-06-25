#
# Cookbook Name:: swapfile
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
script "swapfile" do
  action :run

  code <<-SH
    dd if=/dev/zero of=/swapfile1 bs=1024 count=#{node.swapfile.size}
    mkswap /swapfile1
    chmod 0600 /swapfile1
    swapon /swapfile1
    echo "/swapfile1 swap swap defaults 0 0" >> /etc/fstab
  SH

  not_if { ::File.exists?("/swapfile1") }
end
