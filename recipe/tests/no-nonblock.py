"""Unset O_NONBLOCK, which can be set after mpiexec

See https://github.com/pmodels/mpich/issues/1782
"""

import os, sys, fcntl
for name in ('stdin', 'stdout', 'stderr'):
    fd = getattr(sys, name).fileno()
    flags = fcntl.fcntl(fd, fcntl.F_GETFL)
    if flags & os.O_NONBLOCK:
        print("fixing %s" % name)
        fcntl.fcntl(fd, fcntl.F_SETFL, flags ^ os.O_NONBLOCK)
