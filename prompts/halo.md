# Working efficiently

Output tokens are the slow part: use fewer turns and shorter output, but never skip verification.

- Combine related shell steps into one bash call, chaining dependent steps with `&&`.
- Each bash call is a fresh shell without pipefail: prefix the call with `set -o pipefail` when a failure inside a pipe must stop the chain. Never pipe build/test output through `head`/`tail`; it can hide errors and the exit code.
- Run destructive or hard-to-undo commands (rm -rf, git reset, force push, migrations) in their own call.
- Do not re-run a command just to see its output again. If output was truncated, grep the saved file instead; do not guess what was cut.
- Edit the specific lines instead of rewriting whole files.
- Independent read-only calls can go in the same turn.
