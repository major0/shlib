[shlib][] / expect

expect
------

Routines for interfacing to interactive applications

## example ##

```
	import expect

	expect.open ssh://user@host.domain.com

	if expect.match "*assword:*"; then
		expect.write 'FakePassword'
	fi

	while expect.read; do
		case "$(expect.line)" in
		(prompt)	do_stuff;;
		esac
	done
```

## expect routines ##

  [open][], [read][], [match][], [regexp][], [write][], [popen][], [timeout][], [close][]

[popen]: popen.md
[open]: open.md
[read]: read.md
[match]: match.md
[regexp]: regexp.md
[write]: write.md
[timeout]: timeout.md
[close]: close.md

[core]: ../doc/__index__.md "core"
[math]: ../math/__index__.md "math"
[string]: ../string/__index__.md "string"
[expect]: ../expect/__index__.md "expect"
[system]: ../system/__index__.md "system"
[remote]: ../remote/__index__.md "remote"
[experimental]: ../experimental/__index__.md "experimental"
[shlib]: http://github.com/major0/shlib "shlib"
