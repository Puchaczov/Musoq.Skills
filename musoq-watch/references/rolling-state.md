# Compare successive snapshots and retain state

Use rolling state when the question depends on previous captures, differences, or later replay. A plain repeated query does not need rolling SQL. Named state can retain committed action results even without rolling references.

## Start with a bounded comparison

The following action uses the built-in filesystem source, exposes a relation named `currentFiles`, and returns newly added text-file names. Save it as `added-files.sql` outside the watched inputs:

```sql
param(root: string)
WITH currentFiles AS (
 SELECT p.Name AS Path
 FROM system.files($root, false) p
 WHERE p.Extension = '.txt'
)
SELECT c.Path AS Path FROM currentFiles c
EXCEPT
SELECT p.Path AS Path FROM watch.previous('currentFiles') p
```

For persistence requested by the user, select a fresh descriptive name or inspect their existing state first:

```powershell
$stateName = 'incoming-files'
musoq watch state list
# If this name already exists, inspect it before deciding to reuse it:
# musoq watch state show $stateName
$watchRoot = (Resolve-Path -LiteralPath './incoming').Path
$actionFile = (Resolve-Path -LiteralPath './added-files.sql').Path
$actionParameters = @{root=$watchRoot} | ConvertTo-Json -Compress
musoq watch filesystem $watchRoot --include '*.txt' --initial --state $stateName --keep-generations 10 --keep-for 1h --max-state-bytes 64MiB --max-output-bytes 4MiB --fail-fast --progress run $actionFile --from-file --params-json $actionParameters --format json
```

For a new state, the initial result contains current text-file names compared with an empty previous relation. After readiness, adding one text file should produce its name in the next difference. Cancel after the requested observation, then inspect retained generations. Validate the base filesystem query separately with ordinary `run`; the complete action above needs Watch preparation. This example observes one directory without recursion; use `FullName` as the identity and align the trigger's recursion when comparing descendants.

Omit `--state` for an isolated ephemeral comparison whose state is removed when its foreground session closes. A new rolling session without `--initial` still captures a startup baseline before waiting for triggers; source reads can happen before any displayed action result.

## Choose the relation to compare

| Source | Purpose |
| --- | --- |
| `watch.previous('currentFiles')` | Read the previous capture of this relation |
| `watch.added('currentFiles')` | Read added rows, preserving added multiplicity |
| `watch.removed('currentFiles')` | Read removed rows, preserving removed multiplicity |
| `watch.diff_summary`, `watch.generations`, `watch.generation` | Summarize changes or select retained history |

To include additions and removals, keep the same `currentFiles` CTE and replace the final comparison with:

```sql
SELECT a.Path AS Path, 'added' AS Change FROM watch.added('currentFiles') a
UNION ALL
SELECT r.Path AS Path, 'removed' AS Change FROM watch.removed('currentFiles') r
```

The original `EXCEPT` example is a set comparison; use `watch.added`/`watch.removed` when duplicate counts matter. Bind relation names explicitly. Discover arguments for history/summary sources through the installed rolling workflow and confirm them inside Watch; do not infer their shape from the previous-relation example. Avoid changing an existing state's action just to experiment: changes to SQL, parameters, source identities, or paths can make its definition incompatible.

## Bound and inspect history

```powershell
musoq watch state show $stateName
musoq watch state generations $stateName
```

Select generation IDs from this output for [replay and attach](operations.md). Keep count (`--keep-generations`), age (`--keep-for`), and total retained bytes (`--max-state-bytes`) distinct from per-turn output bytes (`--max-output-bytes`). None is a session timer or a whole-process memory limit. Pruned generations cannot be replayed or delivered later.

`--skip-unchanged` compares exposed candidate slots before the action runs. It can avoid the action entirely and is not deduplication of completed query output. Use it only when that matches the observation being requested.

Publication is confirmed before stdout delivery. A delivery failure can therefore leave a committed generation; inspect state before retrying. Retained captures do not establish atomic snapshots across independent files or exactly-once downstream processing. Reconcile authoritative inputs after a history gap.

Use another name for an incompatible new observation, or reset an existing state only when authorized to discard its history. Earlier Watch state/definition formats are not automatically migrated: preserve them and use the matching runtime for recovery rather than overwriting them.
