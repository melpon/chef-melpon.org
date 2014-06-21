include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/rust'
prefix = '/usr/local/rust-head'
build_sh = build_home + '/build/rust.sh'

git_repo = 'https://github.com/mozilla/rust.git'
with_gcc = '/usr/local/gcc-4.8.2'

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
  cd #{build_dir}
  git clean -xdqf
  chown heads:heads -R ./

  export PATH=#{with_gcc}/bin:$PATH
  export LD_LIBRARY_PATH=#{with_gcc}/lib64:$LD_LIBRARY_PATH

  su - #{build_user} -c '
    set -ex
    cd #{build_dir}
    git reset --hard
    git clean -xdqf
    git pull
    git submodule update -i

    cd #{build_dir}/src/libuv
    export CC="gcc -fPIC"
    ./autogen.sh
    ./configure --prefix=#{build_dir}/libuv
    nice make
    nice make check
    nice make install

    cd #{build_dir}
    export PATH="#{with_gcc}/bin:$PATH"
    export CC="#{with_gcc}/bin/gcc"
    export CXX="#{with_gcc}/bin/g++"
    export LDFLAGS="-Wl,-rpath,#{with_gcc}/lib64"
    export RUSTFLAGS="-C linker=#{with_gcc}/bin/g++ -C link-args=-Wl,-rpath,#{with_gcc}/lib64"
    ./configure --prefix=#{prefix} --sysconfdir=#{prefix}/etc --disable-docs --disable-llvm-assertions --disable-debug --enable-llvm-static-stdcpp --libuv-root=#{build_dir}/libuv/lib
    nice make RUSTFLAGS="$RUSTFLAGS" -j3 -k
    nice make RUSTFLAGS="$RUSTFLAGS" -j3 -k
    nice make RUSTFLAGS="$RUSTFLAGS"
  '
  cd #{build_dir}
  nice make install

  echo '#!/bin/sh
export PATH=#{with_gcc}/bin:$PATH
export LD_LIBRARY_PATH=#{with_gcc}/lib64:$LD_LIBRARY_PATH
#{prefix}/bin/rustc "$@"
  ' > #{prefix}/bin/run-rustc.sh
  chmod +x #{prefix}/bin/run-rustc.sh

  SH
end

# test building
bash 'test building rust-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/rustc'}"
end
