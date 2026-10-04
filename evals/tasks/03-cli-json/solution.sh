python3 - <<'PY'
s=open("inventory.py").read()
s=s.replace('import argparse\n','import argparse\nimport json\n')
s=s.replace('    args = ap.parse_args()\n    rows = load(args.csv)\n','    ap.add_argument("--json", action="store_true")\n    args = ap.parse_args()\n    rows = load(args.csv)\n    if args.json:\n        items = [{"name": n, "qty": q, "price": round(p, 2), "total": round(q * p, 2)} for n, q, p in rows]\n        print(json.dumps({"items": items, "total": round(sum(q * p for _, q, p in rows), 2)}))\n        return\n')
open("inventory.py","w").write(s)
PY
