# Package Versioning and Dependency Resolution

This note captures the design for versioned [shlib][] packages and, in
particular, how conflicting transitive dependencies are resolved.  It is a
design document, not an interface reference.

## The problem

shlib presents its public API through a single, flat, process-global
namespace: an interface `poo.thing` is a shell alias that expands to an
internal function `__shlib_poo_thing`.  Everything imported into a script is
sourced into *one* shell, so there is exactly one global symbol table and no
per-caller scoping.

That makes the classic diamond dependency the hard case:

    foo -> boo -> poo@v1
    foo -> bar -> poo@v2

`boo` needs `poo` to behave as v1, `bar` needs it to behave as v2, and both
end up sourced into the same process.  With one global namespace and no
versioning, the second definition of `__shlib_poo_thing` silently clobbers the
first — the failure mode that plagues single-version resolvers.  Bundling a
private copy of `poo` with every consumer (the deep `node_modules` approach)
avoids the clash but reintroduces unbounded duplication.

## Why the obvious runtime fixes do not work

- **Rebinding a shared alias per consumer at runtime.**  An alias is a single
  global slot; `poo/v1` and `poo/v2` both want to own `poo.thing`, and the
  last one sourced wins.  There is no way to make one alias mean two things to
  two callers at call time.
- **A routing alias that dispatches on the caller.**  This needs a portable
  runtime call stack to identify the caller, which POSIX does not provide
  (`SHLIB_CALL_STACK` is an import-time stack, not a runtime one).  Building
  one means push/pop bookkeeping in every function — the heaviest possible tax
  on the most-travelled path — and for the router to tell callers apart their
  symbols must already be version-tagged, at which point the direct call is
  already available and the router is pure overhead.

The conclusion the constraints force: **a single name cannot carry two
behaviours in one namespace.**  The version has to live in the *name* — the
same reason a C shared library cannot have one unversioned symbol mean two
things in one address space.

## The solution: resolve versions at install time

Put the version in the name, and bind it the way a linker binds a symbolic
reference to a versioned one — at *link* (here, *install*) time, not at
runtime and not by the author.

1. **The author writes version-agnostic source.**  A package calls
   `poo.thing`; it never writes a version anywhere.

2. **Install stamps the version into the names.**  When a package is
   materialised into its slot, a mechanical rewrite keyed on the package name
   applies:

   - its own internals are slotted: `__shlib_poo_` -> `__shlib_poo_v1_`
   - each declared dependency reference is resolved: a consumer that depends on
     `poo@v1` has its `poo.thing` calls rewritten to the versioned interface
     `poo_v1.thing`

   Concretely this is a `sed` pass — the shell equivalent of a linker version
   script.  It runs at install (cold path), never at runtime.

3. **Runtime stays dumb.**  Both `poo/v1` and `poo/v2` install as physically
   distinct symbols (`__shlib_poo_v1_*`, `__shlib_poo_v2_*`) that coexist with
   zero collision.  A consumer's installed body calls the versioned interface
   directly, so there is no resolver, no router, and no call-stack tracking at
   runtime — only a `SHLIB_PATH` lookup and ordinary function calls.

4. **The unqualified alias remains the "latest" convenience.**  `poo.thing`
   (unqualified) resolves to the newest installed slot and is intended for
   interactive and unversioned use, where there is no diamond to resolve.

The diamond then resolves trivially: `boo` literally calls
`__shlib_poo_v1_thing` and `bar` literally calls `__shlib_poo_v2_thing`.  They
are simply two different functions sitting in the namespace — shared once in
the tree, never duplicated per consumer.

## On-disk layout and import syntax

Packages install into a shared tree, one directory per slot:

    ${prefix}/lib/shlib/<package>/v<version>/

- `import <package>` — bind the newest installed version (latest, caveat
  emptor; appropriate for interactive use).
- `import <package>@v<version>` — bind an exact slot.

The path version is the **major / slot** — the API contract.  Compatible
minor and patch releases share a slot and live once in the tree, so updating
within a slot requires no code change; only a breaking major bump opens a new
slot (and may legitimately require touching code).  Keeping the path version
to the major also keeps `__shlib_lib_resolv`'s "newest" comparison cheap.

This is the same shape REST APIs use (`/v2/...`): the version is part of the
address, and unversioned means "current".

## Optional: manifests and lockfiles

Version-in-path with major slots already decouples minor/patch updates from
code.  Exact-pin reproducibility ("this release shipped against 2.1.3") and
central override are the only things it does not give for free, and neither
belongs in the core.  Because `SHLIB_PATH` is a search path, a lockfile can be
an *overlay*: it materialises a pinned slice and prepends it, so the code still
says `import poo@v2` while the overlay decides which 2.x answers.  Deferred
until reproducibility demands it.

## Load-bearing behaviour and its verification

The scheme relies on one shell behaviour: an alias used inside a function body
is expanded when the function is **defined** (parse time), and the expansion —
not the alias — is what is stored, so redefining the alias afterward does not
affect already-parsed functions.  Bash only does this in POSIX mode, which
shlib forces via `POSIXLY_CORRECT`.

This was verified directly across shells.  With bash in POSIX mode, all of
dash, bash, ksh, mksh, and zsh agree:

- an alias expands inside a function body, and
- the expansion is frozen at parse time (redefining the alias later prints the
  original binding).

A worked example, confirmed green under all five shells:

```sh
# two versions coexist as distinct symbols + distinct aliases
# (this is what the install-time stamp produces)
__shlib_poo_v1_thing() { echo 'v1'; }
alias poo_v1.thing='__shlib_poo_v1_thing '
__shlib_poo_v2_thing() { echo 'v2'; }
alias poo_v2.thing='__shlib_poo_v2_thing '

# consumers as the installer leaves them (each author wrote a plain "poo.thing")
__shlib_boo_run() { poo_v1.thing; }   # boo declared poo@v1
__shlib_bar_run() { poo_v2.thing; }   # bar declared poo@v2

__shlib_boo_run    # -> v1
__shlib_bar_run    # -> v2   (simultaneously, in one process)
```

## Limitations

- **Static references only.**  Only literal interface calls can be resolved at
  install time.  A call built with `eval` or dispatched through a variable
  cannot be bound — the analogue of `ld.so` being unable to version a `dlsym`.
  Genuinely dynamic dispatch is the one place an explicit runtime router is
  justified, and it is opt-in, not the default calling convention.
- **The unqualified alias means one version at a time** — the newest.  A bare
  `poo.thing` cannot transparently serve v1 to one caller and v2 to another in
  the same process; anything with a real dependency uses the version stamped in
  at install.

[//]: # (References)

[shlib]: http://github.com/major0/shlib "shlib"
