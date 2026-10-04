python3 - <<'PY'
s = open("bank.py").read()
s = s.replace("import time\n", "import itertools\nimport threading\nimport time\n\n_ids = itertools.count()\n")
s = s.replace("        self.balance = balance\n", "        self.balance = balance\n        self.lock = threading.Lock()\n        self.order = next(_ids)\n")
s = s.replace('''    if src.balance < amount:
        raise InsufficientFunds(src.name)
    new_src = src.balance - amount
    time.sleep(0)  # simulate I/O
    src.balance = new_src
    new_dst = dst.balance + amount
    time.sleep(0)
    dst.balance = new_dst''', '''    first, second = sorted((src, dst), key=lambda a: a.order)
    with first.lock, second.lock:
        if src.balance < amount:
            raise InsufficientFunds(src.name)
        new_src = src.balance - amount
        time.sleep(0)  # simulate I/O
        src.balance = new_src
        new_dst = dst.balance + amount
        time.sleep(0)
        dst.balance = new_dst''')
open("bank.py", "w").write(s)
PY
