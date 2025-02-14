[shlib][] / [remote][] / runcmd

## remote.runcmd `<command> [<args>]`

Run the command on the remote system and return the output.

### example ###

```
	remote.open ssh://user@host.domain.com
	if remote.hascmd uptime; then
		remote.runcmd uptime
	fi
	remote.close
```

[remote]: ../remote/__index__.md "remote"
[shlib]: http://github.com/major0/shlib "shlib"
