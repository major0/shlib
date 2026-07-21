# The SHLIB_RESULT Calling Convention

This note describes how [shlib][] interfaces return a value.  It is a design
document and a coding convention, not an interface reference.

## The problem

The traditional shell idiom for "returning" a value is to write it to stdout
and have the caller capture it with a command substitution:

```sh
result="$(some.interface "${arg}")"
```

Every `$(...)` forks a subshell.  A fork is the single most expensive thing a
shell does, and shlib's whole reason for existing is to avoid fork/exec.  In a
loop -- iterating an array, folding a list -- the per-call fork dominates the
runtime and defeats the point of a pure-shell library.

## The convention

An interface returns through two native channels and never through stdout:

- **Value -> `SHLIB_RESULT`.**  The interface assigns its result to the
  shell-global `SHLIB_RESULT`.
- **Status -> `return` / `$?`.**  The interface uses the shell's native
  `return <n>`; the caller reads `$?`.

The caller then reads the value with no fork:

```sh
some.interface "${arg}"
result="${SHLIB_RESULT}"      # no subshell
```

Rules that make this safe:

1. **Set `SHLIB_RESULT` last.**  Assign it in tail position, just before the
   interface returns, so nothing it calls afterward clobbers it.
2. **Read it immediately.**  `SHLIB_RESULT` is a single global slot with the
   same lifetime semantics as `$?` and `$!`: the *next* interface call
   overwrites it.  Copy it into a local before making another call.
3. **Interfaces emit nothing to stdout.**  A stray `echo` would leak into a
   caller that is itself being captured, corrupting that caller's output.  The
   only place a result reaches stdout is the command-line boundary: an
   interface's `shlib.main` block reads `SHLIB_RESULT` and prints it for the
   user.

`SHLIB_RESULT` is reserved: the core exempts it from the variable-leak
detector, alongside the other shlib-provided globals.

## Why there is no `shlib.return` helper

It is tempting to write `shlib.return <status> <value>` as a helper that sets
`SHLIB_RESULT` and the exit status in one call.  It cannot work: `return`
always returns from the *current* function, so a helper's `return` returns from
the helper, not from the interface that called it -- the helper cannot set its
caller's `$?`.  An alias route fails too, because aliases are textual and
cannot be parameterised to carry the value.  Verified across every supported
shell.  The convention is therefore a plain assignment plus a native `return`;
there is nothing cheaper, and nothing else works.

## Fork-free requires pure parameter expansion

The convention only pays off when the interface can *build* its result without
forking.  A function that shells out (`sed`, `awk`) or needs a subshell to
capture a builtin's output (`x="$(printf '%q' ...)"`) forks anyway, so it gains
nothing until it is rewritten in pure shell.  `printf -v` is not a portable
escape hatch -- only bash, ksh93, and zsh provide it; dash, mksh, lksh, yash,
and busybox do not.  So a lib that leans on external tools wants a pure-shell
rewrite *before* it adopts `SHLIB_RESULT`.

## Interaction with ksh93 and `-c`

`SHLIB_RESULT` sidesteps the alias parse-unit problems entirely: a caller reads
a variable rather than expanding an alias, so there is no same-unit alias to
bake.  The interfaces themselves still use aliases internally, so the usual
rules apply -- see the "Nonconforming shells" section of the README and the
function re-baking that supports ksh93.

## Worked example

```sh
import array

# Build fork-free: each call sets SHLIB_RESULT, read immediately.
array one two three
list="${SHLIB_RESULT}"

array.length "${list}"
count="${SHLIB_RESULT}"       # 3

array.head "${list}"
first="${SHLIB_RESULT}"       # one
```

## Status and rollout

Piloted on `string.escape` and the `array` library.  The convention is being
rolled out interface by interface; each migration is a flag day -- an interface
and all of its callers (and tests) must move together, because the moment it
stops writing to stdout every `$(...)` caller of it breaks.

[//]: # (References)

[shlib]: http://github.com/major0/shlib "shlib"
