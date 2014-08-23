include_recipe 'heads'

$build_user = 'heads'
$build_home = '/home/' + $build_user
$build_dir = $build_home + '/scala'

def install_scala(tag, prefix)
    bash "git clone scala-#{tag}" do
      action :run
      user 'root'
      group 'root'
      cwd "#{Chef::Config[:file_cache_path]}"
      code "git clone https://github.com/scala/scala.git scala"
      not_if "test -d #{prefix + '/bin'}"
    end

    bash "build scala-#{tag}" do
      action :run
      user 'root'
      group 'root'
      code <<-SH
        set -ex
        cd #{Chef::Config[:file_cache_path]}/scala
        git checkout #{tag}
        nice ant build-opt
        rm -r #{prefix}
        cp -r build/pack #{prefix}
      SH
      not_if "test -d #{prefix + '/bin'}"
    end

    file "#{prefix}/bin/run.sh" do
      mode '0755'
      user 'root'
      group 'root'
      content <<-SH
        for cls in `ls *.class`; do
          /usr/bin/javap $cls | grep 'public static void main(java.lang.String\\[\\])' > /dev/null 2>&1
          if [ $? -eq 0 ]; then
            #{prefix}/bin/scala ${cls%.*} "$@"
            exit $?
          fi
        done
        echo "The program compiled successfully, but main class was not found." >&2
        echo "Main class should contain method: public static void main (String[] args)." >&2
        exit 1
      SH
    end
end

install_scala(
    'v2.11.2',
    '/usr/local/scala-2.11.2')
