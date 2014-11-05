shlib
=====

One of the great drawbacks to the POSIX shell environment is that, like the C
programming language, it has very little in the way of builtin high-level
functionality.  This has lead to a number of variations of the POSIX shell
([Korne Shell][ksh], [Z Shell][zsh], [Bash][bash], etc..) which implement
various high-level features in their own proprietary way.  [shlib][shlib] aims
to supply many (all?) of these high-level features using only pure POSIX shell
syntax, while optimizing the core of any interface via shell-specific
enhancements under the covers.  Further more, [shlib][shlib] is self-optimizing
at *load-time*, meaning that it does not spend time checking the shell
environment every time an interface is called.  The end result is fast and
portable shell scripts which work right regardless of which flavor of `/bin/sh`
is interpretting them.

Usage
=====

[shlib][shlib] tries hard to be as non-intrussive as possible to software
developers.  To this end there are a number of ways to integrate [shlib][shlib]
into ones software.

Command Line
------------

[shlib][shlib] can be envoked from the command-line in much the same way as
traditional /bin/sh.

Examples:

 1. Run an shlib: `shlib program.shlib`
 2. Run a shell script: `shlib program.sh`
 3. Shell-like `-c` syntax: `shlib -c 'import hostinfo;hostinfo'

See `shlib --help` for various command-line options which change the behavior
of [shlib][shlib].

hash/bang
---------

You can make [shlib][shlib] the interpretter for an existing shell script.

	#!/usr/bin/env shlib

(_warning: not all OS's support scripts being used as the interpretter for a
file in this way_).

Source in shlib
---------------

When all else fails, you can simply source in the [shlib][shlib] top-level
script into your existing `/bin/sh` scripts.

	. /path/to/shlib

See Also
========

 * [Examples](examples/)
 * [Development](CONTRIB.md)
 * [API](libexec/shlib/__index__.md)
 * [License](LICENSE)

[shlib]: http://github.com/major0/shlib "shlib"
[ksh]: http://www.kornshell.com/ "Korne Shell"
[bash]: http://www.gnu.org/software/bash/ "Borne Again Shell"
[zsh]: http://www.zsh.org/ "Z Shell"
