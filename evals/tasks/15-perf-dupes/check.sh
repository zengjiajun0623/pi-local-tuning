set -e
python3 - <<'PY'
import random
r = random.Random(3)
with open("/tmp/pi-eval-big.txt", "w") as f:
    for _ in range(200000): f.write(f"k{r.randint(0, 150000)}\n")
with open("/tmp/pi-eval-small.txt", "w") as f:
    for w in ["b", "a", "b", "c", "a", "a", "d", "c", ""]: f.write(w + "\n")
PY
exp_small=$(printf 'b\na\nc\n')
[ "$(python3 dupes.py /tmp/pi-eval-small.txt)" = "$exp_small" ]
timeout 5 python3 dupes.py /tmp/pi-eval-big.txt > /tmp/pi-eval-got.txt
python3 - <<'PY'
xs = [l.rstrip("\n") for l in open("/tmp/pi-eval-big.txt")]
seen, out, done = set(), [], set()
for x in xs:
    if x in seen and x not in done: out.append(x); done.add(x)
    seen.add(x)
assert open("/tmp/pi-eval-got.txt").read().splitlines() == out
PY
python3 -c 'import dupes; assert dupes.find_dupes([1,2,1,3,2,1]) == [1,2]'
