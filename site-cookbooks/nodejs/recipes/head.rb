include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/node'
prefix = '/usr/local/node-head'
build_sh = build_home + '/build/node.sh'

bash 'git clone node' do
  action :run
  user build_user
  cwd build_home
  code "git clone https://github.com/joyent/node.git"
  not_if "test -d #{build_home + '/node'}"
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
    git pull origin master

    ./configure --prefix=#{prefix}
    nice make
  '
  cd #{build_dir}
  nice make install
  SH
end

# test building
bash 'test building node-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/node'}"
end
