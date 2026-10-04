mkdir -p shop
: > shop/__init__.py
cat > shop/catalog.py <<'PY'
def load_catalog():
    return {"A1": {"name": "Mug", "price": 10.0}, "B2": {"name": "Tea", "price": 4.0}, "C3": {"name": "Pot", "price": 25.0}}
PY
cat > shop/cache.py <<'PY'
import functools


def memoize(fn):
    store = {}

    @functools.wraps(fn)
    def wrapper(*args):
        if args not in store:
            store[args] = fn(*args)
        return store[args]

    wrapper.cache = store
    return wrapper
PY
cat > shop/pricing.py <<'PY'
from .cache import memoize
from .catalog import load_catalog

RATES = {"eu": 1.2, "us": 1.0}
compute_calls = 0


@memoize
def price_table(region):
    global compute_calls
    compute_calls += 1
    rate = RATES[region]
    return {sku: {"name": v["name"], "price": round(v["price"] * rate, 2)} for sku, v in load_catalog().items()}
PY
cat > shop/promotions.py <<'PY'
def apply_discount(table, pct, skus=None):
    """Return the price table with `pct` percent off the given skus (all if None)."""
    for sku, row in table.items():
        if skus is None or sku in skus:
            row["price"] = round(row["price"] * (1 - pct / 100), 2)
    return table
PY
cat > shop/orders.py <<'PY'
from .pricing import price_table
from .promotions import apply_discount


def order_total(region, items, promo=None):
    table = price_table(region)
    if promo:
        table = apply_discount(table, promo["pct"], promo.get("skus"))
    return round(sum(table[sku]["price"] * qty for sku, qty in items.items()), 2)
PY
cat > test_orders.py <<'PY'
from shop.orders import order_total
assert order_total("us", {"A1": 2}) == 20.0
assert order_total("us", {"A1": 2}, {"pct": 50}) == 10.0
assert order_total("us", {"A1": 2}) == 20.0
assert order_total("eu", {"C3": 1, "B2": 1}, {"pct": 10, "skus": ["C3"]}) == 31.8
assert order_total("eu", {"C3": 1}) == 30.0
print("ok")
PY
