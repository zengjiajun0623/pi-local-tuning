set -e
[ "$(md5sum < test_orders.py | cut -c1-8)" = "$(cd "$TASK_DIR" && d=$(mktemp -d) && cd $d && bash "$TASK_DIR/setup.sh" && md5sum < test_orders.py | cut -c1-8)" ]
python3 test_orders.py
python3 - <<'PY'
from shop import pricing
from shop.orders import order_total
for _ in range(3):
    for promo in (None, {"pct": 20}, {"pct": 50, "skus": ["A1"]}, None):
        t = order_total("eu", {"A1": 1, "B2": 2, "C3": 1}, promo)
        exp = 51.6 if promo is None else 41.28 if promo["pct"] == 20 else 45.6  # eu: A1 12, B2 4.8, C3 30
        assert t == exp, (promo, t, exp)
    order_total("us", {"B2": 3}, {"pct": 25})
    assert order_total("us", {"B2": 3}) == 12.0
assert pricing.compute_calls == 2, pricing.compute_calls
t1 = pricing.price_table("eu"); assert t1["A1"]["price"] == 12.0
print("ok")
PY
