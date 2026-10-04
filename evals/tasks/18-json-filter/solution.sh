jq -r '.[] | select((.version|ltrimstr("v")|split(".")[0]|tonumber) >= 2 and ((.deps // []) | index("lodash"))) | .name' packages.json | LC_ALL=C sort > answer.txt
