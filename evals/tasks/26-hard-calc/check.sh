set -e
if grep -nE '(^|[^.[:alnum:]_])(eval|exec|compile)[[:space:]]*\(|import ast|from ast' calc.py; then echo "forbidden"; exit 1; fi
python3 - <<'PY'
from calc import evaluate as E
ok = [("1+2*3",7),("(1+2)*3",9),("2**3**2",512),("-2**2",-4),("2**-1",0.5),("2*-3",-6),("--3",3),("-(-(2))",2),
 ("7%3",1),("10/4",2.5),("10-4-3",3),("2*3%4",2),("100/10/5",2),(".5+1",1.5),("3.25*4",13),(" 1 +\t2 ",3),
 ("min(3, 1+1, 5)",2),("max(1)",1),("abs(-2.5)",2.5),("abs(2-5)*2",6),("max(2,3)**2",9),("-abs(-3)",-3),
 ("x*2",8,{"x":4}),("rate*(1+tax)",110,{"rate":100,"tax":0.1}),("+5",5),("2**3*2",16),("-3**-2*9",-1)]
for c in ok:
    v = E(c[0], c[2] if len(c) > 2 else None)
    assert abs(v - c[1]) < 1e-9, (c, v)
for bad in ["1+","2 3","(1","1)","","*2","1**","min()","abs(1,2)","foo(1)","y+1","1/0","5%0","1..2","3.4.5","max(1,)","()","2(3)"]:
    try:
        E(bad); raise SystemExit(f"no ValueError for {bad!r}")
    except ValueError:
        pass
print("ok")
PY
