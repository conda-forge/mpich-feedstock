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

MPIEXEC="mpiexec -launcher fork"
$MPIEXEC --help

python no-nonblock.py

mpicc helloworld.c -o helloworld_c
$MPIEXEC -n 4 ./helloworld_c
python no-nonblock.py

mpicxx helloworld.cxx -o helloworld_cxx
$MPIEXEC -n 4 ./helloworld_cxx
python no-nonblock.py

mpif77 helloworld.f -o helloworld_f
$MPIEXEC -n 4 ./helloworld_f
python no-nonblock.py

mpif90 helloworld.f90 -o helloworld_f90
$MPIEXEC -n 4 ./helloworld_f90
python no-nonblock.py

popd
