#!/bin/bash

# configure balks if F90 is defined
# with a fatal deprecation message pointing to FC
unset F90 F77

if [ $(uname) == Darwin ]; then
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
fi

# avoid absolute-paths in compilers
export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

# from anaconda recipe, not sure if it matters
export FCFLAGS="$FFLAGS"

export LIBRARY_PATH="$PREFIX/lib"

./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            --enable-cxx \
            --enable-fortran

make -j"${CPU_COUNT:-1}"
make install
