set -e
python3 test.py
subs=$(git log --format=%s --reverse)
echo "$subs" | head -4 | diff - <(printf 'initial calc\ndocs: docstring for add\nscale: tweak default factor handling\nreadme: usage\n')
git log -1 --format=%s | grep -qi revert
grep -q 'Usage: import calc' README.md
grep -q 'Add two numbers' calc.py
[ -z "$(git status --porcelain --untracked-files=no)" ]
