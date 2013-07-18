include_recipe 'build-essential'
include_recipe 'gcc::depends'
include_recipe 'git'

build_user = 'gccbuilder'
build_home = '/home/' + build_user
build_sh = build_home + '/build.sh'
build_gcc = build_home + '/gcc'
build_dir = build_home + '/build'
git_repo = node['gcc_head']['repository']

user build_user do
  action :create
  home build_home
  supports :manage_home => true
  shell '/bin/bash'
end

# Download from: https://gist.github.com/mikesmullin/5660466
# monkey-patch Chef Git Provider
# to raise the default ShellOut timeout setting
# because this repo can take over 10min
# to clone from github.com
class ::Chef::Provider::Git
  def clone # based on opscode/chef commit b86c5b06
    converge_by("clone from #{@new_resource.repository} into #{@new_resource.destination}") do
      remote = @new_resource.remote

      args = []
      args << "-o #{remote}" unless remote == 'origin'
      args << "--depth #{@new_resource.depth}" if @new_resource.depth

      timeout = 100000 # i believe these are seconds

      Chef::Log.info "#{@new_resource} cloning repo #{@new_resource.repository} to #{@new_resource.destination} with timeout #{timeout}"

      clone_cmd = "git clone #{args.join(' ')} #{@new_resource.repository} #{Shellwords.escape @new_resource.destination}"
      shell_out!(clone_cmd, run_options(:log_level => :info, :timeout => timeout))
    end
  end
end

git build_gcc do
  repository git_repo
  action :sync
  user build_user
  group build_user
end

file build_sh do
  mode '0755'
  user 'root'
  group 'root'
  content <<-SH
  set -e
  cd #{build_gcc}
  sudo -u #{build_user} git checkout master
  sudo -u #{build_user} git pull --rebase

  sudo -u #{build_user} rm -rf #{build_dir}
  sudo -u #{build_user} mkdir #{build_dir}
  cd #{build_dir}

  sudo -u #{build_user} #{build_gcc}/configure --prefix=#{node['gcc_head']['prefix']} #{node['gcc_head']['flags']}
  sudo -u #{build_user} nice make -j2
  make install
  SH
end

# build gcc-head every day
cron 'update_gcc_head' do
  action :create
  minute '0'
  hour '4'
  command build_sh
end

# test building
bash 'test building gcc-head' do
  action :run
  user 'root'
  code build_sh
  not_if "test -e #{node['gcc_head']['prefix'] + '/bin/gcc'}"
end
