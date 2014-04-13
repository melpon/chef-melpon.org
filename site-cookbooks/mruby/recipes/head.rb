include_recipe 'heads'

build_user = 'heads'
build_home = '/home/' + build_user
build_dir = build_home + '/mruby'
prefix = '/usr/local/mruby-head'
build_sh = build_home + '/build/mruby.sh'

#ruby = '/usr/local/ruby-2.0.0-p247/bin/ruby'
ruby = 'ruby'

bash 'git clone mruby' do
  action :run
  user build_user
  cwd build_home
  code <<-SH
    git clone https://github.com/mruby/mruby.git #{build_dir}
    cd #{build_dir}
    git checkout master
  SH
  not_if "test -d #{build_dir}"
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
    git clean -dqxf
    git reset --hard
    git pull
    git clean -dqxf

    nice #{ruby} ./minirake
  '
  rm -rf #{prefix} || true
  cp -r #{build_dir} #{prefix}
  SH
end

# test building
bash 'test building mruby-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{prefix + '/bin/mruby'}"
end
