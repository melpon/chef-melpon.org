include_recipe 'heads'

package 'tcl' do
  action :install
end

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/sqlite'
prefix = '/usr/local/sqlite-head'
build_sh = build_home + '/build/sqlite.sh'

bash 'fossil clone sqlite' do
  action :run
  user 'root'
  cwd build_home
  code <<-SH
    su - #{build_user} -c '
      mkdir -p #{build_dir}
      fossil clone http://www.sqlite.org/cgi/src #{build_dir + '/sqlite.fossil'}
    '
  SH
  not_if "test -e #{build_dir + '/sqlite.fossil'}"
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
    rm -rf build || true
    rm -rf source || true
    fossil pull --repository sqlite.fossil
    mkdir source
    mkdir build

    cd source
    fossil open ../sqlite.fossil

    cd ../build
    ../source/configure --prefix=#{prefix}
    nice make
  '
  cd #{build_dir + '/build'}
  nice make install
  SH
end

# test building
bash 'test building sqlite-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -d #{prefix + '/bin'}"
end
