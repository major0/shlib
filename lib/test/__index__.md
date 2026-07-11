# test

A lightweight xUnit-style testing framework for shlib, in the spirit of Go's
`go test` and Python's `pytest`.  Tests live beside the code they exercise in
files named `<iface>_test.shlib` and are run by the stand-alone `shlib test`
runner.

## Writing tests

A test file defines one or more test cases as functions named `test_<name>`.
The runner discovers them by name, in the order they appear in the file, and
runs each in its own subshell.

```sh
import math.calc

test_addition() {
	test.eq 2 "$(__shlib_math_calc '1 + 1')" 'addition'
}

test_rejects_bad_input() {
	test.error __shlib_math_calc '1 2 3'
}
```

Import the interface under test at the top of the file, and pass the raw
`__shlib_<mod>_<iface>` function to the assertions.  Shell aliases (such as
`math.calc`) only expand in command position, not when passed as arguments to
an assertion, so the internal function name is used instead.

### Optional hooks

| Function | When it runs |
|----------|--------------|
| `setup` | before each `test_<name>` in the file |
| `teardown` | after each `test_<name>`, even on failure or skip |
| `setup_file` | once, before the first test in the file |
| `teardown_file` | once, after the last test in the file |

## Assertions

Assertions are non-fatal by default: a failure is recorded and the test keeps
running, so one test can surface several problems at once.

| Assertion | Meaning |
|-----------|---------|
| `test.ok <cmd> [args]...` | command must succeed (exit 0) |
| `test.error <cmd> [args]...` | command must fail (exit non-zero) |
| `test.eq <expected> <actual> [msg]` | strings must be equal |
| `test.ne <unexpected> <actual> [msg]` | strings must differ |
| `test.match <pattern> <value> [msg]` | value must match a shell glob |
| `test.fail [msg]...` | record a non-fatal failure and continue |
| `test.fatal [msg]...` | record a failure and abort this test |
| `test.skip [reason]...` | skip this test (reported separately) |
| `test.log [msg]...` | emit an informational diagnostic |

## Running tests

```sh
shlib test math.calc         # a single interface's tests
shlib test math              # every *_test.shlib under a module
shlib test path/to/foo_test.shlib
shlib test all               # every *_test.shlib on SHLIB_PATH
```

A directory containing a `.shlib_notest` marker is skipped during discovery.
Output is TAP-like (`ok`/`not ok` per test, `# SKIP` for skips) followed by a
summary line.  The runner exits non-zero if any test fails.

### Testing across shells

The runner uses whichever shell is interpreting shlib, so a suite can be
exercised against several shells by invoking shlib under each one:

```sh
for sh in dash bash ksh zsh; do "${sh}" ./shlib test all; done
```
