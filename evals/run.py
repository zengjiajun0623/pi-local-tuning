#!/usr/bin/env python3
"""Run the Pi eval suite for one or more arms, interleaved per task.

Arm spec:  name=provider/model:thinking[:prompts_dir]
  prompts_dir -> PI_MODEL_PROMPTS_DIR for the model-prompts extension
  (default: ~/.pi/agent/model-prompts; "none" = an empty dir, i.e. Pi's default prompt).

Examples:
  ./run.py --arm low=halo/halogen-qwen3.8-flash-next:low --arm med=halo/halogen-qwen3.8-flash-next:medium
  ./run.py --arm cur=halo/halogen-qwen3.8-flash-next:low --arm bare=halo/halogen-qwen3.8-flash-next:low:none --tasks 01,05

One row per (task, arm) is appended to results/<run-id>.jsonl as soon as it finishes,
so an interrupted run keeps its rows; --resume <run-id> skips rows already there.
Halo arms wait until halogen is idle (requests_processing == 0) so timings are clean.
"""
import argparse, json, os, re, shutil, subprocess, sys, tempfile, time, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
METRICS = os.environ.get("HALO_METRICS", "http://localhost:8731/metrics")
SUFFIX = "\n\nWork only inside the current directory."
ENV_EXTRA = {
    "PI_WEB_SEARCH_BACKEND": "searxng",
    "PI_SEARXNG_URL": "http://127.0.0.1:8888",
    "PI_WEB_FETCH_MODE": "direct",
    "PI_SKIP_VERSION_CHECK": "1",
    "PI_TELEMETRY": "0",
}


def metrics():
    try:
        txt = urllib.request.urlopen(METRICS, timeout=5).read().decode()
    except Exception:
        return None
    out = {}
    for line in txt.splitlines():
        m = re.match(r"^([a-z_:]+) ([0-9.e+-]+)$", line)
        if m:
            out[m.group(1)] = float(m.group(2))
    return out


def wait_idle(max_wait=1800):
    t0 = time.time()
    while time.time() - t0 < max_wait:
        m = metrics()
        if m and m.get("llamacpp:requests_processing", 1) == 0:
            return time.time() - t0
        time.sleep(5)
    raise SystemExit("halogen stayed busy for 30 min; aborting so timings stay clean")


def parse_arm(spec):
    name, rest = spec.split("=", 1)
    parts = rest.split(":")
    model, thinking = parts[0], parts[1]
    pdir = parts[2] if len(parts) > 2 else os.path.expanduser("~/.pi/agent/model-prompts")
    return {"name": name, "model": model, "thinking": thinking, "prompts_dir": pdir}


def summarize_events(path):
    s = {"turns": 0, "out": 0, "reasoning": 0, "uncached_in": 0, "cached_in": 0,
         "toolcalls": 0, "tool_errors": 0, "stop": None, "error": None}
    for line in open(path, errors="ignore"):
        try:
            ev = json.loads(line)
        except ValueError:
            continue
        if ev.get("type") != "message_end":
            continue
        m = ev.get("message") or {}
        if m.get("role") == "assistant":
            u = m.get("usage") or {}
            s["turns"] += 1
            s["out"] += u.get("output", 0) or 0
            s["reasoning"] += u.get("reasoning", 0) or 0
            s["uncached_in"] += u.get("input", 0) or 0
            s["cached_in"] += u.get("cacheRead", 0) or 0
            s["toolcalls"] += sum(1 for b in m.get("content") or [] if isinstance(b, dict) and b.get("type") == "toolCall")
            s["stop"] = m.get("stopReason")
            if m.get("errorMessage"):
                s["error"] = str(m["errorMessage"])[:200]
        elif m.get("role") == "toolResult" and m.get("isError"):
            s["tool_errors"] += 1
    return s


