# shlib TODO

Tracked work for shlib, grouped by kind.  Items were surfaced while building
the test framework and the package-versioning design (see docs/packages.md).

## Known bugs

None currently tracked.  The Phase A foundation bugs -- hyphenated imports,
relative `-L` resolution, the undefined `shlib.doc`, the `hostinfo`
config.guess/nproc handling, and the `math` calc/sum/pop defects -- are fixed.
Remaining shortfalls are captured under Core enhancements / Portability below.

## Core enhancements

- **Shell identity.**  *(detection done)* Read-only `SHLIB_SHELL` /
  `SHLIB_SHELL_IMPL` / `SHLIB_SHELL_VERSION` are now published from the bootstrap
  (`ZSH_VERSION`/`BASH_VERSION`/`YASH_VERSION` plus `KSH_VERSION` content to
  split ksh93/mksh/lksh/pdksh).  Remaining: convert the runtime heuristics --
  `shiftarg`'s *BSD `OPTIND` guess, the `printf` selection, the math
  native-gating -- to branch on `SHLIB_SHELL_IMPL` instead of re-probing.  Also
  distinguish `dash` from BusyBox `sh` (both currently report `impl=sh`).

- **SHLIB_RESULT result-register convention.**  *(piloted)* Interfaces publish
  their value into the shell-global `SHLIB_RESULT` and their status via native
  `return`/`$?`, instead of writing to stdout and being captured with `$(...)`.
  This removes a subshell fork per call (the cost being brutal in loops).
  Rules: set `SHLIB_RESULT` last (tail position), read it immediately (same
  timing as `$?`/`$!`), interfaces emit nothing to stdout, and only the CLI
  boundary (`shlib.main`) prints it.  There is no `shlib.return` helper -- a
  function's `return` cannot set its caller's `$?` (proven), so it is a plain
  assignment plus native `return`.  Migrated so far: the `array`, `math`, and
  `string` libs (value-returning interfaces publish `SHLIB_RESULT`; status
  predicates such as `math.cmp`, `string.compare`, and `string.regexp` keep
  using the exit status; `math.seq` stays a documented stream generator).  The
  convention is pinned in `docs/result.md` + a steering rule.  Remaining: (1)
  the `system`, `hostinfo`, and `experimental` libs; (2) a fork-free interface
  can only build its result with pure parameter expansion, so the libs that
  still lean on external tools want a pure-shell rewrite -- see the follow-ups
  below.

- **Pure-shell string backends.**  `string.tolower`/`toupper` still shell out
  to `tr`, and `string.match`/`sub`/`regexp` to `awk`.  Case conversion has a
  straightforward fork-free rewrite (a character-class map); the regex-based
  interfaces need the same regex engine a broader BRE/ERE capability would
  provide.  (`string.compare`/`index`/`escape` are already fork-free.)

- **Documentation system.**  Extract documentation from the `.shlib` sources
  instead of maintaining parallel `.md` files.  Expose via `shlib doc
  <package>` and `shlib doc <package>.<interface>`, with `@<version>` support.
  Retire the per-interface `.md` files and fix the dangling `shlib.doc` once
  done.

- **CLI cleanup.**  Remove `--shlib-only`; rename `--report-set` to
  `--detect-var-leak`.

- **Package system.**  *(declarative core landed)*  A package ships a data-only
  `shpkg.vars` manifest (`pkg_manifest`, whitelist
  NAME/VERSION/DESCRIPTION/HOMEPAGE/LICENSE/DEPENDS) that is parsed, never
  sourced -- no per-package install code (the pip/npm/ebuild hole).  A static
  FHS walker (`pkg_install_tree`) drives the `do*` verbs from a fixed layout;
  the package gets no say (the Go stance); only `bin/` is templated.  See
  `docs/shpkg.md`.  Remaining:
  - **Installer front-end.**  *(local paths land)*  `shlib install
    [<options>] <source>` reads `<source>/shpkg.vars` with `pkg_manifest` and
    installs the fixed layout via `pkg_install_tree` (in
    `libexec/shlib-install`); `shlib install .` self-installs.  Remaining:
    accept a URL -- normalise a local path to `file://` and dispatch by scheme
    (`file://` direct, `git` URLs cloned first) so `shlib install <git-url>`
    works.
  - **Versioning** per docs/packages.md: SLOT/DEPENDS, install-time slot
    mangling and dependency resolution to versioned symbols, the
    `<prefix>/lib/shlib/<package>/v<version>` layout, and `import
    <package>@v<version>`.
  - **Staging + uninstall.**  `DESTDIR`/`${ED}`-style staging and a `CONTENTS`
    manifest recorded at install so a package can be removed cleanly.

- **Pure-shell float evaluator.**  *(integer half + cleanup landed)*  A
  fork-free tokenizer (`token`) and integer evaluator (`math.eval`) back
  `math.calc` and the integer path of `math.cmp` (see the `parse-toolkit`
  spec), and all of `math.*` now publishes via `SHLIB_RESULT`, is
  `shellcheck -s sh` clean, and is tested.  What remains is the *float* half,
  which an integer evaluator cannot cover: `math.int`, `math.seq`'s float path,
  and the transcendental functions (`sin`, `cos`, `exp`, `log`, `sqrt`,
  `atan2`, `rand`) still shell out to `awk`/`zsh`.  A pure-shell fixed-point
  float evaluator (a second consumer of `token`) is the follow-on that removes
  those forks.

