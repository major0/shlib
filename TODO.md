# shlib TODO

Tracked work for shlib, grouped by kind.  Items were surfaced while building
the test framework and the package-versioning design (see doc/packages.md).

## Known bugs

- **Hyphens break library names.**  `__shlib_imported` maps a library name to
  `__shlib_<name>_imported` with `tr '/.' '_'`, which does not sanitize `-`
  (or other non-identifier characters), yielding an invalid function name and a
  hard failure on `import foo-bar`.  Either sanitize such characters or require
  and document identifier-safe library names.

- **`-L <relative-dir>` stops resolving after an import.**  Importing a library
  `cd`s into that library's directory, so a relative entry in `SHLIB_PATH` no
  longer resolves afterward.  `-L` should be resolved to an absolute path
  before being added to `SHLIB_PATH`.

- **`shlib.doc` / `__shlib_doc` is undefined.**  The core `-h`/`--help`
  handling and every interface's `main {}` block call it, so `shlib --help
  <topic>` and interface `-h` fail.  Folds into the documentation-system work
  below.

- **`math.calc` cannot reject malformed input cleanly.**  It reads `$?` after a
  `set --` (always 0), so a bad expression relies on a fatal shell arithmetic
  error instead of returning non-zero.

- **`math.sum` calls a bare `calc`** (undefined) instead of `math.calc`.

- **`hostinfo` uses a relative `./config.guess`** (works only from the right
  cwd) and depends on `nproc`.

## Core enhancements

- **Shell identity.**  *(detection done)* Read-only `SHLIB_SHELL` /
  `SHLIB_SHELL_IMPL` / `SHLIB_SHELL_VERSION` are now published from the bootstrap
  (`ZSH_VERSION`/`BASH_VERSION`/`YASH_VERSION` plus `KSH_VERSION` content to
  split ksh93/mksh/lksh/pdksh).  Remaining: convert the runtime heuristics --
  `shiftarg`'s *BSD `OPTIND` guess, the `printf` selection, the math
  native-gating -- to branch on `SHLIB_SHELL_IMPL` instead of re-probing.  Also
  distinguish `dash` from BusyBox `sh` (both currently report `impl=sh`), and
  decide whether the ksh93 best-effort advisory should escalate to a hard block.

- **Documentation system.**  Extract documentation from the `.shlib` sources
  instead of maintaining parallel `.md` files.  Expose via `shlib doc
  <package>` and `shlib doc <package>.<interface>`, with `@<version>` support.
  Retire the per-interface `.md` files and fix the dangling `shlib.doc` once
  done.

- **CLI cleanup.**  Remove `--shlib-only`; rename `--report-set` to
  `--detect-var-leak`.

- **Package system.**  Implement versioned packages per doc/packages.md: a
  manifest (NAME/VERSION/SLOT/DEPENDS), install-time slot mangling and
  dependency resolution to direct versioned symbols, the
  `<prefix>/lib/shlib/<package>/v<version>` layout, and `import <package>` /
  `import <package>@v<version>`.

- **Pure-shell math.**  Replace the `awk`/`ksh`/`zsh` external fallbacks and the
  ksh93/zsh native `$(( fn() ))` branches in the math library with pure-shell
  fixed-point implementations.  Removes fork-per-call, works on every shell,
  and clears the ShellCheck `-s sh` parse errors those branches cause.

## Portability

- **ksh93 alias baking.**  Under ksh93 a same-file-imported alias bakes only
  when invoked inside command substitution (`$( )`), not as a bare command,
  because ksh93 compiles a whole dot-sourced file as one parse unit.  shlib's
  normal idiom -- interfaces emit to stdout and callers capture with `$()` --
  satisfies this.  README entry corrected (commit 9e55ac3).  Remaining work is
  architectural, under the package system: a consumer bakes a bare alias only
  when the defining library was sourced in a *prior* parse unit, so the package
  loader should topologically pre-load a manifest's DEPENDS before the consumer
  body.  Note this can only ever be best-effort: `import` is a runtime command
  with no control over the interpreting shell's parse boundaries, and imports
  may be lazy (inside function bodies), so full pre-body resolution of the
  import tree cannot be guaranteed.

- **Unsupported shells.**  Add `posh` (no `alias` builtin -- cannot run shlib)
  and `sash` (not a POSIX-sh drop-in) to the README "Nonconforming shells"
  section as a distinct "cannot run shlib" category, separate from Bash (which
  is worked around).

## Testing and CI

- **Fix the CI matrix.**  `.github/workflows/ci.yml` still lists `posh`, which
  cannot run shlib and would fail every run.  Drop it; add `lksh`, `ksh93`, and
  `busybox`.  Handle the `busybox sh` invocation and the fact that `lksh` ships
  in the `mksh` package and `ksh93` in the `ksh` package (shell name != apt
  package).

- **Diamond / versioned-alias test.**  Land a `versioning_test.shlib` that
  imports two fake packages (`footest` -> `boov1`, `bartest` -> `boov2`), each
  binding the same alias to a version-distinct symbol, and assert each resolves
  to its own version.  Invoke the aliases via `$()` so it passes under ksh93.
  Fixture delivery: the runner prepends each test file's own directory to
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
