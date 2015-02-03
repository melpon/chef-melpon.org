include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/mono'
prefix = '/usr/local/mono-head'
build_sh = build_home + '/build/mono.sh'

bash 'git clone mono' do
  action :run
  user build_user
  cwd build_home
  code "git clone https://github.com/mono/mono.git"
  not_if "test -d #{build_home + '/mono'}"
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
    git reset --hard
    git checkout master
    git pull
    git clean -xdqf

    ./autogen.sh --prefix=#{prefix} --disable-nls
    nice make
  '
  cd #{build_dir}
  nice make install
  SH
end

# test building
bash 'test building mono-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -d #{prefix + '/bin'}"
end
