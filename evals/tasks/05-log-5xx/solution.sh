awk '$9 ~ /^5/ {print $1}' access.log | sort | uniq -c | sort -rn | head -3 | awk '{print $2, $1}' > answer.txt