- **Unify math output precision.**  The float backends are inconsistent:
  `cos`/`atan2` print via `printf "%0.20f"` while `sin`/`sqrt`/`log`/`exp`/
  `int`/`rand` use `print` (awk's `%.6g`).  Settle a single precision policy
  (naturally, as part of the float-evaluator work).

## Portability

- **ksh93 -- supported via function re-baking (resolved).**  ksh93 compiles a
  whole dot-sourced file (and a `-c` string) as one parse unit, so a same-unit
  alias never bakes into a function defined in that unit -- and the shlib API is
  alias-based.  `__shlib_rebake` fixes this: when the outermost `import` unwinds
  (all aliases defined), it re-declares every function via `typeset -f`/`eval`
  so the re-parse bakes the aliases in.  Guarded to `SHLIB_SHELL_IMPL=ksh93`;
  no-op elsewhere.  (Was briefly hard-blocked; the re-bake technique, adapted
  from alganet's c89cc.sh, restored support.)  Remaining: (1) top-level bare
  alias use in the same unit still cannot be re-baked (not inside a function) --
  document/accept; (2) re-bake is O(functions) per top-level import under
  ksh93 -- fine for now, revisit if it bites; (3) once packages exist, the
  loader could re-bake per package rather than globally.

- **`-c` is a single parse unit.**  `shlib -c 'import X; X.func'` cannot bake
  `X`'s alias for the bare `X.func` on *any* shell, because the `-c` string is
  run through one `eval` (one parse unit) -- same alias parse-time rule as the
  ksh93 case.  Documented workaround is `-I X -c 'X.func'` (import runs before
  the eval).  A cleaner fix ties into the existing shlib FIXME to write the
  `-c` string to a temp script and source it instead of `eval`-ing it, which
  would let a multi-line `-c` bake aliases the way a real script does.

- **Unsupported shells.**  Add `posh` (no `alias` builtin -- cannot run shlib)
  and `sash` (not a POSIX-sh drop-in) to the README "Nonconforming shells"
  section as a distinct "cannot run shlib" category, separate from Bash (which
  is worked around).

## Testing and CI

- **Grow the CI matrix.**  The matrix is now `[dash, bash, ksh, mksh, zsh,
  yash]` (`ksh` = AT&T ksh93, supported via re-baking; `posh` excluded -- no
  `alias` builtin).  Still to add: `lksh` and `busybox`.  Handle the `busybox
  sh` invocation and the fact that `lksh` ships in the `mksh` apt package (shell
  name != package).

- **Diamond / versioned-alias test.**  Land a `versioning_test.shlib` that
  imports two fake packages (`footest` -> `boov1`, `bartest` -> `boov2`), each
  binding the same alias to a version-distinct symbol, and assert each resolves
  to its own version.  Calling the aliases inside test functions keeps it
  working under ksh93 (the re-bake covers function bodies).  Fixture delivery:
  the runner prepends each test file's own directory to
  `SHLIB_PATH`, so fixtures co-located with a test import by simple name with
  no per-test configuration; keep the diamond test and its fixtures together in
  `lib/test/versioning/`.

- **Test framework growth.**  Add benchmarks (`bench_*`) and tests for `shlib
  <file>`, `shlib -c`, and `#!/usr/bin/env shlib` (existing but untested).

- **Retire the old runner.**  Remove `lib/deprecated/run-tests.sh` and
  `lib/deprecated/Testing.md`, superseded by `run-tests.sh` and the `lib/test`
  framework.

## Planned modules

### dir
Interface for walking and acting upon directory structures.
 - walk
 - isempty

### lock
Portable locks for enforcing exclusion. Likely depends on shlib.mktemp and the
dir.* interaces.
 - init
 - lock
 - unlock
 - destroy

### db
Simple directory structured database supporting key=value pairs. Will likely
depend on dir.* and the lock.* interfaces.

### url
Interface for the manipulation of URLs
 - escape <string>
 - each <url>
 - fetch <url>

### archive
Universal archive wrapper to various archive commands.
 - create <archive> <pattern>
 - add <archive> <pattern>
 - extract <archive> <pattern>
 - find <archive> <pattern>

### fd
File descriptor management.  Shell does not really do any FD management for us,
unlike the underlying OS.  So we need to track all out FDs manualy and figure
out what is or isn't in use.
 - alloc
 - free <fd>
 - dup <fd>

### log (depends on fd.*)
Sane logger interface which allows the opening of multilpe log locations and
the writing to multiple log locations based on a single log message. This will
depend on the fd.* interface.
 - create <label>
 - append <newlabel> <oldlabel>
 - write <label> <message>
 - error: log.write error <message>
 - warn: log.write warn <message>
 - info: log.write info <message>
 - debug: log.write debug <message>

### mktemp
Portable replacement to mktemp that can do most (all?) of the things we expect
from the Linux mktemp, but which automatically adds an automatic shlib.atexit()
to the generated path to garantee its cleanup.  It is also possible that we can
always assume a mktemp cleanup in shlib w/out the use of atexit(). Will
absolutely depend on shlib arrays.
