[shlib][] / [remote][] / hascmd

## remote.hascmd `<command>`

Query the remote system to see if a given command is valid in the remote users PATH.

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
