include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/ruby'
prefix = '/usr/local/ruby-head'
build_sh = build_home + '/build/ruby.sh'

bash 'git clone ruby' do
  action :run
  user build_user
  cwd build_home
  code "git clone https://github.com/ruby/ruby.git"
  not_if "test -d #{build_home + '/ruby'}"
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
    git checkout trunk
    git pull --ff-only

    autoconf
    ./configure --prefix=#{prefix}
    nice make
  '
  cd #{build_dir}
  nice make install
  SH
end

# test building
bash 'test building ruby-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -d #{prefix + '/bin'}"
end
