shlib
=====

One of the great drawbacks to the POSIX shell environment is that, like the C
programming language, it has very little in the way of builtin high-level
functionality.  To do many things often requires resorting to esoteric hacks
which wrap other tools. This has lead to a number of variations of the POSIX
shell ([Korne Shell][ksh], [Z Shell][zsh], [Bash][bash], etc..) which implement
various high-level features in their own proprietary way.  [shlib][shlib] aims
to supply many (all?) of these high-level features using only pure POSIX shell
syntax, while optimizing the core of any interface via shell-specific
enhancements under the covers (making afore mentioned esoteric hacks totally
portable and useful for all).  Further more, [shlib][shlib] is self-optimizing
at *load-time*, meaning that it does not spend time checking the shell
environment every time an interface is called.  The end result is fast and
portable shell scripts  which work right regardless of which flavor of
`/bin/sh` is interpretting them.

## Philosphy ##

[shlib][shlib] is written around the goal of providing a portable **dumping
ground** for various shell tricks and hacks produced throughout the ages.  Such
things as floating point arithematic, string manipulation, and even just overly
common routines used by programmers on a day-to-day basis.  With that in mind,
shlib is a framework which presents a portable interface to the developer, but
which may be implemented via any number of methods under-the-covers at load
time.

## What shlib is not ##

[shlib] is not in and of itself a scripting language, or a replacement to
existing shells.  While various libaries w/in shlib may implement an interface
using external utilities are shell-specific features, the interfaces
provided conform to the [Shell Command Language](http://pubs.opengroup.org/onlinepubs/007904975/utilities/xcu_chap02.html)
as defined by the [OpenGroup](http://www.opengroup.org/).

## load-time optimization ##

Due to the nature of POSIX shell, libraries can perform tests _when_ they are
imported, as opposed to doing a test every time an interface is called.  This
allows [shlib] to implement a single interface via a variety of methods, and
select the method which best fits the local platform.

For example:

```sh
	#!/usr/bin/env shlib
	
	if shlib.hascmd seq; then
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
```

From here a program only need to `import math.seq` to gain access to a
`math.seq()` function which will call the native `seq` command if available,
otherwise it will use one implemented in POSIX shell.


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
 3. Shell-like `-c` syntax: `shlib -c 'import hostinfo;hostinfo'`

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
 * [API Reference](doc/__index__.md)
 * [Future features](TODO.md)
 * [License](LICENSE)

[shlib]: http://github.com/major0/shlib "shlib"
[ksh]: http://www.kornshell.com/ "Korne Shell"
[bash]: http://www.gnu.org/software/bash/ "Borne Again Shell"
[zsh]: http://www.zsh.org/ "Z Shell"
