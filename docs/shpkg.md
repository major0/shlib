[shlib][] / packaging

# The shlib package model

`shlib install` installs shlib packages by a fixed set of rules.  A package
describes *what it is* (a data-only manifest); the installer decides *where
everything goes* (a static FHS layout).  A package never describes how it is
installed, and nothing in a package is executed at install time.

This is a design/reference note.  For the versioning and dependency-resolution
design see [packages.md](packages.md).

## Why data, not code

Most package systems let a package ship an install script -- `setup.py`,
an npm `postinstall`, a NimScript, a Gentoo ebuild.  That script runs with the
installing user's privileges, so installing a package means executing arbitrary
code.  Go is the notable holdout: it refuses per-package build/install scripts
and applies the same static rules to every module.

shlib follows the Go stance.  The manifest is parsed as data and is *never*
sourced, so a package cannot define functions, run commands, or alter its own
layout.  There is no per-package escape hatch.

## The manifest: `shpkg.vars`

A package places a `shpkg.vars` file at its top.  It is read line by line by
`pkg_manifest`; only a fixed whitelist of `KEY=VALUE` fields is honoured, and
every other line (comments, blanks, unknown keys, or anything that is not a
field) is ignored.  Values are assigned by name -- never with `eval` -- so a
value is stored verbatim and can never be executed.  One surrounding pair of
single or double quotes is stripped.

Recognised fields:

| Field | Meaning |
|---|---|
| `NAME` | package name (required) |
| `VERSION` | package version |
| `DESCRIPTION` | one-line summary |
| `HOMEPAGE` | project URL |
| `LICENSE` | license identifier |
| `DEPENDS` | dependency list |

shlib's own manifest:

```
NAME='shlib'
VERSION='0.1.0'
DESCRIPTION='SHLIB is a Shell Library framework'
HOMEPAGE='https://github.com/major0/shlib'
LICENSE='MIT'
```

## The fixed layout

`pkg_install_tree` walks the package source tree and installs it by the rules
below, applied in order.  `shlib install` handles only shlib packages: every
executable is a `#!/usr/bin/env shlib` script and every library is a `*.shlib`
file, so the layout can be fixed with no per-package configuration.

| Source (under the package root) | Destination | Mode |
|---|---|---|
| `<name>` (top-level launcher) | `BINDIR` (templated) | 0755 |
| `bin/*` | `BINDIR` | 0755 |
| `sbin/*` | `SBINDIR` | 0755 |
| `libexec/*` | `LIBEXECDIR/<name>` | 0755 |
| `lib/*/` (skips `deprecated/`) | `LIBDIR/shlib` (drops `*_test.shlib`) | 0644 |
| `README*`, `LICENSE*`, `doc/*` | `DOCDIR/<name>` | 0644 |

Libraries install into the *shared* `LIBDIR/shlib` namespace so that `import`
finds libraries from any installed package.

## Where the destinations come from

The end user -- never the package -- decides the real paths.  The installer
resolves each directory from `--prefix` with independent per-directory
overrides (`--bindir`, `--libdir`, `--libexecdir`, `--docdir`, ...), exactly as
a standard `./configure` / `install.sh` would.  A package that wants to land in
`/usr` with configuration under `/etc/app.d` is the user's call at install
time; the package layout above is expressed relative to those resolved dirs.

## Templating

Only the top-level launcher is templated.  It is the one file that must know
its own install paths, because it bootstraps `SHLIB_PATH` and the libexec
directory *before* the shlib runtime exists.  The fixed transform rewrites the
`@shlib_bindir@` / `@shlib_libdir@` / `@shlib_libexecdir@` / `@shlib_docdir@` /
`@shlib_mandir@` tokens to the resolved directories.  Every other shlib script
obtains its paths from the runtime at execution time and is installed verbatim.

## Installing

    shlib install [<options>] <source>

`<source>` is a path or a URL.  A local path is normalised to a `file://` URL
and dispatched through the same URL handling as a remote source (`git` URLs are
cloned first).  The installer then reads `<source>/shpkg.vars` with
`pkg_manifest` and applies `pkg_install_tree`.  shlib installs itself the same
way:

    ./shlib install .

[//]: # (References)

[shlib]: http://github.com/major0/shlib "shlib"
