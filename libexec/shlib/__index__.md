shlib
-----

The core of the shlib API implements only that which is deemed necessary to
implement the shlib framework. In short, if it was necessary to implement the
shlib executable, than it is supplied by the shlib core, otherwise it will be
found in one of the other libraries.

All library interfaces are bound to a name-space alias.  This means that shlib
routines are prefixed with `shlib.`.  E.g. `shlib.error "${message}"`.
Routines found in the math library will be similarly prefixed, such as
`math.sum 1 2 3 4 5`.

You can get information about a library, and a list of the libraries provided
interfaces, via the command `shlib --help <library>`.  To see documentation for
a specific interface use `shlib --help <library>.<interface>`.

## shlib routines ##

 [error][], [die][], [getarg][], [hascmd][], [import][], [main][], [optarg][], [pathcmd][] [realpath][]

## shlib libraries ##

 [math][], [string][], [experimental][]

[error]: error.md
[die]: die.md
[getarg]: getarg.md
[hascmd]: hascmd.md
[import]: import.md
[pathcmd]: pathcmd.md
[main]: main.md
[optarg]: optarg.md
[realpath]: realpath.md
[math]: ../math/__index__.md
[string]: ../string/__index__.md
[experimental]: ../experimental/__index__.md
