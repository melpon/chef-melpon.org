include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/dmd'
prefix = '/usr/local/dmd-head'
build_sh = build_home + '/build/dmd.sh'

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -ex
  su - #{build_user} -c '
    set -ex
    mkdir -p #{build_dir}
    cd #{build_dir}

    rm -r install || true
    rm -r dmd || true
    rm -r druntime || true
    rm -r phobos || true

    git clone https://github.com/D-Programming-Language/dmd
    cd dmd
    nice make -f posix.mak AUTO_BOOTSTRAP=1
    nice make -f posix.mak install AUTO_BOOTSTRAP=1
    cd ..

    git clone https://github.com/D-Programming-Language/druntime
    cd druntime
    nice make -f posix.mak
    nice make -f posix.mak install
    cd ..

    git clone https://github.com/D-Programming-Language/phobos
    cd phobos
    nice make -f posix.mak
    nice make -f posix.mak install
    cd ..
  '
  rm -rf #{prefix} || true
  cp -r #{build_dir}/install #{prefix}
  SH
end

# test building
bash 'test building dmd-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/linux/bin64/dmd'}"
end
