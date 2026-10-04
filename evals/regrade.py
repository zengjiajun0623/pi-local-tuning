#!/usr/bin/env python3
"""Re-run check.sh in each finished work dir of a run (after a grader fix) and rewrite the rows file.
The original rows file is kept as <file>.orig-<timestamp>. Usage: regrade.py results/<run-id>.jsonl"""
import json, os, shutil, subprocess, sys, time
HERE = os.path.dirname(os.path.abspath(__file__))
path = sys.argv[1]
run_dir = path[:-len(".jsonl")]
rows = [json.loads(l) for l in open(path)]
shutil.copy(path, f"{path}.orig-{time.strftime('%H%M%S')}")
for r in rows:
    tdir = os.path.join(HERE, "tasks", r["task"])
    wd = os.path.join(run_dir, "work", r["arm"], r["task"])
    chk = subprocess.run(["bash", os.path.join(tdir, "check.sh")], cwd=wd, env=dict(os.environ, TASK_DIR=tdir),
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=180)
    new = chk.returncode == 0
    if new != r["pass"]:
        print(f"{r['task']:24s} {r['arm']:10s} {r['pass']} -> {new}")
    r["pass"], r["check_tail"] = new, chk.stdout.decode(errors="ignore")[-300:]
with open(path, "w") as f:
    for r in rows: f.write(json.dumps(r) + "\n")
