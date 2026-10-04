python3 - <<'PY'
from lru import LRUCache
c = LRUCache(2)
c.put(1, 1); c.put(2, 2)
assert c.get(1) == 1
c.put(3, 3)
assert c.get(2) == -1
c.put(4, 4)
assert c.get(1) == -1 and c.get(3) == 3 and c.get(4) == 4
c.put(3, 30); c.put(5, 5)
assert c.get(4) == -1 and c.get(3) == 30
z = LRUCache(0); z.put(1, 1); assert z.get(1) == -1
o = LRUCache(1); o.put(1, 1); o.put(1, 2); assert o.get(1) == 2; o.put(2, 2); assert o.get(1) == -1
import time
b = LRUCache(50000); t = time.time()
for i in range(200000): b.put(i, i); b.get(i - 100)
assert time.time() - t < 3
PY
