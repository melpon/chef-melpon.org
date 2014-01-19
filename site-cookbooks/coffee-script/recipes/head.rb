prefix = '/usr/local/coffee-script-head'
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

cron 'update_coffee-script_head' do
  action :create
  minute '0'
  hour '9'
  command "cd #{prefix}; git pull; rm -r node_modules; #{npm} install"
  mailto node['email']
end
