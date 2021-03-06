include_recipe 'heads'
include_recipe 'git'
include_recipe 'gcc::depends'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/gcc'
prefix = '/usr/local/gcc-head'
build_sh = build_home + '/build/gcc.sh'

gcc_git_repo = 'git://gcc.gnu.org/git/gcc.git'
flags = '--enable-lto --disable-multilib --without-ppl --without-cloog-ppl --enable-checking=release --disable-nls'

languages = 'c,c++'

bash 'git clone gcc' do
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

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -ex
  su - #{build_user} -c '
    set -ex

    cd #{build_dir}/gcc-source
    git clean -xdqf
    git reset --hard
    git pull
    git clean -xdqf

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
bash 'test building gcc-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/gcc'}"
end
