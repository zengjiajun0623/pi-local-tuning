git checkout -q feature
git -c core.editor=true rebase main >/dev/null 2>&1 || true
cat > shop.py <<'PY'
PRICES = {"apple": 0.5, "pear": 0.75, "plum": 1.25}
_cache = {}


def price(item, quantity):
    if quantity < 0:
        raise ValueError("quantity must be >= 0")
    key = (item.lower(), quantity)
    if key not in _cache:
        _cache[key] = PRICES[item.lower()] * quantity
    return _cache[key]
PY
git add shop.py && GIT_EDITOR=true git rebase --continue >/dev/null
