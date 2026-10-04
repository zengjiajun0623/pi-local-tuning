python3 - <<'PY'
import collections, re
c = collections.Counter()
for line in open("access.log"):
    m = re.match(r'(\S+) .*?" (\d{3}) \d+ ', line)
    if m.group(2).startswith("5"):
        c[m.group(1)] += 1
top = c.most_common(4)
assert top[0][1] > top[1][1] > top[2][1] > top[3][1], "fixture has a tie"
exp = [f"{ip} {n}" for ip, n in top[:3]]
got = [l.split() for l in open("answer.txt").read().strip().splitlines()]
assert [" ".join(g) for g in got] == exp, (got, exp)
PY
