default['gcc']['source'] = "http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.7.3/"
default['gcc']['file'] = "gcc-4.7.3.tar.gz"
default['gcc']['build_dir'] = "gcc-4.7.3"
default['gcc']['prefix'] = "/usr/local/gcc-4.7.3"
default['gcc']['gcc_flags'] = "--enable-languages=c,c++ --enable-lto --disable-multilib --without-ppl --without-cloog-ppl --enable-checking=release --disable-nls"

default['gcc-head']['prefix'] = "/usr/local/gcc-head"
default['gcc-head']['flags'] = "--enable-languages=c,c++ --enable-lto --disable-multilib --without-ppl --without-cloog-ppl --enable-checking=release --disable-nls"
