#!/bin/bash
set -exuo pipefail

export HYDRA_LAUNCHER=fork
MPIEXEC="mpiexec"

pushd "tests"

if [[ $PKG_NAME == "mpich" ]]; then
  command -v mpichversion
  mpichversion

  test -f $PREFIX/lib/libmpi${SHLIB_EXT}
  test ! -f $PREFIX/lib/libmpi.a

  command -v mpiexec
  command -v mpiexec.hydra
  command -v mpiexec.gforker

  $MPIEXEC -n 1 mpivars
  $MPIEXEC -n 4 ./helloworld.sh
fi

# verify OFI and UCX netmods
check_netmods()
{
  executable=$1

  # these debug flags let us identify which netmod is loaded
  export MPICH_CH4_UCX_CAPABILITY_DEBUG=1
  export MPICH_CH4_OFI_CAPABILITY_DEBUG=1

  check_ofi=yes
  check_ucx=no
  if [[ "$target_platform" == linux-* && "$target_platform" != linux-ppc64le ]]; then
      check_ucx=yes
  fi

  # default is UCX (set by order in --with-device if available)
  if [[ $check_ucx == yes ]]; then
      $MPIEXEC -n 1 "$executable" | grep UCX
  else
      $MPIEXEC -n 1 "$executable" | grep OFI
  fi

  # explicit OFI
  if [[ $check_ofi == yes ]]; then
    export MPICH_CH4_NETMOD=ofi
    $MPIEXEC -n 1 "$executable" | grep OFI
  fi

  # explicit UCX
  if [[ $check_ucx == yes ]]; then
    export MPICH_CH4_NETMOD=ucx
    $MPIEXEC -n 1 "$executable" | grep UCX
  fi

  unset MPICH_CH4_UCX_CAPABILITY_DEBUG
  unset MPICH_CH4_OFI_CAPABILITY_DEBUG
  unset MPICH_CH4_NETMOD
}

if [[ $PKG_NAME == "mpich-mpicc" ]]; then
  command -v mpicc
  mpicc -show

  mpicc $CFLAGS $LDFLAGS helloworld.c -o helloworld_c
  $MPIEXEC -n 4 ./helloworld_c
  check_netmods ./helloworld_c
fi

if [[ $PKG_NAME == "mpich-mpicxx" ]]; then
  command -v mpicxx
  mpicxx -show

  mpicxx $CXXFLAGS $LDFLAGS helloworld.cxx -o helloworld_cxx
  $MPIEXEC -n 4 ./helloworld_cxx
  check_netmods ./helloworld_cxx
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
