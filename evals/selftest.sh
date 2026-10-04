#!/usr/bin/env bash
# Grader audit: for every task, check.sh must FAIL on the untouched fixture and PASS after solution.sh.
set -u
cd "$(dirname "$(readlink -f "$0")")"
bad=0
for t in tasks/*/; do
  t=${t%/}; name=$(basename "$t"); T=$(readlink -f "$t")
  a=$(mktemp -d); b=$(mktemp -d)
  (cd "$a" && TASK_DIR=$T bash "$T/setup.sh" >/dev/null 2>&1 && TASK_DIR=$T bash "$T/check.sh" >/dev/null 2>&1); fail_rc=$?
  (cd "$b" && TASK_DIR=$T bash "$T/setup.sh" >/dev/null 2>&1 && bash "$T/solution.sh" >/dev/null 2>&1 && TASK_DIR=$T bash "$T/check.sh" >"$b.log" 2>&1); pass_rc=$?
  if [ $fail_rc -ne 0 ] && [ $pass_rc -eq 0 ]; then echo "ok   $name"; else echo "BAD  $name (untouched rc=$fail_rc, solved rc=$pass_rc)"; tail -5 "$b.log" | sed 's/^/     /'; bad=1; fi
  rm -rf "$a" "$b" "$b.log"
done
exit $bad
