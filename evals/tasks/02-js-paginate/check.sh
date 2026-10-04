node -e '
const assert = require("assert");
const { paginate } = require("./paginate.js");
const xs = [1,2,3,4,5,6,7,8,9,10];
assert.deepStrictEqual(paginate(xs, 1, 3), { items: [1,2,3], pages: 4 });
assert.deepStrictEqual(paginate(xs, 4, 3), { items: [10], pages: 4 });
assert.deepStrictEqual(paginate(xs, 5, 3).items, []);
assert.deepStrictEqual(paginate(xs, 2, 5), { items: [6,7,8,9,10], pages: 2 });
assert.strictEqual(paginate([], 1, 3).pages, 0);
'
