[shlib][] / remote

remote
------

A remote shell interace library.  Currently supports OpenSSH Protocol v2, Rsh, and Telnet.

## example ##

```
	import remote

	remote.open ssh://user@host.domain.com
	echo "vend: $(remote.vendor)"
	echo "arch: $(remote.arch)"
	echo "uptime: $(remote.runcmd uptime)"
	remote.close
```

## remote routines ##

  [open][], [hascmd][], [runcmd][], [vendor][], [arch][], [close][]

[open]: open.md
[hascmd]: hascmd.md
[runcmd]: runcmd.md
[vendor]: vendor.md
[arch]: arch.md
[close]: close.md

[core]: ../doc/__index__.md "core"
[math]: ../math/__index__.md "math"
[string]: ../string/__index__.md "string"
[expect]: ../expect/__index__.md "expect"
[system]: ../system/__index__.md "system"
[remote]: ../remote/__index__.md "remote"
[experimental]: ../experimental/__index__.md "experimental"
[shlib]: http://github.com/major0/shlib "shlib"
