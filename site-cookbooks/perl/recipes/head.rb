include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/perl'
# This prefix is removed every building.
# So the prefix must not specify '/usr/local'
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
    git clean -xdqf
    git checkout blead
    git reset --hard
    git pull origin blead

    ./configure.gnu --prefix=#{prefix} -Dusedevel
    nice make
  '
  rm -rf #{prefix}

  cd #{build_dir}
  nice make install

  cd #{prefix}/bin
  rm perl || true
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
