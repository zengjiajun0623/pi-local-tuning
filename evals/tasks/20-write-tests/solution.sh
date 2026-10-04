cat > test_slugify.py <<'PY'
from slugify import slugify
assert slugify("Héllo Wörld") == "hello-world"
assert slugify("a -- b!!c") == "a-b-c"
assert slugify("  --Hi--  ") == "hi"
assert slugify("ABC") == "abc"
assert slugify("abc def", max_len=4) == "abc"
assert slugify("x" * 60) == "x" * 50
print("ok")
PY
