include_recipe 'heads'

$build_user = 'heads'
$build_home = '/home/' + $build_user
$build_dir = $build_home + '/erlang'

bash 'git clone erlang' do
  action :run
  user $build_user
  cwd $build_home
  code "git clone https://github.com/erlang/otp.git erlang"
  not_if "test -d #{$build_home + '/erlang'}"
end

def install_erlang(branch, prefix, build_sh)
    file build_sh do
      mode '0755'
      user 'root'
      group 'root'
      content <<-SH
      set -ex
      su - #{$build_user} -c '
        set -ex
        cd #{$build_dir}
        git clean -xdqf
        git checkout #{branch}
        git clean -xdqf
        git reset --hard
        git pull --rebase

        ./otp_build autoconf
        ./configure --prefix=#{prefix}
        nice make
      '
      cd #{$build_dir}
      nice make install
      SH
    end

    # test building
    bash "test building erlang #{branch} branch" do
      action :run
      user 'root'
      code build_sh
      not_if "test -d #{prefix + '/bin'}"
    end
end

install_erlang(
    'master',
    '/usr/local/erlang-head',
    $build_home + '/build/erlang-head.sh')
install_erlang(
    'maint',
    '/usr/local/erlang-maint',
    $build_home + '/build/erlang-maint.sh')
