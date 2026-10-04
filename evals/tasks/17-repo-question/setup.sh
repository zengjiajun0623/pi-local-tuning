mkdir -p src legacy
cat > src/config.js <<'JS'
const DEFAULTS = { port: 3000, host: "0.0.0.0" };
function load(env) {
  const port = env.APP_PORT ? Number(env.APP_PORT) : DEFAULTS.port;
  return { ...DEFAULTS, port: env.NODE_ENV === "test" ? 0 : port };
}
module.exports = { load };
JS
cat > src/server.js <<'JS'
const http = require("http");
const { load } = require("./config");
const cfg = load(process.env);
const offset = process.env.SHARD ? Number(process.env.SHARD) * 10 : 0;
const port = cfg.port === 0 ? 0 : cfg.port + offset;
http.createServer((req, res) => res.end("ok")).listen(port, cfg.host);
JS
cat > legacy/config.js <<'JS'
// old config, unused since v2
module.exports = { load: () => ({ port: 9000 }) };
JS
cat > start.sh <<'SH'
#!/bin/sh
export APP_PORT="${APP_PORT:-5000}"
[ "$NODE_ENV" = production ] && export APP_PORT=$((APP_PORT + 1))
exec node src/server.js
SH
chmod +x start.sh
