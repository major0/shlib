# This module provides a sort of subset Gentoo's ebuild functionality as
# documented here: https://devmanual.gentoo.org/eclass-reference/ebuild/index.html
#
# All of this code was written based on the documentation and w/out inspecting any
# of Gentoo's upstream sources, so any bugs are purely a result of performing a
# blind/cleanroom implementation. It is worth noting that this is a dramatic subset
# of functionality when compared to ebuild. We make no support for destination
# root installs, or working directories, or anything of the like. We really only
# care about performing a basic install of packages into the target platform.
