cat > paginate.js <<'JS'
// Return page `page` (1-based) of `items` with `size` items per page, and the total page count.
function paginate(items, page, size) {
  const start = page * size;
  const pages = Math.floor(items.length / size);
  return { items: items.slice(start, start + size), pages };
}

module.exports = { paginate };
JS
