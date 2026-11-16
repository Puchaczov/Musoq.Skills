# Repeat a validated observation

Use `musoq-watch` when installed for trigger selection, rolling comparisons, state management, replay/attach, and recovery. This fallback supports a small foreground observation.

Infer a duration or stopping condition from the request; ask when neither is supplied. For an authorized two-turn demonstration, validate the ordinary query and then start:

```text
musoq run "SELECT 1 AS Value FROM system.dual()" --format json
musoq watch interval 2s --initial --fail-fast run "SELECT 1 AS Value FROM system.dual()" --format json
```

It emits Value=1 each turn until cancelled. Observe two completed turns and cancel through the owning process, verifying its exit. For a real trigger test, success also requires observing a relevant input change. This does not establish an unattended scheduler.

For an unfamiliar trigger, read only `musoq watch filesystem --help`, `musoq watch interval --help`, or `musoq watch query --help`. Provider flags precede `run`; action flags follow it. Filesystem recursion is explicit. Notifications are wakeups, not a complete transaction log: events can coalesce or be lost, and `RequiresResync` means rescan authoritative state.

Keep output and retained state outside watched inputs. Omit `--state` unless persistence is requested; inspect an existing name before reuse. Bound action cost, output bytes, and history separately. `--keep-for` limits history age, not session lifetime.

For retained state, read the relevant `musoq watch state --help`, `musoq watch replay --help`, or `musoq watch attach --help`. Inspect generations before replay; replay re-executes from retained inputs and attach delivers committed results. Retention gaps require reconciliation, and reset/delete loses history.

Redirected JSON can contain separate result documents; keep stderr diagnostics separate. Validate event-dependent and rolling actions inside Watch: ordinary `watch.events()` has no batch and rolling sources require preparation. For a failed ordinary source query, diagnose it once with `musoq run` before restarting. Inspect state after ambiguous publication/delivery failures, and stop repeated failures rather than leaving a noisy observation running.
