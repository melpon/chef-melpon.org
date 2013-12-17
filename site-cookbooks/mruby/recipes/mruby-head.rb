include_recipe 'build-essential'
include_recipe 'git'

build_user = 'mrubybuilder'
build_home = '/home/' + build_user
build_sh = build_home + '/build.sh'
build_mruby = build_home + '/mruby'
git_repo = 'https://github.com/mruby/mruby.git'
prefix = '/usr/local/mruby-head'

user build_user do
  action :create
  home build_home
  supports :manage_home => true
  shell '/bin/bash'
end

git build_mruby do
  repository git_repo
  action :sync
  user build_user
  group build_user
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -e
  su - #{build_user} -c '
  set -e
  cd #{build_mruby}
  git checkout master
  git pull --rebase
  git clean -d -x -f

  nice ruby ./minirake
  '
  rm -r #{prefix} || true
  cp -r #{build_mruby} #{prefix}
  SH
end

# build mruby-head every day
cron 'update_mruby_head' do
  action :create
  minute '0'
  hour '7'
  command build_sh
  mailto node['email']
end

# test building
bash 'test building mruby-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/mruby'}"
end
