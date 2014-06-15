
include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/elixir'
prefix = '/usr/local/elixir-head'
build_sh = build_home + '/build/elixir.sh'
erlang_prefix = '/usr/local/erlang-17.0'

bash 'git clone elixir' do
  action :run
  user 'root'
  cwd build_home
  code <<-SH
    su - #{build_user} -c '
      git clone https://github.com/elixir-lang/elixir.git #{build_dir}
      cd #{build_dir}
      git checkout master
    '
  SH
  not_if "test -d #{build_dir}"
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
    git pull
    git clean -xdqf

    sed -e "s#PREFIX := /usr/local#PREFIX := #{prefix}#" Makefile > Makefile.tmp
    mv Makefile.tmp Makefile

    PATH=#{erlang_prefix}/bin:$PATH make clean test
  '
  cd #{build_dir}
  PATH=#{erlang_prefix}/bin:$PATH make install
  echo '#!/bin/bash
PATH=#{erlang_prefix}/bin:$PATH #{prefix}/bin/elixir "$@"' > #{prefix}/bin/run.sh
  chmod +x #{prefix}/bin/run.sh
  SH
end

# test building
bash 'test building elixir-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/elixir'}"
end
