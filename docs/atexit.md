[shlib][] / [core][] / atexit()

## shlib.atexit <function>

Register the given `<function>` to be called at normal process termination.
Functions registered are called in rerverse order of registration and the same
function may be registered multiple times.

Functions registered via `atexit()` are not called if the process terminates
abnormally.

If a registered function calls `exit` then any remaining functions are not
invoked.

[shlib]: http://github.com/major0/shlib "shlib"
[core]: __index__.md "core"
