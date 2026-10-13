# Data analysis

Select the needed recipe, edit its inputs and run it. Replace small `values { ... }` fixtures with scoped sources when adapting joins and comparisons.

| Task | Executable SQL | Inputs to edit | Expected shape / fixture answer |
|---|---|---|---|
| Group CSV rows | [csv-totals](../recipes/csv-totals.sql) | path; Customer, Amount columns | Customer, Orders, Total; Ada 2/30, Bob 1/7 |
| Select nested JSON values | [json-paths](../recipes/json-paths.sql) | stdin, selected paths | Path, Value; tags[0]=docs, user.name=Ada |
| Expand stdin lines | [apply-lines](../recipes/apply-lines.sql) | text on stdin | Value per line |
| Summarize file metadata | [file-stats](../recipes/file-stats.sql) | root, recursion | Extension, Files, Bytes |
| Join and aggregate | [join-totals](../recipes/join-totals.sql) | rows, key, measure | Customer, Orders, Total |
| Find duplicate keys | [duplicates](../recipes/duplicates.sql) | source and key | Id, Copies; 10 occurs twice |
| Missing counterparts | [missing](../recipes/missing.sql) | left/right source, key | MissingId; 2 |
| Handle nulls explicitly | [nulls](../recipes/nulls.sql) | nullable field | Id, Label; missing / ready |
| Rank within each group | [rank](../recipes/rank.sql) | partition, score, tie breaker | Category, Name, Score, Position; A and C |
| Compare snapshots | [compare](../recipes/compare.sql) | previous/current inputs, key, value | Id, Change; 1 changed, 2 removed, 3 added |

Pipe JSON in PowerShell:

```powershell
'{"user":{"name":"Ada","active":true},"tags":["docs","sql"]}' |
  musoq run (Resolve-Path -LiteralPath 'json-paths.sql').Path --from-file --format json
```

Use [execution](execution.md) for Bash quoting and typed `param(...)` binding. For CSV, `comma(path, true, 0)` reads the header; this recipe explicitly casts Amount to int. If the header differs, inspect this file's concrete source once. Keep a compile-time `let` path for this recipe.

Before joining, know the intended key cardinality. Two matching right-side keys duplicate each matching left row; the validation fixture demonstrates Ada's two orders becoming four and total 30 becoming 60. Use [duplicates](../recipes/duplicates.sql) on uncertain keys; choose an actual aggregation/key policy instead of hiding duplication with DISTINCT.

The missing-counterpart and comparison recipes assume non-null keys; the comparison also assumes unique keys on each side. Compare nullable values with `IS DISTINCT FROM`; `= null` is not an absence test. The comparison uses two left joins plus UNION ALL.

Rank in a CTE, then filter its row number. Include a stable tie breaker when one winner is required. Aggregate before ranking if the metric is itself a total.
