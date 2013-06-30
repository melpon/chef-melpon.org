include_recipe "build-essential"
include_recipe "gcc::depends"

remote_file "#{Chef::Config[:file_cache_path]}/#{node.gcc.file}" do
  source node.gcc.source + node.gcc.file
  mode "0644"
  action :create_if_missing
  not_if "test -d #{node.gcc.prefix}"
end

bash "install-gcc" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  cd #{Chef::Config[:file_cache_path]}
  tar xf #{node.gcc.file}

  set -e
  mkdir #{node.gcc.build_dir}_build
  cd #{node.gcc.build_dir}_build

  ../#{node.gcc.build_dir}/configure --prefix=#{node.gcc.prefix} #{node.gcc.gcc_flags}
  make -j2 >log 2>err
  make install

  cd ../
  rm -r #{node.gcc.build_dir}_build
  rm -r #{node.gcc.build_dir}
  EOH
  not_if "test -d #{node.gcc.prefix}"
end
