cat > packages.json <<'J'
[
  {"name": "zeta", "version": "10.0.1", "deps": ["lodash", "chalk"]},
  {"name": "alpha", "version": "1.9.9", "deps": ["lodash"]},
  {"name": "beta", "version": "v2.0.0", "deps": ["lodash-es"]},
  {"name": "gamma", "version": "2.3.0-rc.1", "deps": ["react", "lodash"]},
  {"name": "delta", "version": "3.0.0", "deps": []},
  {"name": "Epsilon", "version": "v4.1.0", "deps": ["lodash"]},
  {"name": "eta", "version": "0.12.0", "deps": ["lodash"]},
  {"name": "theta", "version": "2.0.0", "deps": ["left-pad", "lodash"], "devDeps": ["lodash"]},
  {"name": "iota", "version": "5.0.0", "devDeps": ["lodash"]}
]
J
