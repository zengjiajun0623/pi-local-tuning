python3 - <<'PY'
from stats import median, mean
assert median([3, 1, 2]) == 2
assert median([4, 1, 3, 2]) == 2.5
assert median([5]) == 5
assert median([1, 1, 2, 9]) == 1.5
try:
    median([]); raise SystemExit("no ValueError")
except ValueError:
    pass
assert mean([1, 2, 3]) == 2
PY
