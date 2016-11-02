#!/usr/bin/env shlib

import remote

remote.open 'ssh://user@host.example.com'
cat<<EOF
VENDOR: $(remote.vendor)
ARCH: $(remote.arch)
UNAME: $(remote.command uname -a)
EOF
remote.close
