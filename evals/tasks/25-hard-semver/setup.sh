cat > SPEC.md <<'M'
# satisfies(version: str, range: str) -> bool

Versions are `MAJOR.MINOR.PATCH` with an optional prerelease `-id1.id2...` (ids are alphanumerics/hyphens). No build metadata.

## Precedence
Compare MAJOR, MINOR, PATCH numerically. A version with a prerelease is LOWER than the same version without one.
Prereleases compare id by id: numeric ids compare numerically; alphanumeric ids compare in ASCII order;
a numeric id is lower than an alphanumeric id; if all shared ids are equal, the one with more ids is higher.
Example: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0.

## Range grammar
- A range is one or more comparator SETS joined by `||`; it matches if ANY set matches.
- A set is comparators separated by whitespace; it matches if ALL match. An empty set (or `*`) matches any version without a prerelease.
- Comparator: optional operator `<`, `<=`, `>`, `>=`, `=` (none means `=`) directly followed by a partial version.
- Partial versions: `1.2.3`, `1.2`, `1`, and x-ranges where `x`, `X` or `*` stand for a missing part (`1.x`, `1.2.*`).
- Desugaring of partials (M, m, p are numbers):
  - `=1.2` or `1.2` or `1.2.x` -> `>=1.2.0 <1.3.0`; `1` or `1.x` -> `>=1.0.0 <2.0.0`
  - `>1.2` -> `>=1.3.0`; `>1` -> `>=2.0.0`
  - `>=1.2` -> `>=1.2.0`; `<1.2` -> `<1.2.0`
  - `<=1.2` -> `<1.3.0`; `<=1` -> `<2.0.0`
- Tilde: `~M.m.p` -> `>=M.m.p <M.(m+1).0`; `~M.m` -> `>=M.m.0 <M.(m+1).0`; `~M` -> `>=M.0.0 <(M+1).0.0`.
- Caret: `^M.m.p` -> `<(M+1).0.0` if M > 0; else `<0.(m+1).0` if m > 0; else `<0.0.(p+1)`; always with lower bound `>=M.m.p`.
  `^M.m` (or `^M.m.x`) -> `>=M.m.0` and `<(M+1).0.0` if M > 0 else `<0.(m+1).0`. `^M` -> `>=M.0.0 <(M+1).0.0`.
  A prerelease on the tilde/caret version stays on the lower bound (`^1.2.3-beta.1` -> `>=1.2.3-beta.1 <2.0.0`).
- Hyphen: `A - B` (spaces around `-`) -> `>=A <=B`, where a partial B means `<` the next increment
  (`1.2.3 - 2.3` -> `>=1.2.3 <2.4.0`, `1.2.3 - 2` -> `>=1.2.3 <3.0.0`), and a partial A fills zeros.

## Prerelease rule
A version WITH a prerelease satisfies a set only if, in addition to matching all comparators, at least one
comparator in that set (after desugaring) has a prerelease on the SAME MAJOR.MINOR.PATCH.
So `1.2.3-beta.2` satisfies `>1.2.3-beta.1` but not `<1.2.3`, and `1.2.4-beta.1` does not satisfy `^1.2.3-beta.1`.

Invalid versions or ranges raise ValueError.
M
