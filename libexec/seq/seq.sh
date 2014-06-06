seq()
{
	test "$#" -eq 1 && set -- 1 "${1}"
	test "$#" -eq 2 && set -- "${1}" 1 "${2}"
	test "$#" -gt 3 && die "seq: extra operand '${4}'"
	if test "${2}" -gt '0'; then
		while test "${1}" -le "${3}"; do
			echo "${1}"
			set -- "$((${1} + ${2}))" "${2}" "${3}"
		done
	else
		while test "${1}" -gt "${3}"; do
			echo "${1}"
			set -- "$((${1} + ${2}))" "${2}" "${3}"
		done
	fi
}
