git init -q . && git config user.email t@t && git config user.name t
printf 'def add(a, b):\n    return a + b\n\n\ndef scale(x, k=2):\n    return x * k\n' > calc.py
printf 'from calc import add, scale\nassert add(2, 3) == 5\nassert scale(4) == 8\nprint("ok")\n' > test.py
echo "# calc" > README.md
git add -A && git commit -qm "initial calc"
printf 'def add(a, b):\n    """Add two numbers."""\n    return a + b\n\n\ndef scale(x, k=2):\n    return x * k\n' > calc.py
git commit -qam "docs: docstring for add"
sed -i 's/return x \* k/return x * k + (1 if k == 2 else 0)/' calc.py
git commit -qam "scale: tweak default factor handling"
echo "Usage: import calc" >> README.md
git commit -qam "readme: usage"
