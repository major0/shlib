shlib
=====

One of the great drawbacks to the POSIX shell environment is that, like the C
programming language, it has very little in the way of builtin high-level
functionality.  To do many things often requires resorting to esoteric hacks
which wrap other tools. This has lead to a number of variations of the POSIX
shell ([Korne Shell][ksh], [Z Shell][zsh], [Bash][bash], etc..) which implement
various high-level features in their own proprietary way.  [shlib][] aims
to supply many (all?) of these high-level features using only pure POSIX shell
syntax, while optimizing the core of any interface via shell-specific
enhancements under the covers (making afore mentioned esoteric hacks totally
portable and useful for all).  Further more, [shlib][] is self-optimizing
at *load-time*, meaning that it does not spend time checking the shell
environment every time an interface is called.  The end result is fast and
portable shell scripts which, hopefully, work right regardless of which flavor
of `/bin/sh` is interpretting them.

## Philosphy ##

[shlib][] is written around the goal of providing a portable **dumping
ground** for various shell tricks and hacks produced throughout the ages.  Such
things as floating point arithematic, string manipulation, and even just overly
common routines used by programmers on a day-to-day basis.  With that in mind,
[shlib][] is a framework which presents a portable interface to the developer, but
which may be implemented via any number of methods under-the-covers at load
time.

## What shlib is not ##

[shlib][] is not in and of itself a scripting language, or a replacement to
existing shells.  While various libaries w/in [shlib][] may implement an
interface using external utilities are shell-specific features, the interfaces
provided conform to the [Shell Command Language](http://pubs.opengroup.org/onlinepubs/007904975/utilities/xcu_chap02.html)
as defined by the [OpenGroup](http://www.opengroup.org/).

## load-time optimization ##

Due to the nature of POSIX shell, libraries can perform tests _when_ they are
imported, as opposed to doing a test every time an interface is called.  This
allows [shlib][] to implement a single interface via a variety of methods, and
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

## Nonconforming shells ##

Several widely-used shells deviate from POSIX in ways that affect [shlib][].
Where the deviation can be papered over, [shlib][] does so transparently and
the shell is fully supported; where it cannot, the shell is listed here so its
limits are known.

### Bash ###

Bash is fully supported, but only because [shlib][] works around two POSIX
violations internally:

 * **Alias expansion is disabled in non-interactive shells.**  POSIX performs
   alias substitution while parsing every command; Bash suppresses it unless
   the shell is interactive (or `shopt -s expand_aliases` is set).  Because the
   entire [shlib][] public API is alias-based, [shlib][] forces POSIX mode with
   `readonly POSIXLY_CORRECT=posix`, which restores POSIX alias expansion.

 * **`getopts` mis-indexes `OPTIND`.**  Bash (and Zsh) do not count `$0` in
   `OPTIND`, and during error handling they leave `OPTIND` pointing at the
   offending argument -- behaviour POSIX does not describe.  [shlib][]
   compensates in its internal `shiftarg` routine, which branches on the
   detected shell to recover the correct shift count so that the long-option
   parsing built on top of `getopts` behaves identically everywhere.

### AT&T Ksh 93 ###

Observed in `Version AJM 93u+m/1.0.8`.  When a file is *dot-sourced*
(`. file`), ksh93 compiles the whole file as a single unit, so an alias that is
both **defined and used within that same file** is not yet in effect when a
later function in the file is parsed -- the alias fails to "bake" into the
function body.  (Run as a top-level script it reads line-by-line and behaves as
expected.  POSIX leaves this same-parse-unit case unspecified, so it is not
strictly a violation.)

This does not affect normal [shlib][] use: a library's aliases are defined in
that library's own file and consumed from a *later* imported file -- the
prior-unit case, which ksh93 handles correctly.  It only bites code that
defines an alias and then relies on it within the very same sourced file, a
pattern [shlib][] avoids by convention.

Usage
=====

[shlib][] tries hard to be as non-intrussive as possible to software
developers.  To this end there are a number of ways to integrate [shlib][]
into ones software.

Command Line
------------

[shlib][] can be envoked from the command-line in much the same way as
traditional `/bin/sh`.

Examples:

 1. Run an shlib: `shlib program.shlib`
 2. Run a shell script: `shlib program.sh`
 3. Shell-like `-c` syntax: `shlib -I math -c 'math.seq 0 9'`

See `shlib --help` for various command-line options which change the behavior
of [shlib][].

hash/bang
---------

You can make [shlib][] the interpretter for an existing shell script.

	#!/usr/bin/env shlib

(_warning: not all OS's support scripts being used as the interpretter for a
file in this way_).

Source in shlib
---------------

When all else fails, you can simply source in the [shlib][] top-level
script into your existing `/bin/sh` scripts.

```sh
	. /path/to/shlib
```

See Also
========

 * [Examples](examples/)
 * [Development](CONTRIB.md)
 * [API Reference](doc/__index__.md)
 * [Future features](TODO.md)
 * [License](LICENSE)
 * [Unix Shell Objects](https://www.biblio.com/9780764570049), ISBN-13: 978-0764570049, ISBN-10: 0764570048
 * [A new object-oriented programming lanuage: sh](https://dl.acm.org/doi/10.5555/1267257.1267258)
 * [SHOOP: SHell Object Oriented Programming](https://sourceforge.net/projects/shoop/)

[shlib]: http://github.com/major0/shlib "shlib"
[ksh]: http://www.kornshell.com/ "Korne Shell"
[bash]: http://www.gnu.org/software/bash/ "Borne Again Shell"
[zsh]: http://www.zsh.org/ "Z Shell"
