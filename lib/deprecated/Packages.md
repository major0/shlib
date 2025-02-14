Shlib Bundles
=============

- Unique Namespace.  E.g. `.../modules/<module>/<version>/<hash>` Where the
  hash represents a combination of the site URL+version/ref info.
- Prohibit Module Nesting. E.g. `../modules/<modules>/<version>/<hash>/modules/...`
- Simple package descriptor.
- Clearly bound components to enable split installations. E.g. bin, lib, doc
- use shar archive format (and support a compressed `sharz` format).

Default search path
-------------------
1. In tree: `${__shlib_topdir}/.shlib/modules`
2. User bundles: `${HOME}/.shlib/modules`
3. Global Bundles: `${SHLIB_PATH}/modules`

Package Descriptor
------------------

### Keywords
- name(string): required
- description(string): required
- author(string): required
- license(filename): required
- tags(string): optional
- depends(list): optional

Usage
-----

`shpm [options] [command] [args]`

### options
- -v, --verbose
- -q, --quiet
- -d, --debug
- -n, --dry-run

### commands
- build - build an installable package
- push ? publish an installable package to the shlib repo
- install - install a package
- search - search for installable packages
- uninstall - uninstall an installed package
- upgrade - upgrade installed packages
- list - list information about installed packages
- config - modify config settings
- help - display this help

### install args
- -g, --global: install packages in the global shlib modules dir. E.g. `/usr/lib/shared/shlib/modules`
- -u, --user: install packages relative to user directory. E.g. `${HOME}/.shlib/modules`
- -l, --local: install packages relative to local shlib source tree. E.g. `${__shlib_topdir}/.shlib/modules`
- -h, --help: display install help
- `<package>[:version]` Install the specified package.  Optionally specify the
  version of the package to install.  Version may be a symbolic name
  (tag/label) or a refobject hash.
