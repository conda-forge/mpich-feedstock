!  (C) 2008 by Argonne National Laboratory.
!      See COPYRIGHT in top-level directory.

program main

  use mpi
  
  implicit none

  integer :: ierr, myid, numprocs, rc

  call mpi_init(ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, myid, ierr)
  call mpi_comm_size(MPI_COMM_WORLD, numprocs, ierr)
  print *, "Process ", myid, " of ", numprocs, " is alive"

  call mpi_finalize(rc)

end program main
