#!/bin/bash
set -exuo pipefail

export HYDRA_LAUNCHER=fork
MPIEXEC="${PWD}/mpiexec.sh"

pushd "tests"

if [[ $PKG_NAME == "mpich" ]]; then
  command -v mpichversion
  mpichversion

  test -f $PREFIX/lib/libmpi${SHLIB_EXT}
  test ! -f $PREFIX/lib/libmpi.a

  command -v mpiexec
  $MPIEXEC -n 1 mpivars
  $MPIEXEC -n 4 ./helloworld.sh

  mpichversion | grep ofi
  if [[ "${target_platform}" = linux-* && "${target_platform}" != linux-ppc64le ]]; then
    mpichversion | grep ucx
  fi

  mpicc $CFLAGS $LDFLAGS helloworld.c -o helloworld_c

  # verify netmods
  # these debug flags let us identify which netmod is loaded
  export MPICH_CH4_UCX_CAPABILITY_DEBUG=1
  export MPICH_CH4_OFI_CAPABILITY_DEBUG=1
  # default is OFI (set by order in --with-device)
  out=$($MPIEXEC -n 4 ./helloworld_c)
  echo "$out" | grep OFI
  if echo "$out" | grep UCX; then
    exit 1
  fi

  # explicit OFI
  export MPICH_CH4_NETMOD=ofi
  out=$($MPIEXEC -n 4 ./helloworld_c)
  echo "$out" | grep OFI
  if echo "$out" | grep UCX; then
    exit 1
  fi
  if [[ "${target_platform}" = linux-* && "${target_platform}" != linux-ppc64le ]]; then
    # explicit UCX
    export MPICH_CH4_NETMOD=ucx
    out=$($MPIEXEC -n 4 ./helloworld_c)
    echo "$out" | grep UCX
    if echo "$out" | grep OFI; then
      exit 1
    fi
  fi
fi

if [[ $PKG_NAME == "mpich-mpicc" ]]; then
  command -v mpicc
  mpicc -show

  mpicc $CFLAGS $LDFLAGS helloworld.c -o helloworld_c
  $MPIEXEC -n 4 ./helloworld_c
fi

if [[ $PKG_NAME == "mpich-mpicxx" ]]; then
  command -v mpicxx
  mpicxx -show

  mpicxx $CXXFLAGS $LDFLAGS helloworld.cxx -o helloworld_cxx
  $MPIEXEC -n 4 ./helloworld_cxx
fi

if [[ $PKG_NAME == "mpich-mpifort" ]]; then
  command -v mpifort
  mpifort -show

  mpifort $FFLAGS $LDFLAGS helloworld.f -o helloworld1_f
  $MPIEXEC -n 4 ./helloworld1_f

  mpifort $FFLAGS $LDFLAGS helloworld.f90 -o helloworld1_f90
  $MPIEXEC -n 4 ./helloworld1_f90

  mpifort $FFLAGS $LDFLAGS helloworld.f08 -o helloworld1_f08
  $MPIEXEC -n 4 ./helloworld1_f08

  command -v mpif77
  mpif77 -show

  mpif77 $FFLAGS $LDFLAGS helloworld.f -o helloworld2_f
  $MPIEXEC -n 4 ./helloworld2_f

  command -v mpif90
  mpif90 -show

  mpif90 $FFLAGS $LDFLAGS helloworld.f90 -o helloworld2_f90
  $MPIEXEC -n 4 ./helloworld2_f90

fi

popd
