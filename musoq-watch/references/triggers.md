# Choose a trigger and verify an observation

Examples use PowerShell. The directories referenced below must already exist. Create or change test inputs only in a task-owned fixture. Agree on a stopping boundary before executing a live watch; the commands themselves remain foreground until cancelled.

## Interval: repeat a snapshot

For an authorized two-turn demonstration:

```powershell
musoq run 'SELECT 1 AS Value FROM system.dual()' --format json
musoq watch interval 2s --initial --fail-fast --progress run 'SELECT 1 AS Value FROM system.dual()' --format json
```

Expect `Value=1` in each result document. Cancel after the second completed turn. `--progress` writes lifecycle information to stderr, so an empty successful table can still be distinguished from a session that has not executed.

Interval is a fixed delay after a completed action: slow actions reduce frequency, without overlapping actions or accumulating missed ticks. Without `--initial`, the first action waits for the delay.

## Filesystem: observe a relevant change

```powershell
$watchRoot = (Resolve-Path -LiteralPath './incoming').Path
musoq watch filesystem $watchRoot --recursive --include '**/*.txt' --exclude 'generated/**' --debounce 200ms --max-wait 2s --initial --fail-fast --progress run 'SELECT e.Kind, e.Subject, e.PreviousSubject, e.RequiresResync, e.Properties FROM watch.events() e' --format json
```

An initial turn confirms execution; it is not proof of a filesystem change. After the watcher reports readiness, create or change a matching text file in the authorized input tree. Expect its path in `Subject`; rename events can include `PreviousSubject`. Cancel after the relevant changed-input result has completed. An excluded or out-of-scope file should not schedule an action.

Recursion is explicit; include/exclude patterns match relative paths. Debounce waits for quiet, `--max-wait` bounds batching and must not be shorter than debounce, and `--settle` waits for stable file metadata. Discover less common event and queue controls with `musoq watch filesystem --help`.

Filesystem notifications can duplicate, coalesce, or be lost. Treat them as wakeups to query authoritative state. `RequiresResync=true` calls for a rescan; it does not recover every intermediate change. Output written inside watched inputs can create a feedback loop.

## Query: react to a scalar transition

This example uses the Search provider to observe whether `ready.flag` exists in the existing `incoming` directory. The probe is inline, so its absolute path uses an escaped raw SQL literal; nested action parameters do not bind the probe.

```powershell
$watchRoot = (Resolve-Path -LiteralPath './incoming').Path
$probeRoot = $watchRoot.Replace("'", "''")
$probe = "SELECT Count(*) > 0 AS Ready FROM search.paths(r'$probeRoot', options: (scope: (include: array { 'ready.flag' }))) p"
musoq run $probe --format json
musoq watch query $probe --every 1s --trigger rising --initial --fail-fast --progress run 'SELECT e.Kind, e.Properties FROM watch.events() e' --format json
```

Start with the flag absent for a false baseline. With `--initial`, one action follows the first valid probe even when it is false. Creating the flag then produces a rising transition; leaving it unchanged does not keep running the action. Cancel at the requested boundary. The Search provider must be available; discover a missing datasource through the `musoq` skill rather than installing it implicitly.

| Mode | Qualifying observation after the baseline |
| --- | --- |
| `rising` (default) | Boolean false to true |
| `falling` | Boolean true to false |
| `changed` | A change in scalar type or value, including null |

The probe must return exactly one row and one scalar column. Boolean modes reject non-Boolean values; null Boolean observations retain the baseline. The first valid probe establishes the baseline, and without `--initial` it does not execute the action. Recoverable failures retain the baseline; `--fail-fast` ends the session on a probe or action failure.

## Run an action from a file with dynamic inputs

Save the following as `snapshot.sql` outside the input tree:

```sql
param(root: string)
SELECT p.Name AS Path
FROM system.files($root, false) p
WHERE p.Extension = '.txt'
ORDER BY p.Name
```

```powershell
$actionFile = (Resolve-Path -LiteralPath './snapshot.sql').Path
$watchRoot = (Resolve-Path -LiteralPath './incoming').Path
$actionParameters = @{root=$watchRoot} | ConvertTo-Json -Compress
musoq run $actionFile --from-file --params-json $actionParameters --format json
musoq watch filesystem $watchRoot --include '*.txt' --initial --fail-fast run $actionFile --from-file --params-json $actionParameters --format json
```

Pass JSON as one argument; do not manually double backslashes before serialization. Keep intentional SQL text/regex escapes unchanged. `TAKE` bounds returned rows and may still require scanning, sorting, or aggregating the whole scoped source. Apply the same execution ceilings and repeatable-input requirements as an ordinary `run` action.
