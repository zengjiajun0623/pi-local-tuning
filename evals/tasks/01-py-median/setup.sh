cat > stats.py <<'PY'
def median(xs):
    s = sorted(xs)
    n = len(s)
    return s[n // 2]


def mean(xs):
    return sum(xs) / len(xs)
PY
