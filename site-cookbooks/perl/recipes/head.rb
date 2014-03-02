include_recipe 'heads'

build_dir = '/home/heads/perl'
prefix = '/usr/local/perl-head'
build_sh = '/home/heads/build/perl.sh'

user build_user do
  action :create
  home build_home
  supports :manage_home => true
  shell '/bin/bash'
end

git build_dir do
  repository 'git://perl5.git.perl.org/perl.git'
  action :sync
  user 'heads'
  group 'heads'
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -ex
  su - heads -c '
    cd #{build_dir}
    git checkout blead
    git clean -xdqf

    ./configure --prefix=#{prefix} -Dusedevel
    nice make
  '
  cd #{build_dir}
  nice make install

  su - heads -c '
    cd #{build_dir}
    ln -s perl5.* perl
  '
  SH
end

# test building
bash 'test building perl-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/perl'}"
end
