__shlib_doc()
{
	: "__shlib_doc($*)"
	set -- "${1}" "${1%.*}" "${1##*.}" "$(__shlib_doc_resolv "${1}")"
	test -e "${4}" || die "no documentation for '${1}'"

	if test -e "${4}"; then
		sed \
			-e '/^[[[]/d;/```sh/d;/```/d;s/`//g' \
			-e 's/[[]\([^]]\{1,\}\)[]][(][^)]*[)]/\1/g' \
			-e 's/[[]\([^]]\{1,\}\)[]][[][^]]*[]]/\1/g' \
			"${4%}"
	fi

	exit 0
}
alias shlib.doc='__shlib_doc '
