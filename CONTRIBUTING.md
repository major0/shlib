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
