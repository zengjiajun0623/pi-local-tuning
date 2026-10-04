python3 - <<'PY'
import csv, json, datetime as dt
def eu(s):
    neg = s.startswith("(") and s.endswith(")")
    s = s.strip("()").replace(".", "").replace(",", ".")
    c = round(float(s) * 100)
    return -c if neg else c
bank = [(dt.datetime.strptime(r["Date"], "%d/%m/%Y").date(), eu(r["Amount"])) for r in csv.DictReader(open("bank.csv"))]
led = [(dt.date.fromisoformat(r["date"]), round(float(r["amount"]) * 100)) for r in csv.DictReader(open("ledger.csv"))]
used = set(); bo = []
for i, (bd, ba) in enumerate(bank):
    c = [(abs((ld - bd).days), j) for j, (ld, la) in enumerate(led) if j not in used and la == ba and abs((ld - bd).days) <= 2]
    if c: used.add(min(c)[1])
    else: bo.append(i)
json.dump({"bank_only": bo, "ledger_only": [j for j in range(len(led)) if j not in used]}, open("unmatched.json", "w"))
PY
