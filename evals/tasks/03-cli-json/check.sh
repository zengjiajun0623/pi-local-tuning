set -e
exp='apple: 3 x 0.50 = 1.50
pear: 2 x 1.25 = 2.50
melon: 1 x 3.10 = 3.10
TOTAL: 7.10'
[ "$(python3 inventory.py)" = "$exp" ]
python3 inventory.py --json | python3 -c '
import json,sys
d=json.load(sys.stdin)
it=d["items"]
assert [i["name"] for i in it]==["apple","pear","melon"]
assert [i["qty"] for i in it]==[3,2,1] and all(type(i["qty"]) is int for i in it)
assert [round(i["price"],2) for i in it]==[0.5,1.25,3.1]
assert [round(i["total"],2) for i in it]==[1.5,2.5,3.1]
assert abs(d["total"]-7.1)<1e-9
'
