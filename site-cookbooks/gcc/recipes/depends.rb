

def install(url, file, build_dir, prefix, lib)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source url + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/lib/lib#{lib}.a"
  end
  
  bash "install-#{build_dir}" do
    user 'root'
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
end


url = 'http://ftp.gnu.org/gnu/gmp/'
file = 'gmp-5.1.2.tar.bz2'
build_dir = 'gmp-5.1.2'
prefix = '/usr'
lib = 'gmp'
install(url, file, build_dir, prefix, lib)


url = 'http://www.mpfr.org/mpfr-current/'
file = 'mpfr-3.1.2.tar.gz'
build_dir = 'mpfr-3.1.2'
prefix = '/usr'
lib = 'mpfr'
install(url, file, build_dir, prefix, lib)


url = 'http://www.multiprecision.org/mpc/download/'
file = 'mpc-1.0.1.tar.gz'
build_dir = 'mpc-1.0.1'
prefix = '/usr'
lib = 'mpc'
install(url, file, build_dir, prefix, lib)


package 'gcc-multilib' do
  action :install
end

bash 'symbolic link to lib64' do
  user 'root'
  code 'ln -s /usr/lib/x86_64-linux-gnu /usr/lib64'
  not_if "test -e /usr/lib64"
end
