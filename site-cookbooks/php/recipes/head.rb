include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/php-src'
prefix = '/usr/local/php-head'
build_sh = build_home + '/build/php.sh'

bash 'git clone php' do
  action :run
  user build_user
  cwd build_home
  code "git clone https://github.com/php/php-src.git"
  not_if "test -d #{build_home + '/php-src'}"
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -ex
  su - #{build_user} -c '
    cd #{build_dir}
    git clean -xdqf
    git checkout master
    git reset --hard
    git pull origin master

    ./buildconf
    ./configure --prefix=#{prefix}
    nice make
  '
  cd #{build_dir}
  nice make install
  SH
end

# test building
bash 'test building php-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/php'}"
end
