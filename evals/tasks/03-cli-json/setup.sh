printf 'name,qty,price\napple,3,0.5\npear,2,1.25\nmelon,1,3.1\n' > items.csv
cat > inventory.py <<'PY'
import argparse
import csv


def load(path):
    with open(path, newline="") as f:
        return [(r["name"], int(r["qty"]), float(r["price"])) for r in csv.DictReader(f)]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("csv", nargs="?", default="items.csv")
    args = ap.parse_args()
    rows = load(args.csv)
    grand = 0.0
    for name, qty, price in rows:
        total = qty * price
        grand += total
        print(f"{name}: {qty} x {price:.2f} = {total:.2f}")
    print(f"TOTAL: {grand:.2f}")


if __name__ == "__main__":
    main()
PY
