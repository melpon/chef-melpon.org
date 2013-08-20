include_recipe "build-essential"

def install_boost(source, file, build_dir, prefix, bjam_flags, update_profile)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode "0644"
    action :create_if_missing
    not_if "test -d #{prefix}/include/boost"
  end

  bash "install-boost" do
    user "root"
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
    set -e
    tar xf #{file}
    cd #{build_dir}
    ./bootstrap.sh
    ./bjam install --prefix=#{prefix} #{bjam_flags} > /dev/null
    cd ../
    rm -r #{build_dir}
    EOH
    not_if "test -d #{prefix}/include/boost"
  end

  if update_profile then
    file "/etc/profile.d/boost.sh" do
      mode "0755"
      content <<-SH
        export LIBRARY_PATH=#{prefix}/lib:$LIBRARY_PATH
        export LD_LIBRARY_PATH=#{prefix}/lib:$LD_LIBRARY_PATH
        export CPLUS_INCLUDE_PATH=#{prefix}/include:$CPLUS_INCLUDE_PATH
      SH
    end
  end
end

install_boost(
  'http://sourceforge.net/projects/boost/files/boost/1.47.0/',
  'boost_1_47_0.tar.gz',
  'boost_1_47_0',
  '/usr/local/boost-1.47.0',
  '--with-system --with-program_options',
  false)
install_boost(
  'http://sourceforge.net/projects/boost/files/boost/1.54.0/',
  'boost_1_54_0.tar.gz',
  'boost_1_54_0',
  '/usr/local/boost-1.54.0',
  '--with-system --with-program_options',
  false)
