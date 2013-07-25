include_recipe 'build-essential'
include_recipe 'gcc::depends'

def install_gcc(source, file, build_dir, prefix, flags)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode '0644'
    action :create_if_missing
    not_if "test -e #{prefix}/bin/gcc"
  end
  
  bash "install-#{build_dir}" do
    user 'root'
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
    tar xf #{file}
  
    set -e
    mkdir #{build_dir}_build
    cd #{build_dir}_build
  
    export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu
    ../#{build_dir}/configure --prefix=#{prefix} #{flags}
    make -j2 >log 2>err
    make install
  
    cd ../
    rm -r #{build_dir}_build
    rm -r #{build_dir}
    EOH
    not_if "test -e #{prefix}/bin/gcc"
  end
end

node['gcc_list'].each{|m|
  install_gcc(m['source'], m['file'], m['build_dir'], m['prefix'], m['flags'])
}
