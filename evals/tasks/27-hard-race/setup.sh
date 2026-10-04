cat > bank.py <<'PY'
import time


class InsufficientFunds(Exception):
    pass


class Account:
    def __init__(self, name, balance=0):
        self.name = name
        self.balance = balance


def transfer(src, dst, amount):
    if amount <= 0:
        raise ValueError("amount must be positive")
    if src.balance < amount:
        raise InsufficientFunds(src.name)
    new_src = src.balance - amount
    time.sleep(0)  # simulate I/O
    src.balance = new_src
    new_dst = dst.balance + amount
    time.sleep(0)
    dst.balance = new_dst
PY
