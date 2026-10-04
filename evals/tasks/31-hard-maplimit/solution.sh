cat > map-limit.js <<'JS'
function mapLimit(items, limit, fn) {
  if (typeof limit !== "number" || !Number.isInteger(limit) || limit < 1) throw new RangeError("limit must be a positive integer");
  const it = items[Symbol.iterator]();
  return new Promise((resolve, reject) => {
    const results = [];
    let index = 0, active = 0, done = false, failed = false;
    const next = () => {
      while (!failed && !done && active < limit) {
        const r = it.next();
        if (r.done) { done = true; break; }
        const i = index++;
        active++;
        Promise.resolve().then(() => fn(r.value, i)).then(
          (v) => { results[i] = v; active--; if (!failed) { if (done && active === 0) resolve(results); else next(); } },
          (e) => { if (!failed) { failed = true; reject(e); } }
        );
      }
      if (done && active === 0 && !failed) resolve(results);
    };
    next();
  });
}
module.exports = { mapLimit };
JS
