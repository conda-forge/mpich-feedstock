#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib
    export CC=clang
    export CXX=clang++
    export MACOSX_DEPLOYMENT_TARGET="10.9"
    export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
    export CXXFLAGS="$CXXFLAGS -stdlib=libc++"
fi

export LIBRARY_PATH="${PREFIX}/lib"

./configure --prefix=$PREFIX \
            --enable-shared \
            --enable-fortran=yes

make
make testing
make install

cp $RECIPE_DIR/license.txt $SRC_DIR/license.txt
