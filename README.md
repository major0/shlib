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

Core API
========

At the heart of [shlib's][shlib] core interfaces are some basic helper routines.

error()
-------

Display the given message to stderr.

die()
-----

Display the given message to stderr and terminte program execution.

import()
--------

Import the specified library into the current environment.  This was inspired
by the `import` command found in Python and acts as a replacement to the
`source` or `.` command used in the POSIX shell environment.  This interface
searches for the named library in `SHLIB_PATH` and sources it in.  Thanks to
some shell-magic, a given library can only be imported once (attempting to
source the same library in a second time silently returns), and a library
"knows" if it is being sourced in vs being executed directly.

`shlib.main()`
------------

Test if the current library is being executed directly.

Example Programs
----------------

The following is a simple program which simply prints every argument back to stdout.

	#!/usr/bin/env shlib
	
	args()
	{
		while test "$#" -gt '0'; do
			echo "${1}"
			shift
		done
	}
	
	shlib.main() {
		args "${@}"
	}

Due to the nature of POSIX shell, libraries can perform tests _when_ they are imported.

	#!/usr/bin/env shlib
	
	if hascmd seq; then
		__math_seq() { command seq "${@}"; }
	else
		# no seq cmd available then attempt to load the bash version
		# which uses a c-for style itterator, else use one written in
		# pure POSIX shell.
		if ! . seq.bash > /dev/null 2>&1; then
			. seq.sh
		fi
	fi
	alias math.seq='__math_seq '
	
	shlib.main() { math.seq "${@}"; }

From here a program only need to `import seq` to gain access to a `seq()`
function which will call the native `seq` command if available, otherwise it
will use one implemented in POSIX shell.

[shlib]: http://github.com/major0/shlib "shlib"
[ksh]: http://www.kornshell.com/ "Korne Shell"
[bash]: http://www.gnu.org/software/bash/ "Borne Again Shell"
[zsh]: http://www.zsh.org/ "Z Shell"
