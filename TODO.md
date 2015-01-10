# dir
Interface for walking and acting upon directory structures.
 - walk
 - isempty

# lock
Portable locks for enforcing exclusion. Likely depends on shlib.mktemp and the
dir.* interaces.
 - init
 - lock
 - unlock
 - destroy

db
Simple directory structured database supporting key=value pairs. Will likely
depend on dir.* and the lock.* interfaces.

# url
Interface for the manipulation of URLs
 - escape <string>
 - each <url>
 - fetch <url>

# archive
Universal archive wrapper to various archive commands.
 - create <archive> <pattern>
 - add <archive> <pattern>
 - extract <archive> <pattern>
 - find <archive> <pattern>

# fd
File descriptor management.  Shell does not really do any FD management for us,
unlike the underlying OS.  So we need to track all out FDs manualy and figure
out what is or isn't in use.
 - alloc
 - free <fd>
 - dup <fd>

# log (depends on fd.*)
Sane logger interface which allows the opening of multilpe log locations and
the writing to multiple log locations based on a single log message. This will
depend on the fd.* interface.
 - create <label>
 - append <newlabel> <oldlabel>
 - write <label> <message>
 - error: log.write error <message>
 - warn: log.write warn <message>
 - info: log.write info <message>
 - debug: log.write debug <message>

# mktemp
Portable replacement to mktemp that can do most (all?) of the things we expect
from the Linux mktemp, but which automatically adds an automatic shlib.atexit()
to the generated path to garantee its cleanup.  It is also possible that we can
always assume a mktemp cleanup in shlib w/out the use of atexit(). Will
absolutely depend on shlib arrays.
