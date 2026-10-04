python3 -c '
import csv,json,collections
t=collections.defaultdict(float)
for r in csv.DictReader(open("sales.csv")):
    if r["region"]: t[r["region"]]+=int(r["units"])*float(r["unit_price"])
json.dump({k:round(t[k],2) for k in sorted(t)},open("totals.json","w"))'
