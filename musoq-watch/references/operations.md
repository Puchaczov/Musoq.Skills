# Inspect, replay, consume, and recover

Examples assume `$stateName` names an existing authorized state. Inspect its identity and generations before using it. Destination directories must exist; keep exports and cursors outside watched inputs.

## Inspect a session or retained state

```powershell
musoq watch list
musoq watch state list
musoq watch state show $stateName
musoq watch state generations $stateName
```

`watch list` shows active foreground sessions without action SQL or parameter secrets. `state list` shows durable history; durable state can remain after a session stops. Listing a session does not grant ownership of its process.

## Replay a chosen generation

Set `$generationId` to the actual generation selected from the inspected `state generations` output, respecting any ID already supplied by the user:

```powershell
musoq watch replay $stateName --generation $generationId --format json
```

Replay re-executes the action from retained captures without querying live datasources. It can fail if required history is unavailable. It does not mean that the original inputs still have those values. Omitting the generation selects the runtime's default; choose explicitly when reproducibility matters.

When the user intends to publish that replay as another generation, add `--recommit` to the same command. This mutates history and can deliver another result to attached consumers. An ordinary replay does not request recommit.

## Attach to committed output

```powershell
musoq watch attach $stateName --from-beginning --once --format json
```

Attach delivers already committed results. `--once` drains currently available generations and exits; without it attach can wait for future commits and needs an agreed stopping boundary. `--from-beginning` starts with the oldest retained feed-capable generation; `--after $generationId` starts exclusively after a known ID. Do not combine the two.

For resumable delivery, choose a cursor file owned by this consumer:

```powershell
$cursorRoot = (Resolve-Path -LiteralPath './consumer-state').Path
$cursorFile = Join-Path $cursorRoot 'incoming-files.cursor.json'
musoq watch attach $stateName --from-beginning --cursor-file $cursorFile --once --format json
# Resume the same consumer with its existing cursor:
musoq watch attach $stateName --cursor-file $cursorFile --once --format json
```

Use `--from-beginning` to initialize a new cursor, not to override an existing one. Do not share a cursor among independent consumers. A cursor tracks delivery position rather than a transaction in the receiving system: use downstream idempotency/checkpoints when duplicate processing matters. If retention has removed the cursor's required history, report the gap and reconcile instead of claiming complete delivery.

## Export or discard history deliberately

```powershell
$exportRoot = (Resolve-Path -LiteralPath './exports').Path
$exportFile = Join-Path $exportRoot ($stateName + '.zip')
musoq watch state export $stateName --output $exportFile
```

Export preserves a bundle; add `--force` only when replacing that destination is intended. `--decrypt` exposes action, event, and row data and needs authorization for that disclosure.

After the requested discard is authorized, choose exactly the relevant operation:

```powershell
# Discard all history and definition metadata:
musoq watch state reset $stateName --force
# Or delete the whole state:
musoq watch state delete $stateName --force
# Or delete one selected non-head generation from a retained state:
musoq watch state delete $stateName --generation $generationId --force
```

These are alternatives, not a cleanup sequence. Inspect the target first; do not use reset/delete as an automatic repair for a definition mismatch. Use the authorization already supplied for task-owned disposable fixtures. Verify the resulting state after mutation.

## Output, failure, and cancellation

The nested action chooses output format; attach/replay have their own `--format`. Interactive tables can refresh in place, while redirected and machine output is append-only. JSON can be a sequence of result documents, not one combined JSON array. Keep stderr progress/diagnostics separate and parse complete documents before consuming rows. CSV controls such as `--csv-escape-controls` belong to nested `run` for actions and directly to `attach` for a consumer.

| Symptom | Next step |
| --- | --- |
| No result yet | Check readiness, `--initial`, trigger timing, probe baseline, and whether the last successful result was empty |
| Ordinary query fails | Run it once with `musoq run`, inspect its diagnostic, correct it before repeating |
| Intended SQL is treated as a missing script | Add `--hint sql` to nested `run` to select SQL explicitly |
| Event/rolling action fails | Keep it in Watch context; inspect action diagnostics and verify the underlying source query separately |
| Runtime/plugin loading error | Record runtime and provider identity, stop the failed run, and compare with a minimal built-in-source action before attributing it to SQL; resetting history does not repair runtime loading |
| Repeated probe/action failures | Inspect one failure, correct or stop at the agreed boundary; use `--fail-fast` for a bounded diagnostic run |
| Output or storage quota exceeded | Reduce scope/output or adjust the specific authorized budget; do not treat partial output as a successful generation |
| Publication/delivery outcome is unclear | Inspect the reported candidate/generation and retained state before any retry or recommit |
| State definition or version is incompatible | Preserve history, inspect the definition, then use a new name or an explicitly authorized reset |
| Cursor or history gap | Report incomplete coverage and reconcile with authoritative state |

Recoverable failures normally leave observation running; invalid configuration is not an empty successful result. Diagnostic absence on stdout is expected when stderr carries the error. When stopping, send `Ctrl+C` to the owning process and wait for its cancellation/exit; external providers may take time to release resources. Distinguish a successfully observed result from cancellation exit status (commonly 130). If graceful cancellation fails, report the remaining owned process and use only authorized process cleanup. Do not issue a global `musoq quit` or stop another session to clean up one observation.
