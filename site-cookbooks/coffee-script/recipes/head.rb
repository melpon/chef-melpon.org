include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/coffee-script'
prefix = '/usr/local/coffee-script-head'
build_sh = build_home + '/build/coffee-script.sh'

npm = '/usr/local/node-0.10.24/bin/npm'

bash 'install coffee-script HEAD' do
  action :run
  code <<-SH
    set -ex
    git clone https://github.com/jashkenas/coffee-script.git #{prefix}
    cd #{prefix}
    #{npm} install
  SH
  not_if "test -e #{prefix}/bin/coffee"
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
    cd #{prefix}
    git pull
    rm -r node_modules
    #{npm} install
  SH
end

# test building
bash 'test building coffee-script-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -d #{prefix + '/node_modules'}"
end
