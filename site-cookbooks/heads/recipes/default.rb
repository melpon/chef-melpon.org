#
# Cookbook Name:: heads
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
build_sh = '/home/heads/build.sh'
build_dir = '/home/heads/build'
with_cron_sh = '/home/heads/with_cron.sh'

twitter_root = '/root/twitter'
twitter_post_sh = twitter_root + '/post.sh'
twitter_settings = '/var/twitter/settings.json'

user 'heads' do
  action :create
  home '/home/heads'
  supports :manage_home => true
  shell '/bin/bash'
end

directory build_dir do
  user 'root'
  group 'root'
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
    has_error=0
    cd #{build_dir}
    rm /tmp/heads/cron/error_scripts || true
    mkdir -p /tmp/heads/cron
    touch /tmp/heads/cron/error_scripts
    echo "[`date`] ---- BEGIN $0 ----"
    for line in `ls *.sh -1`; do
      echo "[`date`] start building $line"
      ./$line > /tmp/heads/cron/$line 2>&1
      if [ $? -ne 0 ]; then
        echo "[`date`] FAILURE: $line. log file is /tmp/heads/cron/$line"
        echo "$line" >> /tmp/heads/cron/error_scripts
        has_error=1
      fi
      echo "[`date`] end building $line"
    done
    echo "[`date`] ---- END $0 with exit $has_error ----"
    exit $has_error
  SH
end

file with_cron_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
    #{build_sh} > /tmp/heads/cron/log 2>&1
    if [ $? -ne 0 ]; then
        #{twitter_post_sh} /tmp/heads/cron/error_scripts
    fi
  SH
end

bash 'initialize twitter' do
  action :run
  user 'root'
  code <<-SH
    set -ex

    mkdir -p #{twitter_root}
    cd #{twitter_root}
    virtualenv -p /usr/bin/python #{twitter_root}/shared
    source #{twitter_root}/shared/bin/activate
    pip install twitter

    echo "
import sys
import json
import twitter


settings = json.loads(open('#{twitter_settings}').read())
tw = twitter.Twitter(
    auth=twitter.OAuth(
        settings['access-token'],
        settings['access-token-secret'],
        settings['api-key'],
        settings['api-secret']))
tw.statuses.update(status=sys.stdin.read())
" > #{twitter_root + '/post.py'}

    echo "
#coding: utf-8
import sys


error_scripts = [line[:-1] for line in sys.stdin.readlines()]
print '''[Wandbox] Failed Scripts: {}
Build logs is here: http://melpon.org/wandbox/errors

三へ( へ՞ਊ ՞)へ ﾊｯﾊｯ cc: @kikairoya'''.format(
    ', '.join(error_scripts))
" > #{twitter_root + '/prepost.py'}

    echo "#!/bin/bash
source #{twitter_root}/shared/bin/activate
/bin/cat \\$1 | python #{twitter_root + '/prepost.py'} | python #{twitter_root + '/post.py'}
" > #{twitter_post_sh}

    chmod +x #{twitter_post_sh}
  SH
  not_if "test -e #{twitter_post_sh}"
end

# build heads every day
cron 'update_heads' do
  action :create
  minute '1'
  hour '0'
  command with_cron_sh
  mailto node['email']
end
