include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/rill'
prefix = '/usr/local/rill-head'
build_sh = build_home + '/build/rill.sh'

llvm_source = build_dir + '/llvm/source'
llvm_build = build_dir + '/llvm/build'
llvm_prefix = build_dir + '/llvm/llvm'

boost_build = build_dir + '/boost/build'
boost_prefix = build_dir + '/boost/boost'

rill_source = build_dir + '/rill/source'
rill_build = build_dir + '/rill/build'
rill_branch = 'develop'

run_rill_sh = build_dir + '/rill/run_rill.sh'

boost_root = boost_prefix
gcc_root = '/usr/local/gcc-4.8.2'

bash 'make llvm for rill' do
  action :run
  user build_user
  cwd build_home
  code <<-SH
    set -ex
    svn co http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_34/final #{llvm_source}
    svn co http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_34/final #{llvm_source}/tools/clang
    svn co http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_34/final #{llvm_source}/projects/compiler-rt

    rm -rf #{llvm_build} || true
    mkdir -p #{llvm_build}
    cd #{llvm_build}
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=#{llvm_prefix} #{llvm_source}
    nice make -j3
    nice make install
  SH
  not_if "test -d #{llvm_prefix + '/bin'}"
end

bash 'make boost for rill' do
  action :run
  user build_user
  cwd build_home
  code <<-SH
    set -ex
    rm -rf #{boost_build} || true
    mkdir -p #{boost_build}
    cd #{boost_build}
    wget 'http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz'
    tar xf boost_1_55_0.tar.gz
    cd boost_1_55_0
    nice ./bootstrap.sh
    PATH=/usr/local/gcc-4.8.2/bin:$PATH nice ./bjam install -sTOOLS=gcc --prefix=#{boost_prefix} --without-mpi
  SH
  not_if "test -d #{boost_prefix + '/include'}"
end

bash 'git clone rill' do
  action :run
  user build_user
  cwd build_home
  code <<-SH
    mkdir -p #{rill_source}
    git clone https://github.com/yutopp/rill.git #{rill_source}
    cd #{rill_source}
    git checkout #{rill_branch}
  SH
  not_if "test -d #{rill_source}"
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -ex
  su - #{build_user} -c '
    set -ex

    cd #{rill_source}
    git reset --hard
    git clean -xdqf
    git pull

    rm -rf #{rill_build} || true
    mkdir -p #{rill_build}
    cd #{rill_build}
    CC=#{gcc_root}/bin/gcc CXX=#{gcc_root}/bin/g++ cmake -DBOOST_ROOT=#{boost_root} -DLLVM_CONFIG_PATH=#{build_dir}/llvm/llvm/bin/llvm-config -DCMAKE_INSTALL_PREFIX=#{prefix} -DCMAKE_BUILD_TYPE=Release /home/heads/rill/rill/source
    nice make -j3
  '
  cd #{rill_build}
  nice make install

  cd #{rill_source}
  git rev-parse HEAD | cut -c 1-8 > #{prefix}/bin/version
  cp #{run_rill_sh} #{prefix}/bin
  SH
end

file run_rill_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
    LD_LIBRARY_PATH=#{boost_root}/lib:#{gcc_root}/lib64 #{prefix}/bin/rillc --rill-rt-lib-path=#{prefix}/lib/librill-rt.a "$@"
  SH
end

# test building
bash 'test building rill-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -d #{prefix + '/bin'}"
end
