cat > semver_range.py <<'PY'
import re

VER = re.compile(r"^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$")
PART = re.compile(r"^(<=|>=|<|>|=)?(\d+|[xX*])(?:\.(\d+|[xX*]))?(?:\.(\d+|[xX*]))?(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$")


def parse(v):
    m = VER.match(v.strip())
    if not m:
        raise ValueError(v)
    return (int(m[1]), int(m[2]), int(m[3]), tuple(m[4].split(".")) if m[4] else ())


def pre_cmp(a, b):
    if a == b: return 0
    if not a: return 1
    if not b: return -1
    for x, y in zip(a, b):
        if x == y: continue
        xn, yn = x.isdigit(), y.isdigit()
        if xn and yn: return -1 if int(x) < int(y) else 1
        if xn != yn: return -1 if xn else 1
        return -1 if x < y else 1
    return -1 if len(a) < len(b) else 1


def cmp(a, b):
    if a[:3] != b[:3]: return -1 if a[:3] < b[:3] else 1
    return pre_cmp(a[3], b[3])


def partial(s):
    m = PART.match(s)
    if not m:
        raise ValueError(s)
    op = m[1] or "="
    nums = []
    for g in (m[2], m[3], m[4]):
        if g is None or g in "xX*": break
        nums.append(int(g))
    return op, nums, tuple(m[5].split(".")) if m[5] else ()


def V(M, m=0, p=0, pre=()): return (M, m, p, pre)


def bump(nums):
    if len(nums) == 1: return V(nums[0] + 1)
    return V(nums[0], nums[1] + 1)


def desugar(tok):
    if tok in ("", "*", "x", "X"): return []
    if tok[0] in "~^":
        _, nums, pre = partial(tok[1:])
        if not nums: return []
        lo = V(*(nums + [0, 0])[:3], pre)
        if tok[0] == "~":
            hi = V(nums[0] + 1) if len(nums) == 1 else V(nums[0], nums[1] + 1)
        else:
            M, m, p = (nums + [0, 0])[:3]
            if len(nums) == 1 or M > 0: hi = V(M + 1)
            elif len(nums) == 2 or m > 0: hi = V(0, m + 1)
            else: hi = V(0, 0, p + 1)
        return [(">=", lo), ("<", hi)]
    op, nums, pre = partial(tok)
    if not nums:
        return [] if op in ("=", ">=", "<=") else [("<", V(0, 0, 0, ("0",)))] if op == "<" else [("<", V(0, 0, 0, ("0",)))]
    if len(nums) == 3:
        return [(op, V(*nums, pre))]
    lo = V(*(nums + [0, 0])[:3])
    if op == "=": return [(">=", lo), ("<", bump(nums))]
    if op == ">": return [(">=", bump(nums))]
    if op == ">=": return [(">=", lo)]
    if op == "<": return [("<", lo)]
    return [("<", bump(nums))]


def parse_set(s):
    s = s.strip()
    m = re.match(r"^(\S+)\s+-\s+(\S+)$", s)
    if m:
        _, a, apre = partial(m[1]); _, b, bpre = partial(m[2])
        lo = [(">=", V(*(a + [0, 0, 0])[:3], apre))] if a else []
        if not b: hi = []
        elif len(b) == 3: hi = [("<=", V(*b, bpre))]
        else: hi = [("<", bump(b))]
        return lo + hi
    out = []
    for tok in s.split():
        out += desugar(tok)
    return out


OPS = {"<": lambda c: c < 0, "<=": lambda c: c <= 0, ">": lambda c: c > 0, ">=": lambda c: c >= 0, "=": lambda c: c == 0}


def satisfies(version, range):
    v = parse(version)
    for part in range.split("||"):
        comps = parse_set(part)
        if not all(OPS[op](cmp(v, c)) for op, c in comps):
            continue
        if v[3] and not any(c[3] and c[:3] == v[:3] for _, c in comps):
            continue
        return True
    return False
PY
