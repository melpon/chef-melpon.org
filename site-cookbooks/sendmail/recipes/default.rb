#
# Cookbook Name:: sendmail
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package 'sendmail-bin'

domain = 'melpon.org'

bash 'set mailaddress' do
  action :run
  user 'root'
  code <<-SH
    set -ex
    echo "Dm#{domain}" >> /etc/mail/sendmail.mc
    echo "Cw#{domain}" >> /etc/mail/sendmail.mc
    echo "define(\\`confDOMAIN_NAME', \\`#{domain}')dnl" >> /etc/mail/sendmail.mc
    echo "MASQUERADE_AS(\\`#{domain}')dnl" >> /etc/mail/sendmail.mc
    m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
    service sendmail restart
  SH
  not_if "cat /etc/mail/sendmail.mc | grep 'confDOMAIN_NAME'"
end

bash 'set hostname' do
  action :run
  user 'root'
  code <<-SH
    set -ex
    sed "s/ubuntu.localdomain/melpon.org/" /etc/hosts > /tmp/hosts
    mv /tmp/hosts /etc/hosts
    chmod 644 /etc/hosts
  SH
  only_if "cat /etc/hosts | grep 'ubuntu.localdomain'"
end

