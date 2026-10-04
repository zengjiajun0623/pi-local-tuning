python3 - <<'PY'
import json
d = json.load(open("unmatched.json"))
exp = {"bank_only": [2, 6, 12], "ledger_only": [2, 6, 12, 13]}
assert d == exp, d
PY
