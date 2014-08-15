include_recipe "build-essential"


%w{
  python-dev
  libbz2-dev
  zlib1g-dev
}.each do |pc|
  package pc do
    action :install
  end
end

def install_boost(source, file, build_dir, prefix, bjam_flags, update_profile)
  remote_file "#{Chef::Config[:file_cache_path]}/#{file}" do
    source source + file
    mode "0644"
    action :create_if_missing
    not_if "test -d #{prefix}/include/boost"
  end

  bash "install-boost #{build_dir}" do
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
  '--without-mpi',
  false)
install_boost(
  'http://sourceforge.net/projects/boost/files/boost/1.48.0/',
  'boost_1_48_0.tar.gz',
  'boost_1_48_0',
  '/usr/local/boost-1.48.0',
  '--without-mpi',
  false)
install_boost(
  'http://sourceforge.net/projects/boost/files/boost/1.49.0/',
  'boost_1_49_0.tar.gz',
  'boost_1_49_0',
  '/usr/local/boost-1.49.0',
  '--without-mpi',
  false)
install_boost(
  'http://sourceforge.net/projects/boost/files/boost/1.50.0/',
  'boost_1_50_0.tar.gz',
  'boost_1_50_0',
  '/usr/local/boost-1.50.0',
  '--without-mpi',
  false)
install_boost(
  'http://sourceforge.net/projects/boost/files/boost/1.51.0/',
  'boost_1_51_0.tar.gz',
  'boost_1_51_0',
  '/usr/local/boost-1.51.0',
  '--without-mpi',
  false)
install_boost(
  'http://sourceforge.net/projects/boost/files/boost/1.52.0/',
  'boost_1_52_0.tar.gz',
  'boost_1_52_0',
  '/usr/local/boost-1.52.0',
  '--without-mpi',
  false)
install_boost(
  'http://sourceforge.net/projects/boost/files/boost/1.53.0/',
  'boost_1_53_0.tar.gz',
  'boost_1_53_0',
  '/usr/local/boost-1.53.0',
  '--without-mpi',
  false)
install_boost(
  'http://sourceforge.net/projects/boost/files/boost/1.54.0/',
  'boost_1_54_0.tar.gz',
  'boost_1_54_0',
  '/usr/local/boost-1.54.0',
  '--without-mpi',
  false)
install_boost(
  'http://sourceforge.net/projects/boost/files/boost/1.55.0/',
  'boost_1_55_0.tar.gz',
  'boost_1_55_0',
  '/usr/local/boost-1.55.0',
  '--without-mpi',
  false)
install_boost(
  'http://sourceforge.net/projects/boost/files/boost/1.56.0/',
  'boost_1_56_0.tar.gz',
  'boost_1_56_0',
  '/usr/local/boost-1.56.0',
  '--without-mpi',
  false)
