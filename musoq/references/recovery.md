# Recover from failures or contradictory results

Preserve the original command, SQL, exit code and diagnostics. If the user asks for a failure log, include exact inputs and distinguish intentional negative tests from regressions; omit credentials. Correct one evidenced cause and retry the smallest relevant query.

| Observed diagnostic | Narrow next command/action | Correction |
|---|---|---|
| Unknown CLI option/subcommand | `musoq <exact-command> --help` or `musoq describe command <static-path>` | Use the reported grammar; dynamic Watch providers use their own --help |
| Unknown source / missing provider | `musoq describe schema --filter <name>` | Use [datasource discovery](datasources.md) for installed alternatives, registry candidates or specialized providers; install only within authorized scope |
| Wrong source argument/record field | `musoq describe arguments <schema.method> --filter <field>` | Match the reported scalar/record/array type |
| Unknown column | `musoq describe source "<exact-source-call>" --top-level-only` | Project available columns; expand nested collections with APPLY |
| Unknown function/overload | `musoq describe functions <schema> --filter <name>` | Use the observed signature and argument types |
| Parser error | Read its location and nearest SQL statement | Fix quoting, declaration order, alias or syntax; read only the named spec section if needed |
| Search read/encoding/queue failure | Narrow to exact paths or a smaller subtree | Retry a small source once; use a direct file reader/search fallback if progress stops |
| Connection/instance error | `musoq get instance` and the returned help action | Use the intended existing instance; diagnose before changing state |
| MQ9001/internal compiler failure | Save minimal reproducer and correlation ID | Use a validated equivalent form or fall back; retain the failure for repair |
| Successful exit but rows contradict known evidence | Minimize the query and inspect its planning with the same inputs | Compare expected/actual rows and pushed/residual predicates; preserve a reproducer |
| Malformed CSV/JSON/text/bytes | Read the source-level diagnostic as well as the wrapper | Correct the input or explicitly account for rejected rows |

After two informed corrections without progress, switch to an available tool such as direct file reads, Git, rg or a data parser. State the fallback and any lost completeness. Do not repeatedly widen scans or repeat an unchanged failure.

For contradictory results, retain exact SQL, parameter/settings bindings, scope and independently expected rows. Reduce to the smallest fixture before inspecting:

```powershell
musoq inspect $query --from-file --stage planning --format json --params-json (@{root=$root} | ConvertTo-Json -Compress)
```

```bash
musoq inspect "$query" --from-file --stage planning --format json --params-json "$params_json"
```

Use the same JSON bindings as the failing run, including settings profiles when present. Planning distinguishes predicates pushed toward a source from work retained for runtime evaluation; unsupported source work must remain residual. Compare the plan with the expected relationship, then verify rows independently. Inspection is diagnostic evidence, not proof of correctness, and ordinary queries need no inspection preflight. Preserve suspicious plans and results rather than changing provider state.

Prefer the validated regex recipe's explicit record framing, CSV recipe's compile-time path and comparison recipe's two left joins when those operations match the task. Compatibility evidence and reproduction commands belong in maintainer validation records, not a setup ritual.

Do not restart services, purge state or install packages merely because a query failed. Preserve live work and choose a correction justified by the diagnostic.
