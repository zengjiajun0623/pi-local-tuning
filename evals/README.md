# Pi eval suite (local Qwen on halogen)

23 auto-graded tasks in tasks/NN-name/{task.json,prompt.txt,setup.sh,check.sh,solution.sh}.
(This public copy omits the original task 13, an email-extraction task whose fixture data is email addresses.)
check.sh runs in the work dir after Pi finishes; exit 0 = pass. Graders are hidden from the agent.

- ./selftest.sh   grader audit: every check must FAIL on the untouched fixture and PASS after solution.sh. Run after editing any task.
- ./run.py --arm name=provider/model:thinking[:prompts_dir] ...   interleaved arms, waits for halogen idle, rows to results/<id>.jsonl (resumable with --resume <id>).
- ./report.py results/<id>.jsonl   primary metric s/success (wall / passes); guardrail pass rate; paired view on tasks all arms passed.

Arms' prompts_dir feeds PI_MODEL_PROMPTS_DIR (extension ~/.pi/agent/extensions/model-prompts.ts injects <dir>/<provider>.md):
default ~/.pi/agent/model-prompts (live), "none" = Pi default prompt, variants/<name>/ = candidates.

Greedy decoding on halogen makes runs near-deterministic, so 1 rep per task is usually enough; differences of 1-2 tasks out of 24 are noise-level, look at the per-task disagreements before concluding.
Categories: code-fix, feature, refactor, data, shell, git, config, text, perf, comprehension, testing, web (web tasks depend on network/SearXNG).
