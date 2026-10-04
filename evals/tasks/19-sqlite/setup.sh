python3 - <<'PY'
import sqlite3, random
r = random.Random(11)
db = sqlite3.connect("shop.db")
db.executescript("""
create table customers(id integer primary key, name text, country text);
create table orders(id integer primary key, customer_id integer references customers(id), amount real, status text);
""")
names = ["Anna","Ben","Clara","Dieter","Eva","Felix","Greta","Hans","Ida","Jonas","Karl","Lena"]
countries = ["Germany","Germany","France","Germany","Austria","Germany","Belgium","Germany","Spain","Germany","Germany","Germany"]
for i,(n,c) in enumerate(zip(names,countries),1):
    db.execute("insert into customers values(?,?,?)",(i,n,c))
oid=1
for cid in range(1,13):
    for _ in range(r.randint(0,6)):
        db.execute("insert into orders values(?,?,?,?)",(oid,cid,round(r.uniform(5,80),2),r.choice(["paid","paid","refunded","pending"]))); oid+=1
db.commit()
PY
