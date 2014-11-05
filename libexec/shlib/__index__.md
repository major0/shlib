# shlib #

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

 [error] [die] [getarg] [hascmd] [import] [pathcmd] [main] [optarg]

## shlib libraries ##

 [math] [string] [experimental]

[error](libexec/shlib/error.md)
[die](libexec/shlib/error.md)
[getarg](libexec/shlib/getarg.md)
[hascmd](libexec/shlib/hascmd.md)
[import](libexec/shlib/import.md)
[pathcmd](libexec/shlib/pathcmd.md)
[main](libexec/shlib/main.md)
[optarg](libexec/shlib/optarg.md)
[math](libexec/math/__index__.md)
[string](libexec/string/__index__.md)
[experimental](libexec/experimental/__index__.md)
