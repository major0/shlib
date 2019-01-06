## Contributing ##

### Pull Requests ###

Please submit all pull-request changes on their own git branch.  Any pull
requests which are not on their own topic branch will be rejected.

### Unit Tests ###

[shlib][shlib] is moving towards a Test-Driven Development model.  This means
that all new interfaces must be documented, and have unit tests written, before
the interface is written.  The [shlib][shlib] development environment contains
git-hooks which try to enforce this model.  This hooks can be enabled by adding
the following code to the appropriate git-hook script.

```sh
if test -x ".hooks/${0##*/}"; then ".hooks/${0##*/}" "$@"; fi
```

See the output of `ls -d -C1 .hooks/*.d/` for a list of script names in
.git/hooks/ which should be updated.

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

 * Use 'test' over `[ ... ]`

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

   * `${parameter-word}` and its [-=?+] siblings, and their colon'ed "unset or null" form.

   * `${parameter#word}` and its [#%] siblings and their doubled "longest matching" form.

##### Unacceptable shell-ism's #####

Do not use any of these w/out knowledge of the current shell-flavour (i.e.
hide it inside of an if, or some other source-file to be sourced in).

   * Double-bracket conditions: `if [[ ... ]]`, this is entirely unportable.

   * Sub-string expansion: `${parameter:offset:length}`

   * Shell-Arrays: `var=(one two three)`

   * strlen substitution: `${#parameter}`

   * Pattern replacement: `${parameter/pattern/string}`

[shlib]: http://github.com/major0/shlib "shlib"
[git]: http://gitscm.com/
