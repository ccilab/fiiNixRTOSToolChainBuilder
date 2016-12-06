#!/bin/bash
. ./environ.sh
if [[ "$TARGET" == ""  || "$PREFIX" == "" ]] ; then
	echo "You need to set: TARGET and PREFIX"; exit 0;
fi
export PATH=$PATH:$PREFIX/$TARGET
# make sure build area is clean
rm -rf $PREFIX/newlib_build/*
(cd $PREFIX/newlib_build ; \
    ../newlib_sources/configure -v --quiet --target=$TARGET --prefix=$PREFIX \
    --disable-newlib-supplied-syscalls --enable-interwork --enable-multilib \
    --with-gnu-ld --with-gnu-as --disable-newlib-io-float \
   --disable-werror )
zcat downloads/newlib_makefile_patch.gz | patch -d $PREFIX/newlib_build -p0
# keep build quiet so we can see any stderr reports.
cat quiet $PREFIX/newlib_build/Makefile > $BUILDSOURCES/Makefile
mv $BUILDSOURCES/Makefile $PREFIX/newlib_build/Makefile
# note, make.log contains the stderr output of the build.
(cd $PREFIX/newlib_build ;  make all install 2>&1 | tee $BUILDSOURCES/make.log)
