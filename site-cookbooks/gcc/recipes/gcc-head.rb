include_recipe 'build-essential'
include_recipe 'gcc::depends'
include_recipe 'git'

build_user = 'gccbuilder'
build_home = '/home/' + build_user
build_sh = build_home + '/build.sh'
build_gcc = build_home + '/gcc'
build_gdc = build_home + '/gdc'
build_dir = build_home + '/build'
languages = 'c,c++'
gcc_git_repo = node['gcc_head']['repository']
with_gdc = node['gcc_head']['with_gdc']

user build_user do
  action :create
  home build_home
  supports :manage_home => true
  shell '/bin/bash'
end

git build_gcc do
  repository gcc_git_repo
  action :sync
  user build_user
  group build_user
end

if with_gdc then
  git build_gdc do
    repository 'https://github.com/D-Programming-GDC/GDC.git'
    action :sync
    user build_user
    group build_user
  end
  languages = 'c,c++,d'
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -e
  su - #{build_user} -c '
    cd #{build_gcc}
    git checkout master
    git reset --hard
    git clean -xfd
    git pull --rebase

    #{"cd #{build_gdc}" if with_gdc}
    #{'git checkout master' if with_gdc}
    #{'git pull --rebase' if with_gdc}
    #{"./setup-gcc.sh #{build_gcc}" if with_gdc}

    rm -rf #{build_dir}
    mkdir #{build_dir}
    cd #{build_dir}

    #{build_gcc}/configure --prefix=#{node['gcc_head']['prefix']} --enable-languages=#{languages} #{node['gcc_head']['flags']}
    nice make -j2
  '
  cd #{build_dir}
  make install
  SH
end

# build gcc-head every day
cron 'update_gcc_head' do
  action :create
  minute '0'
  hour '4'
  command build_sh
  mailto node['email']
end

# test building
bash 'test building gcc-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{node['gcc_head']['prefix'] + '/bin/gcc'}"
end
