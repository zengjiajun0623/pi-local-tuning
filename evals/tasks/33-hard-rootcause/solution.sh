cat > shop/promotions.py <<'PY'
def apply_discount(table, pct, skus=None):
    """Return a new price table with `pct` percent off the given skus (all if None)."""
    return {sku: {**row, "price": round(row["price"] * (1 - pct / 100), 2)} if skus is None or sku in skus else dict(row)
            for sku, row in table.items()}
PY