def run_one(task, arm, run_dir, empty_prompts):
    tdir = os.path.join(HERE, "tasks", task)
    meta = json.load(open(os.path.join(tdir, "task.json")))
    wd = os.path.join(run_dir, "work", arm["name"], task)
    shutil.rmtree(wd, ignore_errors=True)
    os.makedirs(wd)
    env = dict(os.environ, **ENV_EXTRA, TASK_DIR=tdir)
    env["PI_MODEL_PROMPTS_DIR"] = empty_prompts if arm["prompts_dir"] == "none" else os.path.expanduser(arm["prompts_dir"])
    subprocess.run(["bash", os.path.join(tdir, "setup.sh")], cwd=wd, env=env, check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    prompt = open(os.path.join(tdir, "prompt.txt")).read().strip() + SUFFIX
    halo = arm["model"].startswith("halo/")
    waited = wait_idle() if halo else 0
    m0 = metrics() if halo else None
    ev_path = os.path.join(run_dir, "events", f"{arm['name']}--{task}.jsonl")
    cmd = ["pi", "--mode", "json", "--no-session", "--model", arm["model"], "--thinking", arm["thinking"], prompt]
    t0 = time.time()
    with open(ev_path, "w") as out, open(ev_path + ".err", "w") as err:
        try:
            p = subprocess.run(cmd, cwd=wd, env=env, stdin=subprocess.DEVNULL, stdout=out, stderr=err,
                               timeout=meta.get("timeout", 600))
            rc, timed_out = p.returncode, False
        except subprocess.TimeoutExpired:
            rc, timed_out = None, True
    wall = time.time() - t0
    m1 = metrics() if halo else None
    chk = subprocess.run(["bash", os.path.join(tdir, "check.sh")], cwd=wd, env=env,
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=180)
    row = {"task": task, "category": meta.get("category"), "arm": arm["name"], "model": arm["model"],
           "thinking": arm["thinking"], "prompts_dir": arm["prompts_dir"],
           "pass": chk.returncode == 0, "wall_s": round(wall, 1), "rc": rc, "timed_out": timed_out,
           "waited_idle_s": round(waited, 1), **summarize_events(ev_path),
           "check_tail": chk.stdout.decode(errors="ignore")[-300:]}
    if m0 and m1:
        d = {k: m1.get(k, 0) - m0.get(k, 0) for k in m1}
        row["srv_requests"] = int(d.get("halogen:requests_total", 0))
        gen_s = d.get("llamacpp:tokens_predicted_seconds_total", 0)
        row["srv_decode_tps"] = round(d.get("llamacpp:tokens_predicted_total", 0) / gen_s, 1) if gen_s else None
        row["srv_prefill_s"] = round(d.get("llamacpp:prompt_seconds_total", 0), 1)
        row["srv_decode_s"] = round(gen_s, 1)
        dt = d.get("halogen:draft_tokens_total", 0)
        row["srv_draft_accept"] = round(d.get("halogen:draft_tokens_accepted_total", 0) / dt, 3) if dt else None
    return row


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--arm", action="append", required=True)
    ap.add_argument("--tasks", help="comma-separated task prefixes, e.g. 01,05 (default: all)")
    ap.add_argument("--resume", help="run id to continue")
    ap.add_argument("--repeat", type=int, default=1, help="runs per (task, arm); greedy decoding makes 1 usually enough")
    a = ap.parse_args()
    arms = [parse_arm(s) for s in a.arm]
    tasks = sorted(os.listdir(os.path.join(HERE, "tasks")))
    if a.tasks:
        pre = a.tasks.split(",")
        tasks = [t for t in tasks if any(t.startswith(p) for p in pre)]
    run_id = a.resume or time.strftime("%Y%m%d-%H%M%S") + f"-{os.getpid()}"
    res_dir = os.path.join(HERE, "results")
    run_dir = os.path.join(res_dir, run_id)
    os.makedirs(os.path.join(run_dir, "events"), exist_ok=True)
    rows_path = os.path.join(res_dir, f"{run_id}.jsonl")
    done = set()
    if os.path.exists(rows_path):
        for line in open(rows_path):
            r = json.loads(line)
            done.add((r["task"], r["arm"], r.get("rep", 0)))
    json.dump({"arms": arms, "tasks": tasks, "repeat": a.repeat}, open(os.path.join(run_dir, "config.json"), "w"), indent=1)
    empty_prompts = tempfile.mkdtemp(prefix="pi-eval-noprompts-")
    print(f"run {run_id}: {len(tasks)} tasks x {len(arms)} arms x {a.repeat}", flush=True)
    for rep in range(a.repeat):
        for i, task in enumerate(tasks):
            # rotate arm order per task so neither arm always runs first (cache warmth, drift)
            order = arms[i % len(arms):] + arms[:i % len(arms)]
            for arm in order:
                if (task, arm["name"], rep) in done:
                    continue
                row = run_one(task, arm, run_dir, empty_prompts)
                row["rep"] = rep
                with open(rows_path, "a") as f:
                    f.write(json.dumps(row) + "\n")
                print(f"{task:24s} {arm['name']:10s} {'PASS' if row['pass'] else 'fail'} {row['wall_s']:7.1f}s "
                      f"turns={row['turns']} out={row['out']} tps={row.get('srv_decode_tps')}", flush=True)
    print(f"rows: {rows_path}\nreport: {os.path.join(HERE, 'report.py')} {rows_path}")


if __name__ == "__main__":
    main()
