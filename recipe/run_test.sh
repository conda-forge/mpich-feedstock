#!/bin/bash

command -v mpichversion
mpichversion

command -v mpicc
mpicc -show

command -v mpicxx
mpicxx -show

command -v mpif90
mpif90 -show

command -v mpiexec

pushd $RECIPE_DIR/tests

function mpi_exec() {
  if [[ "$(uname)" == "Darwin" ]]; then
    mpiexec -launcher fork $@
    python no-nonblock.py
  else
    # skip mpiexec tests on Linux due to conda-forge bug:
    # https://github.com/conda-forge/conda-smithy/pull/337
    echo "SKIPPING mpiexec $@"
  fi
}

mpicc helloworld.c -o helloworld_c
mpi_exec -n 4 ./helloworld_c

mpicxx helloworld.cxx -o helloworld_cxx
mpi_exec -n 4 ./helloworld_cxx

mpif77 helloworld.f -o helloworld_f
mpi_exec -n 4 ./helloworld_f

mpif90 helloworld.f90 -o helloworld_f90
mpi_exec -n 4 ./helloworld_f90

popd
