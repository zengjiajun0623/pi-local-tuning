mkdir -p lib
cat > README.md <<'M'
# cart

Pricing rules:
1. subtotal = sum of qty * unit price (prices in cents).
2. A discount code takes a percentage off the subtotal.
3. Tax (8%) is charged on the discounted subtotal.
4. Round to whole cents once, at the very end (Math.round).
M
cat > lib/discount.js <<'JS'
const CODES = { SAVE10: 10, HALF: 50 };
function discountPercent(code) {
  return CODES[code] || 0;
}
module.exports = { discountPercent };
JS
cat > lib/tax.js <<'JS'
const RATE = 0.08;
function tax(amount) {
  return amount * RATE;
}
module.exports = { tax };
JS
cat > lib/cart.js <<'JS'
const { discountPercent } = require("./discount");
const { tax } = require("./tax");

function total(items, code) {
  const subtotal = items.reduce((s, it) => s + it.qty * it.price, 0);
  const t = Math.round(tax(subtotal));
  const discount = subtotal * discountPercent(code) / 100;
  return subtotal - discount + t;
}
module.exports = { total };
JS
cat > test.js <<'JS'
const assert = require("assert");
const { total } = require("./lib/cart");
assert.strictEqual(total([{ qty: 2, price: 500 }], ""), 1080);
assert.strictEqual(total([{ qty: 2, price: 500 }], "HALF"), 540);
console.log("ok");
JS
