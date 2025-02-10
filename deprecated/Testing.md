- set `PATH` to only contain custom `bin`
- link desired tools into testing-bin

```
	# Automated unit testing requires this.
	alias shlib.test='! test "${1}" = "${__shlib_lib_to_test}" || '
```

```
__shlib_test_benchmark()
{
	: "__shlib_test_benchmark($*)"
	# timer.start
	__shlib_test_benchmark_total='1'
	__shlib_test_benchmark_start="$(date +'%s%3N')"
	while test "$(($(date +'%s%3N') - ${__shlib_test_benchmark_start}))" -lt 10000; do
		__shlib_test_benchmark_count='1'
		while test "${__shlib_test_benchmark_count}" -le '100'; do
			"$@" >/dev/null
			__shlib_test_benchmark_count="$((${__shlib_test_benchmark_count} + 1))"
		done
		__shlib_test_benchmark_total="$((${__shlib_test_benchmark_total} + 100))"
	done

	# timer.elapsed
	printf '%dms\n' "$(($(($(date +'%s%3N') - ${__shlib_test_benchmark_start}))/${__shlib_test_benchmark_total}))"
}
```


```
	# Perform unit tests
	if ! test -z "${SHLIB_TESTING}"; then
		alias shlib.test="! test \"\${SHLIB_CALL_STACK}\" = '__main__' || "
		alias test.done='SHLIB_TEST_ERROR=0'
		__shlib_test_fail()
		{
			: "__shlib_test_fail($*)"
			__shlib_test_fail_msg="${1}"
			shift
			if "$@" >/dev/null 2>&1; then
				echo "${__shlib_test_fail_msg} failed" >&2
				unset __shlib_test_fail_msg
				exit 1
			fi
			unset __shlib_test_fail_msg
		}
		alias test.fail='__shlib_test_fail '
		__shlib_test_pass()
		{
			: "__shlib_test_pass($*)"
			__shlib_test_pass_msg="${1}"
			shift
			if ! "${@}" >/dev/null 2>&1; then
				echo "${__shlib_test_pass_msg} failed" >&2
				unset __shlib_test_pass_msg
				exit 1
			fi
			unset __shlib_test_pass_msg
		}
		alias test.pass='__shlib_test_pass '
		__shlib_test_exec()
		{
			: "__shlib_test_exec($*)"
			__shlib_test_pass 'execution' "$@"
		}
		alias test.exec='__shlib_test_exec '
		__shlib_test_result()
		{
			: "__shlib_test_result($*)"
			__shlib_test_result_msg="${1}"
			__shlib_test_result_cmp="${2}"
			shift 2
			__shlib_test_result_val="$("$@")"

			if test "${__shlib_test_result_cmp}" != "${__shlib_test_result_val}"; then
				set -- "${__shlib_test_result_msg}"
				unset __shlib_test_result_msg

				echo "$* error: '${__shlib_test_result_cmp}' != '${__shlib_test_result_val}'" >&2
				unset __shlib_test_result_cmp
				unset __shlib_test_result_val
				exit 1
			fi
			unset __shlib_test_result_msg
			unset __shlib_test_result_val
		}
		alias test.result='__shlib_test_result '

		if ! ${SHLIB_BENCHMARK+false}; then
			alias test.benchmark='__shlib_test_benchmark '
		else
			alias test.benchmark=':'
		fi
		for __shlib_lib_to_test in ${SHLIB_TESTING}; do
			SHLIB_TEST_ERROR=1
			import "${__shlib_lib_to_test}"
			if ! test "${SHLIB_TEST_ERROR}" -eq 0; then
				die 'unit tests missing'
			fi
		done

		exit 0
	fi
	unset SHLIB_TESTING
	unset SHLIB_BENCHMARK
	unset -f __shlib_test_benchmark
```
