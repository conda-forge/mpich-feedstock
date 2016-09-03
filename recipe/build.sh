#!/bin/bash

if [ "$(uname)" == "Darwin" ]
then
    export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib
fi

export LIBRARY_PATH="${PREFIX}/lib"

./configure --prefix=$PREFIX \
            --enable-shared \
            --enable-fortran=yes

make
make testing
make install

cp $RECIPE_DIR/license.txt $SRC_DIR/license.txt
