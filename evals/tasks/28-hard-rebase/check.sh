set -e
[ "$(git rev-parse --abbrev-ref HEAD)" = feature ]
[ ! -d .git/rebase-merge ] && [ ! -d .git/rebase-apply ]
git merge-base --is-ancestor main feature
[ "$(git rev-list --count main..feature)" = 2 ]
[ -z "$(git rev-list --merges main..feature)" ]
[ "$(git log --format=%s main..feature | sort | tr '\n' '|')" = "feature: cache prices|feature: tests|" ]
[ -z "$(git status --porcelain | grep -v __pycache__)" ]  # test runs leave __pycache__; that is not a dirty tree
git diff --quiet main -- test_main.py
python3 test_main.py && python3 test_feature.py && python3 test_base.py
grep -q 'assert ("pear", 4) in shop._cache' test_feature.py
