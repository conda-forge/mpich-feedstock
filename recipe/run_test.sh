# Stop on first error
set -e

# Test compilers. For this we need to set DYLD_FALLBACK_LIBRARY_PATH to
# make sure libgfortran gets picked up. Ideally this shouldn't be needed, but
# this is how the gfortran compiler works in conda - see:
#
#   https://github.com/ContinuumIO/anaconda-issues/issues/739
#
# for more details.

export DYLD_FALLBACK_LIBRARY_PATH=${CONDA_PREFIX}/lib

# Test C compiler
echo "Testing mpicc"
mpicc -show
mpicc hellow.c -o hellow_c
mpirun -n 4 ./hellow_c

# Test f77 compiler
echo "Testing mpif77"
mpif77 -show
mpif77 hellow.f -o hellow_f
mpirun -n 4 ./hellow_f

# Test f90 compiler
echo "Testing mpif90"
mpif90 -show
mpif90 hellow.f90 -o hellow_f90
mpirun -n 4 ./hellow_f90
