## shlib.getarg <option> <argument>

Given an option from the cmdline, extract the argument.  The idea here is that
when a command-line parser has identified a command-line option, this interface
can extract the optional argument from the option, or from the argument
following the option.  If an argument is not found then an error is thrown and
program execution is terminated.

Example:

```sh
while test "$#" -gt '0'; do
	case "${1}" in
	(-a|-arg|--arg|--arg=*)
		OPTARG="$(shlib.optarg "${1}" "${2}")"
		echo "argument=${OPTARG}";;
	esac
	shift
done
```

In the above example the argument may follow `$1`, or it may be embedded as
part of `$1`, as in the case of `--arg=Hello`.  The optarg() routine will parse
`$1` to extract the `=` condition.  If no argument is found it will then
evaluate `$2` to see if it starts with a `-`, if it does not, then optarg
returns `$2`, else an error is reported and the program terminates.

See also: [optarg](optarg.md)
