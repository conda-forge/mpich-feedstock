#!/bin/bash

if [ $(uname) == Darwin ]; then
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
fi

export LIBRARY_PATH="$PREFIX/lib"

./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            --enable-cxx \
            --enable-fortran

make -j"${CPU_COUNT:-1}"
make install
