## shlib.import [<lib>|<lib>.<iface>] ...

Import the specified lib or lib.iface into the current environment.  This was
inspired by the `import` command found in Python and acts as a replacement to
the `source` or `.` command used in the POSIX shell environment.  This
interface searches for the named library in `SHLIB_PATH` and sources it in.
Thanks to some shell-magic, a given library can only be imported once
(attempting to source the same library in a second time silently returns).

aliases: shlib.import, import
