exp=$(git log --format=%H --reverse -S FIXME-42 | head -1)
[ "$(tr -d '[:space:]' < answer.txt)" = "$exp" ]
