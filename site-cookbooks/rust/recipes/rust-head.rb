include_recipe 'build-essential'
include_recipe 'git'

build_user = 'rustbuilder'
build_home = '/home/' + build_user
build_sh = build_home + '/build.sh'
build_rust = build_home + '/rust'
git_repo = 'https://github.com/mozilla/rust.git'
prefix = '/usr/local/rust-head'

user build_user do
  action :create
  home build_home
  supports :manage_home => true
  shell '/bin/bash'
end

git build_rust do
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
  cd #{build_rust}
  git checkout master

  set +e
  git pull --rebase
  if [ $? -ne 0 ]; then
    set -e
    git clean -d -x -f
    git pull --rebase
  fi
  set -e

  set +e
  nice make
  if [ $? -ne 0 ]; then
    set -e
    git clean -d -x -f
    ./configure --prefix=#{prefix} --disable-docs --disable-llvm-assertions --disable-debug
    nice make
  fi
  '
  cd #{build_rust}
  make install
  SH
end

# build rust-head every day
cron 'update_rust_head' do
  action :create
  minute '0'
  hour '8'
  command build_sh
  mailto node['email']
end

# test building
bash 'test building rust-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/rustc'}"
end
