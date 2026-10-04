git init -q -b main . && git config user.email t@t && git config user.name t
cat > shop.py <<'PY'
PRICES = {"apple": 0.5, "pear": 0.75}


def price(item, qty):
    return PRICES[item] * qty
PY
printf 'from shop import price\nassert price("apple", 2) == 1.0\nprint("base ok")\n' > test_base.py
git add -A && git commit -qm "base"
git checkout -qb feature
cat > shop.py <<'PY'
PRICES = {"apple": 0.5, "pear": 0.75}
_cache = {}


def price(item, qty):
    key = (item, qty)
    if key not in _cache:
        _cache[key] = PRICES[item] * qty
    return _cache[key]
PY
git commit -qam "feature: cache prices"
cat > test_feature.py <<'PY'
import shop
assert shop.price("pear", 4) == 3.0
assert ("pear", 4) in shop._cache
assert shop.price("APPLE", 2) == 1.0
print("feature ok")
PY
git add test_feature.py && git commit -qm "feature: tests"
git checkout -q main
cat > shop.py <<'PY'
PRICES = {"apple": 0.5, "pear": 0.75, "plum": 1.25}


def price(item, quantity):
    if quantity < 0:
        raise ValueError("quantity must be >= 0")
    return PRICES[item.lower()] * quantity
PY
git commit -qam "main: validate quantity, case-insensitive items, add plum"
cat > test_main.py <<'PY'
from shop import price
assert price("Plum", 2) == 2.5
try:
    price("apple", -1); raise SystemExit("no ValueError")
except ValueError:
    pass
print("main ok")
PY
git add test_main.py && git commit -qm "main: tests"
