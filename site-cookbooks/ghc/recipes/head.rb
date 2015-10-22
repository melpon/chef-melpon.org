include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/ghc'
# WARNING: use this command: "rm -rf #{prefix}"
prefix = '/usr/local/ghc-head'
build_sh = build_home + '/build/ghc.sh'

with_ghc = '/usr/local/ghc-7.8.3/bin/ghc'

bash 'git clone ghc' do
  action :run
  user 'root'
  code <<-SH
    set -ex
    su - #{build_user} -c '
      set -ex
      git clone https://github.com/ghc/ghc.git
      cd ghc
      git checkout master
      cabal update
      cabal install cabal-dev
    '
  SH
  not_if "test -d #{build_home + '/ghc'}"
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
    git submodule foreach git clean -xdqf
    git reset --hard master
    git pull
    git clean -xdqf
    git submodule update -i

    cabal update

    export PATH=#{build_home}/.cabal/bin:$PATH
    cabal-dev install alex happy

    export PATH=#{build_dir}/cabal-dev/bin:$PATH
    ./boot
    ./configure --prefix=#{prefix} --with-ghc=#{with_ghc}
    nice make -j3
  '
  cd #{build_dir}
  rm -rf #{prefix}
  nice make install
  SH
end

# test building
bash 'test building ghc-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -d #{prefix + '/bin'}"
end
