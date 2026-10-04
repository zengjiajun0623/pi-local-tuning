sed -i 's/const start = page \* size;/const start = (page - 1) * size;/; s/Math.floor(items.length \/ size)/Math.ceil(items.length \/ size)/' paginate.js
