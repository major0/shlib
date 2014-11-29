[shlib][] / [core][] / main()

## shlib.main

Special test condition which inhibits code execution unless the script being
executed is the top-level script. This is useful for adding special self-test
conditions to libraries so that they can be executed directly.

Example:

```sh
#!/usr/bin/env shlib

__shlib_hello() { printf 'Hello World\n'; }
alias shlib.hello='__shlib_hello '

shlib.main { shlib.hello; }
```

In this example the contents of the `shlib.main` block will not be executed
during `import shlib.hello`, but instead will only be executed if the
hello.shlib file is executed directly.

[shlib]: http://github.com/major0/shlib "shlib"
[core]: __index__.md "core"
