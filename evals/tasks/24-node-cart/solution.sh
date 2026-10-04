cat > lib/cart.js <<'JS'
const { discountPercent } = require("./discount");
const { tax } = require("./tax");

function total(items, code) {
  const subtotal = items.reduce((s, it) => s + it.qty * it.price, 0);
  const discounted = subtotal - subtotal * discountPercent(code) / 100;
  return Math.round(discounted + tax(discounted));
}
module.exports = { total };
JS
