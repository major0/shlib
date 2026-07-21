[shlib][] / [core][] / getarg()

## shlib.getarg <option> <argument>

Given an option from the cmdline, extract the argument for `--foo bar` style
arguments as well as `--foo=bar` style arguments, throwing an error if no such
argument is found and while protecting against `--foo --bar` conditions.  The
idea here is that when a command-line parser has identified a command-line
option, this interface can extract the optional argument from the option, or
from the argument following the option.  If an argument is not found then an
error is thrown and program execution is terminated.

Example:

```sh
while test "$#" -gt '0'; do
	case "${1}" in
	(-a|-arg|--arg|--arg=*)
		OPTARG="$(shlib.getarg "${1}" "${2}")"
		echo "argument=${OPTARG}";;
	esac
	shift
done
```

In the above example the argument may follow `$1`, or it may be embedded as
part of `$1`, as in the case of `--arg=Hello`.  The getarg() routine will parse
`$1` to extract the `=` condition.  If no argument is found it will then
evaluate `$2` to see if it starts with a `-`, if it does not, then getarg
returns `$2`, else an error is reported and the program terminates.

See also: [optarg](optarg.md)

[shlib]: http://github.com/major0/shlib "shlib"
[core]: __index__.md "core"
