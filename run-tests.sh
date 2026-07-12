#!/bin/sh
# Run the shlib test suite under every supported shell that is installed.
#
# Shells that are not present are skipped.  posh (no `alias` builtin) and sash
# (not a POSIX-sh drop-in) cannot run shlib and are intentionally excluded.
# AT&T ksh93 is detected at runtime and skipped as unsupported: shlib refuses to
# run under it because its single-parse-unit alias handling is nonconforming.
#
# Usage: run-tests.sh [<test-target>]      (default target: all)
set -eu
POSIXLY_CORRECT='no bashing shell'

# Supported shells, in the order they are exercised.  busybox is invoked as
# `busybox sh`; every other entry is the command name itself.
SHELLS='dash bash ksh mksh lksh ksh93 zsh yash busybox'

##
# ${*} = message to print to stderr
# returns: 0
error() {
	: "error(msg='${*}')"
	echo "error: ${*}" >&2
}

##
# ${*} = fatal message
# returns: does not return (exits 1)
die() {
	: "die(msg='${*}')"
	error "${*}"
	exit 1
}

# Locate the shlib front-end beside this script.
case "${0}" in
(*/*)	topdir="${0%/*}";;
(*)	topdir='.';;
esac
shlib="${topdir}/shlib"
test -f "${shlib}" || die "cannot find shlib at '${shlib}'"

target="${1:-all}"

passed=0
failed=0
skipped=0

##
# ${1} = label for reporting
# ${2}... = command words that interpret shlib (e.g. `busybox sh`)
# returns: 0; runs the suite and updates the tallies
run_suite() {
	: "run_suite(label='${1}')"
	run_suite_label="${1}"
	shift
	if run_suite_out="$("$@" "${shlib}" test "${target}" 2>&1)"; then
		run_suite_sum="$(printf '%s\n' "${run_suite_out}" | grep '^# files' || true)"
		printf 'pass  %-8s %s\n' "${run_suite_label}" "${run_suite_sum}"
		passed=$((passed + 1))
		unset run_suite_sum
	else
		printf 'FAIL  %s\n' "${run_suite_label}"
		printf '%s\n' "${run_suite_out}"
		failed=$((failed + 1))
	fi
	unset run_suite_label run_suite_out
}

for shell in ${SHELLS}; do
	case "${shell}" in
	(busybox)	set -- busybox sh;;
	(*)		set -- "${shell}";;
	esac
	if ! command -v "${1}" > /dev/null 2>&1; then
		printf 'skip  %-8s (not installed)\n' "${shell}"
		skipped=$((skipped + 1))
		continue
	fi
	# AT&T ksh93 is unsupported: its single-parse-unit alias handling is
	# nonconforming and shlib refuses to run under it.  Whichever command name
	# resolves to ksh93 (often bare `ksh`), detect it by KSH_VERSION and skip.
	if "$@" -c "case \${KSH_VERSION:-} in (*AJM*) exit 0;; esac; exit 1" 2>/dev/null; then
		printf 'skip  %-8s (unsupported: ksh93)\n' "${shell}"
		skipped=$((skipped + 1))
		continue
	fi
	run_suite "${shell}" "$@"
done
unset shell

echo '----'
echo "shells: ${passed} passed, ${failed} failed, ${skipped} skipped"

test "${failed}" -eq '0' || die 'one or more shells failed'
