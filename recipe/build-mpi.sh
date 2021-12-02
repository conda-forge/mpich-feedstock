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

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 && $target_platform == osx-arm64 ]]; then
    export FFLAGS=$FFLAGS" -fallow-argument-mismatch"
    export pac_cv_f77_accepts_F=yes
    export pac_cv_f77_flibs_valid=unknown
    export pac_cv_f77_sizeof_double_precision=8
    export pac_cv_f77_sizeof_integer=4
    export pac_cv_f77_sizeof_real=4
    export pac_cv_fc_accepts_F90=yes
    export pac_cv_fc_and_f77=yes
    export pac_cv_fc_module_case=lower
    export pac_cv_fc_module_ext=mod
    export pac_cv_fc_module_incflag=-I
    export pac_cv_fc_module_outflag=-J
    export pac_cv_fort90_real8=yes
    export pac_cv_fort_integer16=yes
    export pac_cv_fort_integer1=yes
    export pac_cv_fort_integer2=yes
    export pac_cv_fort_integer4=yes
    export pac_cv_fort_integer8=yes
    export pac_cv_fort_real16=no
    export pac_cv_fort_real4=yes
    export pac_cv_fort_real8=yes
    export pac_cv_prog_f77_and_c_stdio_libs=none
    export pac_cv_prog_f77_exclaim_comments=yes
    export pac_cv_prog_f77_has_incdir=-I
    export pac_cv_prog_f77_library_dir_flag=-L
    export pac_cv_prog_f77_mismatched_args=yes
    export pac_cv_prog_f77_mismatched_args_parm=
    export pac_cv_prog_f77_name_mangle='lower uscore'
    export CROSS_F77_TRUE_VALUE=1
    export CROSS_F77_FALSE_VALUE=0
    export pac_cv_prog_fc_and_c_stdio_libs=none
    export pac_cv_prog_fc_int_kind_16=8
    export pac_cv_prog_fc_int_kind_8=4
    export pac_cv_prog_fc_works=yes
    export CROSS_F90_ADDRESS_KIND=8
    export CROSS_F90_OFFSET_KIND=8
    export CROSS_F90_INTEGER_KIND=4
    export CROSS_F90_SIZEOF_INTEGER=4
    export CROSS_F90_SIZEOF_REAL=4
    export CROSS_F90_SIZEOF_DOUBLE_PRECISION=8
    export CROSS_F90_REAL_MODEL=' 6 , 37'
    export CROSS_F90_DOUBLE_MODEL=' 15 , 307'
    export CROSS_F90_INTEGER_MODEL=' 9'
    export CROSS_F90_ALL_INTEGER_MODELS=' 2 , 1, 4 , 2, 9 , 4, 18 , 8,'
    export CROSS_F90_INTEGER_MODEL_MAP=' {  2 , 1 , 1 }, {  4 , 2 , 2 }, {  9 , 4 , 4 }, {  18 , 8 , 8 },'
    export pac_MOD='mod'
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
            --disable-wrapper-rpath \
            --disable-opencl \
            --with-device=ch3

make -j"${CPU_COUNT:-1}"
make install
