include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/rust'
prefix = '/usr/local/rust-head'
build_sh = build_home + '/build/rust.sh'

git_repo = 'https://github.com/mozilla/rust.git'

bash 'git clone rust' do
  action :run
  user build_user
  cwd build_home
  code <<-SH
    git clone #{git_repo} #{build_dir}
    cd #{build_dir}
    git checkout master
  SH
  not_if "test -d #{build_dir}/.git"
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -ex
  su - #{build_user} -c '
    set -ex
    cd #{build_dir}
    git clean -xdqf
    git pull
    git clean -xdqf

    ./configure --prefix=#{prefix} --disable-docs --disable-llvm-assertions --disable-debug
    nice make -j3
  '
  cd #{build_dir}
  nice make install
  SH
end

# test building
bash 'test building rust-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/rustc'}"
end
