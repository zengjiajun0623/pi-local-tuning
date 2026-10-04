#!/usr/bin/env python3
"""Compare arms from one or more results/<run-id>.jsonl files (numbers only).

Primary metric: wall seconds per successful task (total wall / passes).
Guardrail: pass rate. Paired view: tasks every arm passed, so speed is compared on equal work.
"""
import collections, json, statistics as st, sys

rows = [json.loads(l) for p in sys.argv[1:] for l in open(p)]
if not rows:
    raise SystemExit("usage: report.py results/<run-id>.jsonl [...]")
arms = list(dict.fromkeys(r["arm"] for r in rows))
by = collections.defaultdict(list)
for r in rows:
    by[r["arm"]].append(r)


def mean(xs):
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs) if xs else float("nan")


print(f"{'arm':10s} {'pass':>7s} {'s/success':>9s} {'wall_sum':>8s} {'wall_p50':>8s} {'turns':>6s} {'out_tok':>7s} "
      f"{'reason%':>7s} {'calls/turn':>10s} {'tool_err':>8s} {'tps':>5s} {'mtp_acc':>7s} {'prefill_s':>9s} {'timeouts':>8s}")
for a in arms:
    R = by[a]
    n, ok = len(R), sum(r["pass"] for r in R)
    wall = sum(r["wall_s"] for r in R)
    turns = sum(r["turns"] for r in R)
    out = sum(r["out"] for r in R)
    print(f"{a:10s} {ok:3d}/{n:<3d} {wall / max(ok, 1):9.1f} {wall:8.0f} {st.median(r['wall_s'] for r in R):8.1f} "
          f"{mean(r['turns'] for r in R):6.1f} {mean(r['out'] for r in R):7.0f} "
          f"{100 * sum(r['reasoning'] for r in R) / max(out, 1):6.0f}% {sum(r['toolcalls'] for r in R) / max(turns, 1):10.2f} "
          f"{sum(r['tool_errors'] for r in R):8d} {mean(r.get('srv_decode_tps') for r in R):5.1f} "
          f"{mean(r.get('srv_draft_accept') for r in R):7.2f} {sum(r.get('srv_prefill_s') or 0 for r in R):9.0f} "
          f"{sum(1 for r in R if r['timed_out']):8d}")

# paired: tasks passed by every arm (same rep)
key = lambda r: (r["task"], r.get("rep", 0))
cell = {(r["arm"],) + key(r): r for r in rows}
keys = sorted(k for k in {key(r) for r in rows} if all((a,) + k in cell for a in arms))  # only tasks every arm has run
both = [k for k in keys if all(cell.get((a,) + k, {}).get("pass") for a in arms)]
if len(arms) > 1 and both:
    print(f"\npaired on {len(both)} task(s) every arm passed:")
    for a in arms:
        w = [cell[(a,) + k]["wall_s"] for k in both]
        o = [cell[(a,) + k]["out"] for k in both]
        print(f"  {a:10s} wall_sum={sum(w):7.0f}s  wall_p50={st.median(w):6.1f}s  out_tok_sum={sum(o):7d}")

print("\nper category (pass):")
cats = sorted({r["category"] for r in rows})
for c in cats:
    print(f"  {c:14s} " + "  ".join(f"{a}={sum(r['pass'] for r in by[a] if r['category'] == c)}/{sum(1 for r in by[a] if r['category'] == c)}" for a in arms))

disc = [k for k in keys if len({cell.get((a,) + k, {}).get("pass") for a in arms}) > 1]
if disc:
    print("\ntasks where arms disagree:")
    for k in disc:
        print(f"  {k[0]:24s} " + "  ".join(f"{a}={'PASS' if cell.get((a,) + k, {}).get('pass') else 'fail'}" for a in arms))
