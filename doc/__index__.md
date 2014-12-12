[shlib][] / core

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

You can get information about a library, and a list of the library's provided
interfaces via the command `shlib --help <library>`.  To see documentation for
a specific interface use `shlib --help <library>.<interface>`.

### shlib routines ###

 [error][], [die][], [getarg][], [hascmd][], [import][], [main][], [optarg][], [pathcmd][] [realpath][]

### libraries ###

 [math][], [string][], [experimental][]

[atexit]: atexit.md "atexit"
[error]: error.md "error"
[die]: die.md "die"
[getarg]: getarg.md "getarg"
[hascmd]: hascmd.md "hascmd"
[import]: import.md "import"
[pathcmd]: pathcmd.md "pathcmd"
[main]: main.md "main"
[optarg]: optarg.md "optarg"
[realpath]: realpath.md "realpath"
[math]: ../math/__index__.md "math"
[string]: ../string/__index__.md "string"
[experimental]: ../experimental/__index__.md "experimental"
[core]: ../shlib/__index__.md "core"
[shlib]: http://github.com/major0/shlib "shlib"
