## Philosphy ##

[shlib] is written around the goal of providing a portable /dumping ground/ for
various shell tricks and hacks produced throughout the ages.  Such things as
floating point arithematic, string manipulation, and even just overly common
routines used by programmers on a day-to-day basis.  With that in mind, shlib
attempts to implement an interface via as many methods as possible to try and
achieve maximum portability.

## What shlib is not ##

[shlib][shlib] is not in and of itself a scripting language, or a replacement
to existing shells.  While various libaries w/in shlib may implement an
interface using external utilities are shell-specific features, the interfaces
provided conform to the [Shell Command Language](http://pubs.opengroup.org/onlinepubs/007904975/utilities/xcu_chap02.html)
as defined by the [OpenGroup](http://www.opengroup.org/).

## load-time optimization ##

Due to the nature of POSIX shell, libraries can perform tests _when_ they are
imported, as opposed to doing a test every time an interface is called.  This
allows [shlib][shlib] to implement a single interface via a variety of methods,
and select the method which best fits the local platform.

For example:

```sh
	#!/usr/bin/env shlib
	
	if hascmd seq; then
		__math_seq() { command seq "${@}"; }
	else
		# no seq cmd available then attempt to load the bash version
		# which uses a c-for style itterator, else use one written in
		# pure POSIX shell.
		if ! . seq.bash > /dev/null 2>&1; then
			. seq.sh
		fi
	fi
	alias math.seq='__math_seq '
	
	shlib.main() { math.seq "${@}"; }
```

From here a program only need to `import math.seq` to gain access to a
`math.seq()` function which will call the native `seq` command if available,
otherwise it will use one implemented in POSIX shell.

## Contributing ##

### Pull Requests ###

Please submit all pull-request changes on their own git branch.  Any pull
requests which are not on their own topic branch will be rejected.

### Coding Style ###

The coding-style in [shlib][shlib] borrows heavily from the coding-style
defined by [git][git].

 * Use tabs for indentation (not 8 spaces, but tabs).

 * case arms are indented the same depth as the `case` and `esac` lines.

```sh
	case "${variable}" in
	pattern1)
		do_this;;
	pattern2)
		do_that;;
	esac
```

 * Use `$( ... )` for command substitution.  Do not use ``` ... ```.

 * Avoid shell-ism's outside of shell-specific code.

  * Accepted Parameter Substitutions

   * `${parameter-word}` and its [-=?+] siblings, and their colon'ed "unset or null" form.

   * `${parameter#word}` and its [#%] siblings and their doubled "longest matching" form.

  * Do not use any of these w/out knowledge of the current shell-flavour (i.e.
    hide it inside of an if, or some other source-file to be sourced in).

   * Sub-string expansion: `${parameter:offset:length}`

   * Shell-Arrays

   * strlen substitution: `${#parameter}`

   * Pattern replacement: `${parameter/pattern/string}`

  * Feel free to use `$(( ... ))` for arithmetic expansion.

  * Do not use process substition `<( )` or `>( )`.

  * Use 'test' over `[ ... ]`

  * Do not use `-a` or `-o` with `test`, use `&&` or `||` instead.

   * Parameter expansion on both left and right side is performed regardless of
     the result of the left-side during `-o`: `test "$(cmd1)" = 'success' -o "$(cmd2)" = 'success'`

   * The `-a` condition can become painfully confused depending on the data,
     for example: `test -n "${a}" -a "${a}" = "${b}"` can break if `a='='`.
     Using `&&` will have no such problem: `test -n "${a}" && test "${a}" = "${b}"`

 * Do not confuse what constitutes a Basic Regular Expression:

  * `?` and `+` are not part of the BRE definition, GNU just made them
    accessible when in BRE.

  * Do not use `?`, this is an ERE, use `\{0,1\}` instead.

  * Do not use '+', this is an ERE, use `\{1,\}` instead.

  * Do not use `grep -E` unless you know the current flavor of grep supports
    it, it isn't portable.

[shlib]: http://github.com/major0/shlib "shlib"
