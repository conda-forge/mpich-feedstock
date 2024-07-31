#!/bin/bash

# configure balks if F90 is defined
# with a fatal deprecation message pointing to FC
unset F90 F77

export FCFLAGS="$FFLAGS"

# avoid absolute-paths in compilers
export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 && $target_platform == osx-arm64 ]]; then
    # use Conda-Forge's Arm64 config.guess and config.sub, see
    # https://conda-forge.org/blog/posts/2020-10-29-macos-arm64/
    list_config_to_patch=$(find ./ -name config.guess | sed -E 's/config.guess//')
    for config_folder in $list_config_to_patch; do
        echo "copying config to $config_folder ...\n"
        cp -v $BUILD_PREFIX/share/gnuconfig/config.* $config_folder
    done

    ./autogen.sh
fi

if [[ "$target_platform" == "linux-ppc64le" ]]; then
    # Fix symbol relocation errors
    export CFLAGS="$CFLAGS -fplt"
    export CXXFLAGS="$CXXFLAGS -fplt"
fi

if [[ "$target_platform" == osx-* ]]; then
  # Add gfortran internal header to clang include dir
  fcdir=$($FC -print-search-dirs | awk '/install: /{print $2}')
  ccdir=$($CC -print-search-dirs | awk '/libraries: =/{print substr($2,2)}')
  cp ${fcdir}/include/ISO_Fortran_binding.h ${ccdir}/include
fi

# avoid recording flags in compilers
# See Compiler Flags section of MPICH readme
# TODO: configure ignores MPICHLIB_LDFLAGS
export MPICHLIB_CPPFLAGS=$CPPFLAGS
unset CPPFLAGS
export MPICHLIB_CFLAGS=$CFLAGS
unset CFLAGS
export MPICHLIB_CXXFLAGS=$CXXFLAGS
unset CXXFLAGS
export MPICHLIB_LDFLAGS=$LDFLAGS
unset LDFLAGS
export MPICHLIB_FFLAGS=$FFLAGS
unset FFLAGS
export MPICHLIB_FCFLAGS=$FCFLAGS
unset FCFLAGS

# set some specific flags that we *do* want recorded in the compilers
# only the bare minimum of prefix-awareness here
export CPPFLAGS="-I$PREFIX/include"
export CFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export FFLAGS="-I$PREFIX/include"
export FCFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

export LIBRARY_PATH="$PREFIX/lib"

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  if [[ "$target_platform" == "osx-arm64" || "$target_platform" == "linux-aarch64" || "$target_platform" == "linux-ppc64le" ]]; then
    export CROSS_F77_SIZEOF_INTEGER=4
    export CROSS_F77_SIZEOF_REAL=4
    export CROSS_F77_SIZEOF_DOUBLE_PRECISION=8
    export CROSS_F77_SIZEOF_LOGICAL=4
    export CROSS_F77_TRUE_VALUE=1
    export CROSS_F77_FALSE_VALUE=0
    export CROSS_F90_ADDRESS_KIND=8
    export CROSS_F90_OFFSET_KIND=8
    export CROSS_F90_INTEGER_KIND=4
    export CROSS_F90_REAL_MODEL=' 6 , 37'
    export CROSS_F90_DOUBLE_MODEL=' 15 , 307'
    export CROSS_F90_INTEGER_MODEL=' 9'
    export CROSS_F90_ALL_INTEGER_MODELS=' 2 , 1, 4 , 2, 9 , 4, 18 , 8,'
    export CROSS_F90_INTEGER_MODEL_MAP=' {  2 , 1 , 1 }, {  4 , 2 , 2 }, {  9 , 4 , 4 }, {  18 , 8 , 8 },'
  else
    echo "Set CROSS_F77_* and CROSS_F90_* variables for cross compiling"
    exit 1
  fi
fi

if [[ "$target_platform" == linux-* ]]; then
    # On linux-aarch64 centos image there's also a /usr/bin/bash, but it's not
    # present in other OSes. /bin/bash is universal
    export BASH_SHELL="/bin/bash"
fi

./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            --enable-cxx \
            --enable-fortran \
            --enable-f08 \
            --with-wrapper-dl-type=none \
            --disable-opencl \
            --with-device=ch4 \
            || cat config.log

make -j"${CPU_COUNT:-1}"
make install
