set -e
[ "$(md5sum < test.js | cut -c1-32)" = "$(cat <<'JS' | md5sum | cut -c1-32
const assert = require("assert");
const { total } = require("./lib/cart");
assert.strictEqual(total([{ qty: 2, price: 500 }], ""), 1080);
assert.strictEqual(total([{ qty: 2, price: 500 }], "HALF"), 540);
console.log("ok");
JS
)" ]
node test.js >/dev/null
node -e '
const assert = require("assert");
const { total } = require("./lib/cart");
assert.strictEqual(total([{ qty: 3, price: 333 }], "SAVE10"), 971);   // 999*0.9=899.1 *1.08=971.03 -> 971
assert.strictEqual(total([{ qty: 1, price: 105 }, { qty: 1, price: 1 }], "SAVE10"), 103); // 95.4*1.08=103.03
assert.strictEqual(total([{ qty: 1, price: 7 }], ""), 8); // 7.56 -> 8 (rounded once at end)
assert.strictEqual(total([], "HALF"), 0);
'
