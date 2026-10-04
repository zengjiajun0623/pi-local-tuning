# Pi + a local Qwen on Strix Halo: measured tuning notes

What this is: a public writeup of tuning the Pi coding agent against a local
model (Qwen3.8 Flash-Next Q4, served by halogen on a Strix Halo box), plus the
two small extensions and the eval harness we used to get the numbers. The
three most useful takeaways, all measured: (1) thinking level "high" bought
zero quality on two task sets (all arms passed everything) and cost about 2x
wall time, so we run "low"; (2) decode speed is flat from 2k to 156k context,
so long sessions are nearly free while the prefix cache holds, and the real
cost is cache misses (prefill is slow), which means you should protect the
cache rather than trim context; (3) the local model is about 3.6x slower than
a cloud model on easy tasks and about 7x on hard ones at the same pass rate,
so on this hardware routing is about speed and privacy, not capability.

## Setup measured

- Pi coding agent with an OpenAI-compatible backend.
- Model server: halogen 0.16.2, greedy decoding, on a Strix Halo box
  (referred to below as the halo box; server placeholder
  `http://localhost:8731/v1`, or your `HALO_URL`).
- Model: Qwen3.8 Flash-Next Q4, 262k context window.
- Comparison arm: DeepSeek Flash (cloud), driven through the same Pi harness
  and the same tasks, so wall times are directly comparable.
- Eval suite: auto-graded repo tasks in two sets, an easy set (tasks 01-24)
  and a hard set (tasks 25-34), interleaved arms, one rep (greedy decoding
  makes runs near-deterministic). This public copy ships 23 of the 24 easy
  tasks (see `evals/README.md`). Full tables in
  [evals/results/SUMMARY.md](evals/results/SUMMARY.md).
- Background baseline from 669 real halo turns before any prompt changes:
  prefix cache hit 96.4%, avg decode 53.2 tok/s, draft acceptance 69%, p90
  context 126k tokens (limit 262k).

## Findings

### Context and prefix cache

- **Decode speed is flat vs context: 64/63/61/63 tok/s at 2k/52k/104k/156k
  tokens** (greedy, thinking off, code prompt). Consequence: do not lower
  Pi's compaction threshold for speed. Long sessions cost nothing while the
  prefix cache holds, and compaction itself is a full cache miss.
- **Prefill is about 1.8k tok/s cold, so a full miss at 156k context costs
  about 90 s.** The cache is what you are optimizing. Changing thinking level
  mid-session is a full miss (observed: 68.6k uncached, cacheRead 0), and so
  are context edits and server restarts. Pick one thinking level per session
  and change configs deliberately, not constantly.
- **Huge web_fetch results were the biggest cause of large cache misses
  before we capped output.** The 10 worst turns had over 20k uncached tokens
  each, 605k tokens total, about 60% of all prefill time in the baseline,
  mostly giant fetched pages re-prefilled. Fix: cap fetched output (we went
  from 200000 to 12000 chars).

### Thinking level

- **high vs low: same pass rate on both sets, about 2x slower.** Easy set:
  24/24 pass either way, 61.7 vs 29.6 s/success (high vs low), +47% output
  tokens. Hard set: 10/10 either way, 173.4 vs 170.2 s/success. High
  over-verifies open-ended tasks (one task took 20 turns, 594 s at high).
  Consequence: keep the local model at "low"; see
  `config-examples/settings.json.example`.

### Prompt rules (AGENTS-style instructions)

- **Rules vs none: no measurable effect on this suite, honestly.** Easy set:
  29.6 s/success with rules vs 25.9 without, both 24/24; the no-rules arm was
  faster on 14 of 24 tasks, a coin flip. We kept a trimmed rules file anyway
  (it encodes real Pi/bash behavior, see `prompts/halo.md`), but do not
  expect measurable speed or quality wins from prompt rules on self-contained
  tasks.

### Local vs cloud

- **Qwen vs DeepSeek wall time: about 3.6x on the easy set (29.6 vs 8.2
  s/success) and about 7x on the hard set (170.2 vs 24.6), both all-pass.**
  Long spec/parser code was the worst case for the local model (one task:
  727 s vs 60 s). Consequence: for self-contained tasks the routing question
  is speed and privacy, not capability.

### Concurrency

- **2 or 4 parallel streams give little aggregate gain: 1 stream 63-67 tok/s
  (MTP on), 2 streams aggregate 58-61 tok/s (30-40 per stream), 4 streams
  aggregate 75-77 tok/s (21-24 per stream).** Multi-token prediction turns
  off with more than 1 stream, which eats the batching gain: the sum of
  per-stream rates is about 65-70 at 2 streams (no gain) and at most about
  1.4x at 4, while each stream is about 3x slower. Consequence: parallel
  subagents are not worth it on this box.

### Tool behavior

- **The local model never sets a bash `timeout` itself** (the cloud model did,
  30/60/120 s), so a runaway command blocks the agent indefinitely. The
  `bash-default-timeout` extension injects a 120 s default; when it fired on
  a runaway task rerun, wall time went from 594 s to 353 s.
- **`pi --mode json` hangs when stdin is a non-TTY that never closes** (for
  example an agent shell socket): it waits for stdin forever. Always pass
  `</dev/null`. `evals/run.py` does.

## Limitations

- One machine, one model, one server version. Greedy decoding makes runs
  reproducible but is not how every server runs.
- The eval suite is too easy to separate quality: every arm passed every
  task on both sets, so it measures speed only. We did not find the local
  model's ceiling on well-specified, self-contained tasks.
- Untested: long multi-hour sessions, vague real-world requests, huge repos,
  knowledge-heavy tasks. Numbers here may not transfer to those.

## How to use

1. Install the extensions (see `extensions/README.md`):

   ```bash
   cp extensions/*.ts ~/.pi/agent/extensions/
   ```

2. Drop the prompt file in, named after your provider in `models.json`:

   ```bash
   mkdir -p ~/.pi/agent/model-prompts
   cp prompts/halo.md ~/.pi/agent/model-prompts/<provider>.md
   ```

3. Merge `config-examples/models.json.example` (point `baseUrl` at your
   server, keep `apiKey` as `EMPTY` unless your server needs one) and
   `config-examples/settings.json.example` into `~/.pi/agent/`.
   `showCacheMissNotices` is UI-only and useful for watching misses.

4. Sanity-check the eval graders on your machine (every line should say
   "ok"; the web tasks need network access):

   ```bash
   bash evals/selftest.sh
   ```

5. Run an A/B, for example thinking low vs medium against your provider:

   ```bash
   ./run.py --arm low=<provider>/<model>:low --arm med=<provider>/<model>:medium
   ```

   Set `HALO_METRICS` if your server's metrics endpoint is not
   `http://localhost:8731/metrics`. Then `./report.py results/<run-id>.jsonl`.

## Repo layout

```
extensions/         model-prompts.ts, bash-default-timeout.ts (+ README)
prompts/halo.md     the Qwen guidance prompt that was live during the runs
config-examples/    sanitized models.json / settings.json fragments
evals/              task suite, runner, reporter, grader selftest
evals/results/SUMMARY.md   numbers-only tables from the three runs
tools/              numeric session statistics scripts (stats, tails, misses)
```

The `tools/` scripts read `~/.pi/agent/sessions` and print numbers only, no
session content. They are how the baseline and miss analysis were measured.

## License

MIT, see [LICENSE](LICENSE).
