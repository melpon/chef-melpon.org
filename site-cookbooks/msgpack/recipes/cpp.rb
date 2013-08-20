
include_recipe 'ruby_build'

ruby_build_ruby '1.8.7-p374' do
  action :install
  prefix_path "/usr/local"
end

git "#{Chef::Config[:file_cache_path]}/msgpack-c" do
  repository 'https://github.com/msgpack/msgpack-c.git'
  action :sync
  not_if "test -e /usr/local/lib/libmsgpack.so"
end

bash 'build msgpack' do
  action :run

  cwd "#{Chef::Config[:file_cache_path]}/msgpack-c"
  code <<-SH
    ./bootstrap
    ./configure --prefix=/usr/local
    make
    sudo make install
  SH

  not_if "test -e /usr/local/lib/libmsgpack.so"
end

git "#{Chef::Config[:file_cache_path]}/mpio" do
  repository 'https://github.com/frsyuki/mpio.git'
  action :sync
  not_if "test -e /usr/local/lib/libmpio.so"
end

bash 'build mpio' do
  action :run

  cwd "#{Chef::Config[:file_cache_path]}/mpio"
  code <<-SH
    ./bootstrap
    ./configure --prefix=/usr/local
    make
    sudo make install
  SH

  not_if "test -e /usr/local/lib/libmpio.so"
end

git "#{Chef::Config[:file_cache_path]}/msgpack-rpc-cpp" do
  repository 'https://github.com/msgpack-rpc/msgpack-rpc-cpp.git'
  action :sync
  not_if "test -e /usr/local/lib/libmsgpack-rpc.so"
end

bash 'build msgpack-rpc-cpp' do
  action :run

  cwd "#{Chef::Config[:file_cache_path]}/msgpack-rpc-cpp"
  code <<-SH
    ./bootstrap
    ./configure --prefix=/usr/local
    make
    sudo make install
  SH

  not_if "test -e /usr/local/lib/libmsgpack-rpc.so"
end
