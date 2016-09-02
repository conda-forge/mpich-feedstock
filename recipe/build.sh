#!/bin/bash

if [[ $(uname) == Linux ]]; then
  # FIXME: This is a terrible workaround.
  # Ideally we should fix the information the .la files.
  rm -rf $PREFIX/lib/libquadmath.la
  rm -rf $PREFIX/lib/libgfortran.la
fi

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
