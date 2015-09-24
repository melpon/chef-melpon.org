include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/msgpack'
prefix = '/usr/local/msgpack-head'
build_sh = build_home + '/build/msgpack.sh'

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
    set -ex
    su - #{build_user} -c '
      mkdir #{build_dir}
      rm -rf #{build_dir}/msgpack-c
      set -ex
      cd #{build_dir}
      git clone https://github.com/msgpack/msgpack-c.git
    '
    set +e
    mkdir #{prefix}
    rm -r #{prefix}/include
    set -e
    cp -r #{build_dir}/msgpack-c/include #{prefix}/include
  SH
end

# test building
bash 'test building msgpack-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -d #{prefix + '/include'}"
end
