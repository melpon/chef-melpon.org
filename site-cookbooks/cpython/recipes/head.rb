

include_recipe 'heads'

$build_user = 'heads'
$build_home = '/home/' + $build_user
$build_dir = $build_home + '/cpython'

bash 'hg clone cpython' do
  action :run
  user $build_user
  cwd $build_home
  code "hg clone http://hg.python.org/cpython/"
  not_if "test -d #{$build_home + '/cpython'}"
end

def install_cpython(branch, prefix, build_sh, venv_flags)
    file build_sh do
      mode '0755'
      user 'root'
      group 'root'
      content <<-SH
      set -ex
      su - #{$build_user} -c '
        set -ex
        cd #{$build_dir}
        hg purge --all
        hg update -c #{branch}
        hg pull -u

        virtualenv #{venv_flags} venv
        source venv/bin/activate

        ./configure --prefix=#{prefix}
        nice make
      '
      cd #{$build_dir}
      nice make install
      SH
    end

    # test building
    bash 'test building python-head' do
      action :run
      user 'root'
      code build_sh
      not_if "test -d #{prefix + '/bin'}"
    end
end

install_cpython(
    '2.7',
    '/usr/local/python-2.7-head',
    $build_home + '/build/python-2.7.sh',
    '')
install_cpython(
    'default',
    '/usr/local/python-head',
    $build_home + '/build/python.sh',
    '-p /usr/local/python-3.3.2/bin/python3')
