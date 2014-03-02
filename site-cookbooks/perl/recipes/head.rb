include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/perl'
prefix = '/usr/local/perl-head'
build_sh = build_home + '/build/perl.sh'

git build_dir do
  repository 'git://perl5.git.perl.org/perl.git'
  action :sync
  user build_user
  group build_user
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -ex
  su - #{build_user} -c '
    cd #{build_dir}
    git checkout blead
    git clean -xdqf

    ./configure.gnu --prefix=#{prefix} -Dusedevel
    nice make
  '
  cd #{build_dir}
  nice make install

  cd #{prefix}/bin
  ln -s perl5.* perl
  SH
end

# test building
bash 'test building perl-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/perl'}"
end
