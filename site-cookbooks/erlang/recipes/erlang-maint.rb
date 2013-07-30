include_recipe 'build-essential'
include_recipe 'git'

build_user = 'erlangbuilder'
build_home = '/home/' + build_user
build_sh = build_home + '/build.sh'
build_erlang = build_home + '/erlang'
git_repo = 'https://github.com/erlang/otp.git'
prefix = '/usr/local/erlang-maint'

user build_user do
  action :create
  home build_home
  supports :manage_home => true
  shell '/bin/bash'
end

git build_erlang do
  repository git_repo
  action :sync
  revision 'maint'
  user build_user
  group build_user
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -e
  cd #{build_erlang}
  sudo -u #{build_user} git checkout maint
  sudo -u #{build_user} git pull --rebase
  sudo -u #{build_user} git clean -d -x -f

  sudo -u #{build_user} ./otp_build autoconf
  sudo -u #{build_user} ./configure --prefix=#{prefix}
  sudo -u #{build_user} nice make
  make install
  SH
end

# build erlang-maint every day
cron 'update_erlang_maint' do
  action :create
  minute '0'
  hour '6'
  command build_sh
end

# test building
bash 'test building erlang-maint' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/escript'}"
end
