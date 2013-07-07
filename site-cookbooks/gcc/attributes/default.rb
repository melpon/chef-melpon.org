default['gcc_list'] = [
  {
    'source' => 'http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.8.1/',
    'file' => 'gcc-4.8.1.tar.gz',
    'build_dir' => 'gcc-4.8.1',
    'prefix' => '/usr/local/gcc-4.8.1',
    'flags' => '--enable-languages=c,c++ --enable-lto --disable-multilib --without-ppl --without-cloog-ppl --enable-checking=release --disable-nls',
  },{
    'source' => 'http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.7.3/',
    'file' => 'gcc-4.7.3.tar.gz',
    'build_dir' => 'gcc-4.7.3',
    'prefix' => '/usr/local/gcc-4.7.3',
    'flags' => '--enable-languages=c,c++ --enable-lto --disable-multilib --without-ppl --without-cloog-ppl --enable-checking=release --disable-nls',
  },{
    'source' => 'http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.6.4/',
    'file' => 'gcc-4.6.4.tar.gz',
    'build_dir' => 'gcc-4.6.4',
    'prefix' => '/usr/local/gcc-4.6.4',
    'flags' => '--enable-languages=c,c++ --disable-multilib --without-ppl --without-cloog-ppl --enable-checking=release --disable-nls',
  },{
    'source' => 'http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.5.4/',
    'file' => 'gcc-4.5.4.tar.gz',
    'build_dir' => 'gcc-4.5.4',
    'prefix' => '/usr/local/gcc-4.5.4',
    'flags' => '--enable-languages=c,c++ --disable-multilib --without-ppl --without-cloog-ppl --enable-checking=release --disable-nls',
  },{
    'source' => 'http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.4.7/',
    'file' => 'gcc-4.4.7.tar.gz',
    'build_dir' => 'gcc-4.4.7',
    'prefix' => '/usr/local/gcc-4.4.7',
    'flags' => '--enable-languages=c,c++ --disable-multilib --without-ppl --without-cloog-ppl --enable-checking=release --disable-nls',
  },{
    'source' => 'http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.3.6/',
    'file' => 'gcc-4.3.6.tar.gz',
    'build_dir' => 'gcc-4.3.6',
    'prefix' => '/usr/local/gcc-4.3.6',
    'flags' => '--enable-languages=c,c++ --disable-multilib --without-ppl --without-cloog-ppl --enable-checking=release --disable-nls',
  }
]

default['gcc_head'] = {
  'repository' => 'git://gcc.gnu.org/git/gcc.git',
  'prefix' => '/usr/local/gcc-head',
  'flags' => '--enable-languages=c,c++ --enable-lto --disable-multilib --without-ppl --without-cloog-ppl --enable-checking=release --disable-nls',
}
