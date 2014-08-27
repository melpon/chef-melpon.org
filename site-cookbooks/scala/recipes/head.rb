include_recipe 'heads'

$build_user = 'heads'
$build_home = '/home/' + $build_user
$build_dir = $build_home + '/scala'

bash 'git clone scala' do
  action :run
  user $build_user
  cwd $build_home
  code "git clone https://github.com/scala/scala.git scala"
  not_if "test -d #{$build_home + '/scala'}"
end

def install_scala(branch, prefix, build_sh)
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

        nice ant build-opt
      '
      cd #{$build_dir}
      rm -r #{prefix} || /bin/true
      cp -r build/pack #{prefix}
      chown -R root:root #{prefix}

      echo "
for cls in \\`ls *.class\\`; do
  /usr/bin/javap \\$cls | grep 'public static void main(java.lang.String\\[\\])' > /dev/null 2>&1
  if [ \\$? -eq 0 ]; then
    #{prefix}/bin/scala \\$@ \\${cls%.*}
    exit \\$?
  fi
done
echo 'The program compiled successfully, but main class was not found.' >&2
echo 'Main class should contain method: public static void main (String[] args).' >&2
exit 1
      " > #{prefix}/bin/run.sh
      chmod +x #{prefix}/bin/run.sh
      SH
    end

    # test building
    bash "test building scala #{branch} branch" do
      action :run
      user 'root'
      code build_sh
      not_if "test -d #{prefix + '/bin'}"
    end
end

install_scala(
    '2.12.x',
    '/usr/local/scala-2.12.x',
    $build_home + '/build/scala-2.12.x.sh')

install_scala(
    '2.11.x',
    '/usr/local/scala-2.11.x',
    $build_home + '/build/scala-2.11.x.sh')
