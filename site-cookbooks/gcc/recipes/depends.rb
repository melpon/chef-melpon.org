

url = "http://ftp.gnu.org/gnu/gmp/"
file = "gmp-5.1.2.tar.bz2"
build_dir = "gmp-5.1.2"
prefix = "/usr/local"
lib = "gmp"

remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
  source url + file
  mode "0644"
  action :create_if_missing
  not_if "test -e #{prefix}/lib/lib#{lib}.a"
end

bash "install-#{build_dir}" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  set -e
  tar xf #{file}
  cd #{build_dir}
  ./configure --prefix=#{prefix}
  make install
  cd ../
  rm -r #{build_dir}
  EOH
  not_if "test -e #{prefix}/lib/lib#{lib}.a"
end


url = "http://www.mpfr.org/mpfr-current/"
file = "mpfr-3.1.2.tar.gz"
build_dir = "mpfr-3.1.2"
prefix = "/usr/local"
lib = "mpfr"

remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
  source url + file
  mode "0644"
  action :create_if_missing
  not_if "test -e #{prefix}/lib/lib#{lib}.a"
end

bash "install-#{build_dir}" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  set -e
  tar xf #{file}
  cd #{build_dir}
  ./configure --prefix=#{prefix}
  make install
  cd ../
  rm -r #{build_dir}
  EOH
  not_if "test -e #{prefix}/lib/lib#{lib}.a"
end

url = "http://www.multiprecision.org/mpc/download/"
file = "mpc-1.0.1.tar.gz"
build_dir = "mpc-1.0.1"
prefix = "/usr/local"
lib = "mpc"

remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
  source url + file
  mode "0644"
  action :create_if_missing
  not_if "test -e #{prefix}/lib/lib#{lib}.a"
end

bash "install-#{build_dir}" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  set -e
  tar xf #{file}
  cd #{build_dir}
  ./configure --prefix=#{prefix}
  make install
  cd ../
  rm -r #{build_dir}
  EOH
  not_if "test -e #{prefix}/lib/lib#{lib}.a"
end

