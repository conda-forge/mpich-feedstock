# Stop on first error.
set -e

pushd $RECIPE_DIR/tests

# Test C compiler.
echo "Testing mpicc"
mpicc -show
mpicc hellow.c -o hellow_c
mpirun -n 4 ./hellow_c

# Test f77 compiler.
echo "Testing mpif77"
mpif77 -show
mpif77 hellow.f -o hellow_f
mpirun -n 4 ./hellow_f

# Test f90 compiler.
echo "Testing mpif90"
mpif90 -show
mpif90 hellow.f90 -o hellow_f90
mpirun -n 4 ./hellow_f90

popd
