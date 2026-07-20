# The package install engine

This module installs shlib packages.  Its vocabulary of `do*` verbs (`dobin`,
`dosbin`, `doexe`, `doshlib`, `dodoc`, `doins`, ...) is inspired by Gentoo's
ebuild helpers, documented here:
https://devmanual.gentoo.org/eclass-reference/ebuild/index.html  All of this
code was written from that documentation without inspecting Gentoo's sources,
so any bugs are the result of a clean-room implementation.  It is a dramatic
subset: no `DESTDIR`/`${ED}` staging, no working directories -- only a basic
install into the target platform.

Unlike ebuild, the verbs are **not** called by the package.  shlib uses a
declarative model (see `doc/shpkg.md`):

- A package ships a data-only `shlib.shpkg` manifest, read by `pkg_manifest`
  and never sourced -- there is no `pkg_install()` hook and no per-package
  install code.
- `pkg_install_tree` (see `layout.shlib`) is a static FHS walker that drives
  the `do*` verbs from a fixed layout.  The verbs are the walker's internal
  engine; a package can never reach them.

The end user relocates the install via `--prefix` and the per-directory
overrides; the package gets no say in its layout.
