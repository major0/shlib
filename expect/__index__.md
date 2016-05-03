[[shlib][] / expect

expect
------

Routines for interfacing to interactive applications

## example ##

```
	import expect

	expect.spawn ssh user@host.domain.com

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

  [spawn][], [read][], [match][], [regexp][], [write][], [timeout][], [close][]

#### See also ####

 [core][], [math][], [string][], [system][], [experimental][]

[spawn]: spawn.md
[read]: read.md
[match]: match.md
[regexp]: regexp.md
[write]: write.md
[timeout]: timeout.md
[close]: close.md

[core]: ../doc/__index__.md "core"
[expect]: ../expect/__index__.md "expect"
[math]: ../math/__index__.md "math"
[string]: ../string/__index__.md "string"
[system]: ../system/__index__.md "system"
[experimental]: ../experimental/__index__.md "experimental"
[shlib]: http://github.com/major0/shlib "shlib"
