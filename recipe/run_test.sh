#!/bin/bash
set -x

command -v mpichversion
mpichversion

command -v mpicc
mpicc -show

command -v mpicxx
mpicxx -show

command -v mpif90
mpif90 -show

command -v mpiexec


pushd "tests"

function mpi_exec() {
  # use pipes to avoid O_NONBLOCK issues on stdin, stdout
  mpiexec -launcher fork $@ 2>&1 </dev/null | cat
}

if [[ $PKG_NAME == "mpich" ]]; then
  mpi_exec -n 4 python test_exec.py
fi

if [[ $PKG_NAME == "mpich-mpicc" ]]; then
  mpicc $CFLAGS $LDFLAGS helloworld.c -o helloworld_c
  mpi_exec -n 4 ./helloworld_c
fi

if [[ $PKG_NAME == "mpich-mpicxx" ]]; then
  mpicxx $CXXFLAGS $LDFLAGS helloworld.cxx -o helloworld_cxx
  mpi_exec -n 4 ./helloworld_cxx
fi

if [[ $PKG_NAME == "mpich-mpifort" ]]; then
  mpif77 $FFLAGS $LDFLAGS helloworld.f -o helloworld_f
  mpi_exec -n 4 ./helloworld_f

  mpif90 $FFLAGS $LDFLAGS helloworld.f90 -o helloworld_f90
  mpi_exec -n 4 ./helloworld_f90
fi

popd
