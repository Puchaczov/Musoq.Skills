# Repeat a validated observation

Run the action once with ordinary `musoq run`, then choose a filesystem, interval, or query trigger. A small foreground interval example is:

```text
musoq watch interval 2s --initial run "SELECT 1 AS Value FROM system.dual()" --format json
```

It emits Value=1 each turn until cancelled. For a bounded demonstration, observe two turns and cancel through the owning process. Success means the action returns expected rows, a relevant input change is observed when testing a trigger, and the process stops. This does not establish an unattended scheduler.

For an unfamiliar trigger, read only `musoq watch filesystem --help`, `musoq watch interval --help`, or `musoq watch query --help`. Provider flags precede `run`; action flags follow it. Filesystem recursion is explicit. Notifications are wakeups, not a complete transaction log: events can coalesce or be lost, and `RequiresResync` means rescan authoritative state.

Keep output and retained state outside the watched input tree. Omit `--state` for isolated ephemeral runs; choose a durable name only when persistence is requested, and inspect an existing name before reuse. Bound action cost, output bytes per turn, state bytes, and retained generations separately. Query or parameter changes may make durable state incompatible.

For retained state, use `musoq describe command watch state`, `watch replay`, or `watch attach` as needed. Inspect generations before replay. Consumers needing duplicate protection require checkpoints or deduplication; retained generations do not promise exactly-once delivery or atomic cross-file snapshots. A retention gap requires reconciliation. Reset/delete loses history; use a new name when starting a separate observation.

Redirected JSON output may contain separate result documents rather than one JSON array; inspect its framing and keep stderr diagnostics separate. If the action fails, run that query once with ordinary `musoq run`, inspect its diagnostic, correct it, then restart Watch. Stop repeated failures rather than leaving a noisy observation running.
