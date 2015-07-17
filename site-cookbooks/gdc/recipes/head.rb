include_recipe 'heads'
include_recipe 'git'
include_recipe 'gcc::depends'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/gdc'
prefix = '/usr/local/gdc-head'
build_sh = build_home + '/build/gdc.sh'

gcc_git_repo = 'git://gcc.gnu.org/git/gcc.git'
flags = '--enable-lto --disable-multilib --without-ppl --without-cloog-ppl --enable-checking=release --disable-nls'

gdc_git_repo = 'https://github.com/D-Programming-GDC/GDC.git'

languages = 'd'

bash 'git clone gcc for gdc' do
  action :run
  user 'root'
  cwd build_home
  code <<-SH
    su - #{build_user} -c '
      mkdir -p #{build_dir}
      git clone #{gcc_git_repo} #{build_dir + '/gcc-source'}
      cd #{build_dir + '/gcc-source'}
      git checkout master
    '
  SH
  not_if "test -d #{build_dir + '/gcc-source'}"
end

bash 'git clone gdc' do
  action :run
  user 'root'
  cwd build_home
  code <<-SH
    su - #{build_user} -c '
      mkdir -p #{build_dir}
      git clone #{gdc_git_repo} #{build_dir + '/gdc-source'}
      cd #{build_dir + '/gdc-source'}
      git checkout master
    '
  SH
  not_if "test -d #{build_dir + '/gdc-source'}"
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  #!/bin/bash

  set -ex
  su - #{build_user} -c '
    set -ex

    cd #{build_dir}/gdc-source
    git clean -xdqf
    git reset --hard
    git pull
    git clean -xdqf
    #cd libphobos
    #autoreconf -i
    sed -i "s/d-warn = /d-warn = -Wno-suggest-attribute=format /" gcc/d/Make-lang.in

    cd #{build_dir}/gcc-source
    git clean -xdqf
    git reset --hard
    git pull
  '
  cd /home/heads/gdc/gcc-source
  UNTIL=`cat ../gdc-source/gcc.version | cut -d- -f3 | date -f - +%FT24:00:00Z+00:00`
  COMMIT=`git log origin/master --until $UNTIL -n1 --pretty=format:%H`
  echo $COMMIT > commit
  su - heads -c '
    set -ex

    cd /home/heads/gdc/gcc-source
    git reset --hard `cat commit`
    git clean -xdqf

    cd #{build_dir}/gdc-source
    ./setup-gcc.sh #{build_dir}/gcc-source

    rm -rf #{build_dir}/build || true
    mkdir #{build_dir}/build
    cd #{build_dir}/build

    #{build_dir}/gcc-source/configure --prefix=#{prefix} --enable-languages=#{languages} #{flags}
    nice make -j2
  '
  cd #{build_dir}/build
  make install
  SH
end

# test building
bash 'test building gdc-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/gdc'}"
end
