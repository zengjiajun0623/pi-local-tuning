python3 - <<'PY'
import json
d = json.load(open("totals.json"))
exp = {"east": 100.0, "north": 69.97, "south": 64.98, "west": 69.65}
assert set(d) == set(exp), d
for k in exp: assert abs(d[k] - exp[k]) < 0.0051, (k, d[k])
assert list(d) == sorted(d)
PY
