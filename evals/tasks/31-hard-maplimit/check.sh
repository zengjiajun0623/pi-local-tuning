timeout 60 node - <<'JS'
const assert = require("assert");
const _m = require("./map-limit.js"); const mapLimit = typeof _m === "function" ? _m : _m.mapLimit;  // default or named export
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
(async () => {
  // order + max concurrency
  let inflight = 0, peak = 0;
  const res = await mapLimit([1,2,3,4,5,6,7,8,9,10], 3, async (x, i) => {
    inflight++; peak = Math.max(peak, inflight);
    await sleep(5 + ((x * 7) % 5) * 4); inflight--; return x * 2 + i * 0;
  });
  assert.deepStrictEqual(res, [2,4,6,8,10,12,14,16,18,20]); assert.strictEqual(peak, 3);
  // index argument, sync fn values
  assert.deepStrictEqual(await mapLimit(["a","b"], 5, (x, i) => x + i), ["a0","b1"]);
  // next starts as soon as a slot frees
  const t0 = Date.now(), starts = [], ends = [];
  await mapLimit([120, 10, 10, 10], 2, async (ms, i) => { starts[i] = Date.now() - t0; await sleep(ms); ends[i] = Date.now() - t0; });
  assert(starts[2] < ends[0] && starts[3] < ends[0], "did not refill slots promptly");
  // empty + Set
  assert.deepStrictEqual(await mapLimit([], 2, async (x) => x), []);
  assert.deepStrictEqual(await mapLimit(new Set([3, 4]), 1, async (x) => x * x), [9, 16]);
  // laziness on generators
  let pulled = 0, firstCallPulled = -1;
  function* gen() { for (let i = 0; i < 6; i++) { pulled++; yield i; } }
  await mapLimit(gen(), 2, async (x) => { if (firstCallPulled < 0) firstCallPulled = pulled; await sleep(5); return x; });
  assert(firstCallPulled <= 2, "pulled too eagerly: " + firstCallPulled);
  // rejection stops pulling/starting; infinite generator must not hang
  let started = 0;
  function* inf() { let i = 0; while (true) yield i++; }
  const err = new Error("boom");
  await assert.rejects(mapLimit(inf(), 3, async (x) => { started++; await sleep(10); if (x === 4) throw err; return x; }), (e) => e === err);
  const s1 = started; await sleep(80); assert.strictEqual(started, s1, "kept starting after rejection");
  assert(s1 <= 8, "started too many: " + s1);
  // sync throw -> rejection, not a throw
  const p = mapLimit([1], 1, () => { throw err; }); await assert.rejects(p, (e) => e === err);
  // bad limits throw synchronously
  for (const bad of [0, -1, 1.5, NaN, "2", undefined]) {
    assert.throws(() => mapLimit([1], bad, async (x) => x), RangeError, "limit " + String(bad));
  }
  console.log("ok");
})().catch((e) => { console.error(e); process.exit(1); });
JS
