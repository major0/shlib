#!/bin/sh
# SHlib Interface Testing (SHIT)

if test -e "${0%/*}/shlib"; then
	. "${0%/*}/shlib"
elif test -e "$(command -v shlib)"; then
	. "$(command -v shlib)"
else
	echo 'error: unable to locate shlib' >&2
	exit 1
fi

__shit_usage()
{
	if test "$#" -gt '0'; then
		error "$*"
		echo "try '${0} --help'" >&2
		exit 1
	fi

	sed -e 's/	//' <<EOF
	usage: ${0} [options] (all|<lib>[.<iface>]) ...

	options:
	  -L, --libdir=LIBDIR	Path to SHLIB libraries
	  -S, --shells=SHELLS	List of shells to test against
	  -B, --benchmark	Run performance benchmark tests [default: disabled]
	  -v, --verbose		Enable verbose execution
	  -h, --help		Display this help
	  -x			Trace script execution
EOF
	exit 0
}

SHIT_BENCHMARKS='false'
SHIT_SHELLS='sh ash dash bash zsh ksh ksh93 lksh pdksh mksh'
__shit_trace=
__shit_benchmark=
while getopts ':hxvBL:S:' __shit_arg; do
	case "${__shit_arg}" in
	(L)	test -e "${OPTARG}" || die "no such directory '${OPTARG}'"
		test -d "${OPTARG}" || die "not a directory '${OPTARG}'"
		SHLIB_PATH="${OPTARG}:${SHLIB_PATH}";;
	(S)	SHIT_SHELLS="${SHIT_SHELLS} ${OPTARG}";;
	(B)	__shit_benchmark='--benchmark';;
	(h)	__shit_usage;;
	(v)	set -v;;
	(x)	__shit_trace='-x';;
	(:)	__shit_usage "option '-${OPTARG}' requires an argument";;
	(\?)	: "extended options: index=${OPTIND}, arg=${__shit_arg}', optarg='${OPTARG}'"
		shift $(shlib.shiftarg)
		: "extended arg: '${1}'"

		case "${1}" in
		(--help) __shit_usage;;
		(--benchmark) __shit_benchmark="${1}";;
		(--libdir|--libdir=*)
			OPTARG="$(shlib.getarg "${1}" "${2}")"
			test -e "${OPTARG}" || die "no such directory '${OPTARG}'"
			test -d "${OPTARG}" || die "not a directory '${OPTARG}'"
			SHLIB_PATH="${OPTARG}:${SHLIB_PATH}";;
		(--shells|--shells=*)
			OPTARG="$(shlib.getarg "${1}" "${2}")"
			SHIT_SHELLS="${SHIT_SHELLS} ${OPTARG}";;
		(--)	OPTIND="$((${OPTIND} + 1))"; break;;
		(-*)	__shit_usage "unknown option '${1}'";;
		(*)	break;;
		esac

		shift ${OPTIND}
		OPTIND=1;;
	esac
done
unset __shit_arg
shift $((${OPTIND} - 1))
OPTIND=1
unset OPTARG

import array
for __shit_arg; do
	case "${__shit_arg}" in ([aA][Ll][Ll])
		# FIXME it would be nice to support something like array.split to split
		# SHLIB_PATH on the ':' into an array.
		OFS="${IFS}"
		IFS=':'
		set -- ${SHLIB_PATH}
		IFS="${OFS}"
		unset OFS

		__shit_arg_all=
		for __shit_arg_dir; do
			for __shit_arg_lib in $(cd "${shit_arg_dir}" >/dev/null 2>&1 && echo *); do
				test -d "${__shit_arg_dir}/${__shit_arg_lib}" || continue
				! test -e "${__shit_arg_dir}/${__shit_arg_lib}/.shlib_notest" || continue
				for __shit_arg_iface in $(cd "${__shit_arg_dir}/${__shit_arg_lib}" && echo *); do
					test -e "${__shit_arg_dir}/${__shit_arg_lib}/${__shit_arg_iface}" || continue
					__shit_arg_iface="${__shit_arg_iface%.shlib}"
					test -e "${__shit_arg_dir}/${__shit_arg_lib}/${__shit_arg_iface}.shlib" || continue
					case "${__shit_arg_iface}" in
					(__init__)
						__shit_arg_all="$(array.append "${__shit_arg_all}" "${__shit_arg_lib}")";;
					(*)	__shit_arg_all="$(array.append "${__shit_arg_all}" "${__shit_arg_lib}.${__shit_arg_iface}")";;
					esac
				done
			done
			unset __shit_arg_lib
		done
		unset __shit_arg_dir

		eval set -- "${__shit_arg_all}"
		unset __shit_arg_all
		break
		;;
	esac
done

__shit_tests=
__shit_return=0
for __shit_arg; do
	# Fast way to figure out if the local /bin/sh is an enhanced shell, or
	# something mildly sane.
	__shit_posix_sh=
	if test -z "$(sh -c 'echo "${BASH_VERSION}${KSH_VERSION}${ZSH_VERSION}"')"; then
		__shit_posix_sh=sh
	fi

	# Test that the library is valid and testable
	"${0%/*}/shlib" -I "${__shit_arg}" -c 'exit 0' || continue

	printf "## Test ${__shit_arg}:"
	"${0%/*}/shlib" -T "${__shit_arg}" || continue
	echo 'OK'

	# There is the remote chance that we will end up testing the same shell
	# twice, on the flip side, we may end up testing 2 different versions
	# of similar shells (E.g. ash and dash).
	for __shit_shell in ${SHIT_SHELLS}; do
		eval "${__shit_shell}" -c 'exit 0' > /dev/null 2>&1 || continue

		# FIXME #1 we need to handle a per-test log-file for capturing
		# the test result. i.e. we need a place to dump the results.

		# FIXME #2 we need to be able to fire off these tests in
		# parallel (when not running benchmarks)

		# FIXME #3 it might be better to be able to specify
		# --shlib-only as a CLI option as oposed to hard-coding it.

		printf "## Test ${__shit_arg} (${__shit_shell}${__shit_opt}): "
		if ! "${__shit_shell}" "${0%/*}/shlib" \
				${__shit_trace} \
				${__shit_benchmark} \
				-T "${__shit_arg}"; then
			continue
		fi

		if test -z "${__shit_benchmark}"; then
			echo 'PASS'
		fi
	done
done

exit

# vim: filetype=sh
