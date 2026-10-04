timeout 60 python3 - <<'PY'
import random, threading, sys
import bank
accts = [bank.Account(f"a{i}", 1000) for i in range(6)]
neg = []
def worker(seed):
    r = random.Random(seed)
    for _ in range(3000):
        a, b = r.sample(accts, 2)
        try: bank.transfer(a, b, r.randint(1, 400))
        except bank.InsufficientFunds: pass
        if a.balance < 0 or b.balance < 0: neg.append(1)
ts = [threading.Thread(target=worker, args=(s,), daemon=True) for s in range(16)]
[t.start() for t in ts]; [t.join(50) for t in ts]
assert not any(t.is_alive() for t in ts), "deadlock / too slow"
total = sum(a.balance for a in accts)
assert total == 6000, total
assert not neg and min(a.balance for a in accts) >= 0
a, b = bank.Account("x", 5), bank.Account("y", 0)
try: bank.transfer(a, b, 10); sys.exit("no InsufficientFunds")
except bank.InsufficientFunds: pass
assert (a.balance, b.balance) == (5, 0)
bank.transfer(a, b, 5); assert (a.balance, b.balance) == (0, 5)
print("ok")
PY
