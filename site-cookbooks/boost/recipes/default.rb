include_recipe "build-essential"

remote_file "#{Chef::Config[:file_cache_path]}/#{node.boost.file}" do
  source node.boost.source + node.boost.file
  mode "0644"
  action :create_if_missing
  not_if "test -d #{node.boost.prefix}"
end

bash "install-boost" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  set -e
  tar xf #{node.boost.file}
  cd #{node.boost.build_dir}
  ./bootstrap.sh
  ./bjam install --prefix=#{node.boost.prefix} #{node.boost.bjam_flags} > /dev/null
  cd ../
  rm -r #{node.boost.build_dir}
  EOH
  not_if "test -d #{node.boost.prefix}"
end

if node.boost.update_profile then
  file "/etc/profile.d/boost.sh" do
    mode "0755"
    content <<-SH
      export LIBRARY_PATH=#{node.boost.prefix}/lib:$LIBRARY_PATH
      export LD_LIBRARY_PATH=#{node.boost.prefix}/lib:$LD_LIBRARY_PATH
      export CPLUS_INCLUDE_PATH=#{node.boost.prefix}/include:$CPLUS_INCLUDE_PATH
    SH
  end
end
