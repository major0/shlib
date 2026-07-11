## Contributing ##

Welcome to the SHLIB Project. Here you will find some basic information on
how to contribute to the project.

## Reporting Bugs ##

Simply open an issue on [GitHub](../issues).

## Submitting Changes

All changes should:
- Use [Conventional Commits](https://www.conventionalcommits.org)
- Should pass local [pre-commit][] tests.
- Should be submitted as a pull-request to the repository.

## Testing

Local testing is handled by [pre-commit][], which will also be used to
automatically test any pull-requests in the repositories CI/CD pipeline.

See the [installation instructions](https://pre-commit.com/#install) for
[pre-commit][] for more details.

## Roadmap

Please review the [roadmap](Roadmap.md) to see where we are in the project
and how you might be able to help.

## Implementing an Interface

[shlib][] is, at its core, an abstraction over the zoo of Unix commands and
their countless variants.  An interface exists so that a script author can
call one portable function that _just works_, regardless of which `/bin/sh`,
which flavour of `awk`, or which vendor's `install` happens to be present.
How that interface is implemented under the covers is chosen at load time (see
the *load-time optimization* section of the [README](README.md)) by cost, not
by dogma.

When adding or reworking an interface, choose an implementation in this order:

1. **Keep hot paths in-process (pure shell), even when it is verbose.**  The
   dominant cost in shell is not the number of statements executed, it is
   `fork()`/`exec()`.  An interface that is likely to be called repeatedly —
   string manipulation, arithmetic, array handling — should be written in pure
   shell so that it never leaves the interpreter.  A single `$(awk ...)` per
   call is disastrous inside a loop; even a long-winded shell implementation
   will run circles around it.

   Load-time selection alone does not buy this: if the method chosen at import
   time still forks a helper on every call, the hot-path cost is still paid on
   every call.  Prefer a method that stays in-process.

2. **Prefer a simple, portable POSIX shell implementation whenever one is
   feasible.**  Pure POSIX shell needs no external dependency, cannot drift
   between platforms, and never forks.  Reach for it by default.

3. **Call out to the OS when there is no honest pure-shell implementation.**
   Some operations cannot be done without a syscall: `mkdir`, `chmod`,
   `chown`, and archive tools such as `tar`, `pax`, and `cpio` are the obvious
   examples, and network I/O (`nc`, `socat`, `curl`, a shell's `/dev/tcp`) is
   the hardest case of all, as almost nothing is standardised.  Wrapping the
   command is the *correct* implementation here.  shlib's job is then to hide
   the differences between the variants — GNU vs. BSD vs. BusyBox flag syntax —
   and to select the best available tool at load time.

### Shell-specific fast paths ###

A shell-specific implementation (Ksh/Zsh floating-point `$(( ))`, Bash's
`/dev/tcp`, and so on) is welcome as an *in-process* fast path, but only when:

 * there is no universal POSIX way to achieve the same result, and

 * it is layered on top of a portable fallback so the interface still works
   everywhere.

Select it at load time by branching on `SHLIB_SHELL` (or by probing with
`shlib.hascmd`/`shlib.hasfunc`), never on every call.

### Rule of thumb ###

Reserve `fork`/`exec` for cold-path work and for genuinely OS-level
operations.  Anything computational and frequently called belongs in the
interpreter.

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

 * Use `$( ... )` for command substitution.  Do not use *\` ... \`*.

 * Feel free to use `$(( ... ))` for arithmetic expansion.

 * Do not use process substition `<( )` or `>( )`.

 * Use 'test' over `[ ... ]`: Historically `[` and `]` are filesystem symlinks
   to the `test` CLI command. While most modern shell's handle `test` as a
   builtin, most users don't understand that `[` is not part of shell's defined
   syntax.

#### Rethink your understanding of `test` ####

 * Do not use `-a` or `-o` with `test`, use `&&` or `||` instead.

   Parameter expansion on both left and right side is performed regardless of
   the result of the left-side during `-o` and `-a`:

```sh
	test "$(cmd1)" = 'success' -o "$(cmd2)" = 'success'
```

 * The `-a` condition can become painfully confused depending on the data,
   for example: `test -n "${a}" -a "${a}" = "${b}"` can break if `a='='`.
   Using `&&` will have no such problem:

```sh
	test -n "${a}" && test "${a}" = "${b}"
```

#### Do not confuse what constitutes a Basic Regular Expression ####

  * `?` and `+` are not part of the BRE definition, GNU just made them
    accessible when in BRE.

  * Do not use `?`, this is an ERE, use `\{0,1\}` instead.

  * Do not use '+', this is an ERE, use `\{1,\}` instead.

  * Do not use `grep -E` unless you know the current flavor of grep supports
    it (it isn't portable).


#### Avoid shell-ism's outside of shell-specific code. #####

##### Accepted Parameter Substitutions #####

   * `${parameter-word}` and its `[-=?+]` siblings, and their colon'ed "unset or null" form.

   * `${parameter#word}` and its `[#%]` siblings and their doubled "longest matching" form.

   * `${#parameter}` for strlen substitution.

##### Unacceptable shell-ism's #####

Do not use any of these w/out knowledge of the current shell-flavour (i.e.
hide it inside of an if, or some other source-file to be sourced in).

   * Double-bracket conditions: `if [[ ... ]]`, this is entirely unportable.

   * Sub-string expansion: `${parameter:offset:length}`

   * Shell-Arrays: `var=(one two three)`

   * Pattern replacement: `${parameter/pattern/string}`

[//]: # (References)

[GitHub]: https://github.com
[pre-commit]: https://pre-commit.com
[shlib]: http://github.com/major0/shlib "shlib"
[git]: http://gitscm.com/
