# Eval results summary

Numbers-only output of `report.py` for each run. Primary metric is wall
seconds per successful task (lower is better). Arm names: `cur-*` = prompt
rules active, `bare-*` = Pi default prompt (no rules), `*-low/high` = thinking
level, `ds-*` = DeepSeek Flash (cloud), `q-*` = local Qwen.

## 20261004-133029: easy set (tasks 01-24), local Qwen arms

```
arm           pass s/success wall_sum wall_p50  turns out_tok reason% calls/turn tool_err   tps mtp_acc prefill_s timeouts
cur-low     24/24       29.6      709     22.1    5.6    1406     34%       0.84        3  61.3    0.78       101        0
bare-low    24/24       25.9      623     18.1    5.2    1232     35%       0.83        4  61.1    0.79       100        0
cur-high    24/24       61.7     1481     26.9    6.6    2071     41%       0.94        6  60.7    0.77       126        0

paired on 24 task(s) every arm passed:
  cur-low    wall_sum=    709s  wall_p50=  22.1s  out_tok_sum=  33734
  bare-low   wall_sum=    623s  wall_p50=  18.1s  out_tok_sum=  29574
  cur-high   wall_sum=   1481s  wall_p50=  26.9s  out_tok_sum=  49711

per category (pass):
  code-fix       cur-low=3/3  bare-low=3/3  cur-high=3/3
  comprehension  cur-low=1/1  bare-low=1/1  cur-high=1/1
  config         cur-low=3/3  bare-low=3/3  cur-high=3/3
  data           cur-low=4/4  bare-low=4/4  cur-high=4/4
  feature        cur-low=2/2  bare-low=2/2  cur-high=2/2
  git            cur-low=2/2  bare-low=2/2  cur-high=2/2
  perf           cur-low=1/1  bare-low=1/1  cur-high=1/1
  refactor       cur-low=1/1  bare-low=1/1  cur-high=1/1
  shell          cur-low=2/2  bare-low=2/2  cur-high=2/2
  testing        cur-low=1/1  bare-low=1/1  cur-high=1/1
  text           cur-low=1/1  bare-low=1/1  cur-high=1/1
  web            cur-low=3/3  bare-low=3/3  cur-high=3/3
```

## 20261004-134119: easy set (tasks 01-24), DeepSeek Flash (cloud) arm

```
arm           pass s/success wall_sum wall_p50  turns out_tok reason% calls/turn tool_err   tps mtp_acc prefill_s timeouts
ds-high     24/24        8.2      196      6.3    5.0     962     33%       0.92        1   nan     nan         0        0

per category (pass):
  code-fix       ds-high=3/3
  comprehension  ds-high=1/1
  config         ds-high=3/3
  data           ds-high=4/4
  feature        ds-high=2/2
  git            ds-high=2/2
  perf           ds-high=1/1
  refactor       ds-high=1/1
  shell          ds-high=2/2
  testing        ds-high=1/1
  text           ds-high=1/1
  web            ds-high=3/3
```

## 20261004-144120: hard set (tasks 25-34), DeepSeek Flash vs local Qwen

```
arm           pass s/success wall_sum wall_p50  turns out_tok reason% calls/turn tool_err   tps mtp_acc prefill_s timeouts
ds-high     10/10       24.6      246     19.9    6.7    5239     55%       1.06        7   nan     nan         0        0
q-low       10/10      170.2     1702     83.4   13.1    9115     48%       0.96       12  60.5    0.76       136        0
q-high      10/10      173.4     1734     88.6   10.8    9447     48%       0.94       10  59.2    0.74       102        0

paired on 10 task(s) every arm passed:
  ds-high    wall_sum=    246s  wall_p50=  19.9s  out_tok_sum=  52392
  q-low      wall_sum=   1702s  wall_p50=  83.4s  out_tok_sum=  91152
  q-high     wall_sum=   1734s  wall_p50=  88.6s  out_tok_sum=  94467

per category (pass):
  hard-async     ds-high=1/1  q-low=1/1  q-high=1/1
  hard-build     ds-high=1/1  q-low=1/1  q-high=1/1
  hard-comprehension ds-high=1/1  q-low=1/1  q-high=1/1
  hard-concurrency ds-high=1/1  q-low=1/1  q-high=1/1
  hard-data      ds-high=1/1  q-low=1/1  q-high=1/1
  hard-debug     ds-high=1/1  q-low=1/1  q-high=1/1
  hard-git       ds-high=1/1  q-low=1/1  q-high=1/1
  hard-parser    ds-high=2/2  q-low=2/2  q-high=2/2
  hard-spec      ds-high=1/1  q-low=1/1  q-high=1/1
```
