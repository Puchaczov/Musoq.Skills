# Continue without silently changing the evidence

Read `musoq describe manual investigations-recall` for bounded recall, `investigations-reuse` for reviews/import, or `investigations-capture` for stopped captures. Discover exact options with native help or `describe command` for the chosen operation.

## Resume a supplied workspace

1. Run `musoq investigation open <absolute-folder>` and verify identity, scope, status, current revision and pending attempts. Opening is a read, not a repair.
2. Use `musoq investigation recall <folder> --id <id> --budget-bytes 16384`. Follow every continuation. Check `hasMore`, omissions, and the pinned revision before claiming complete metadata recall.
3. Expand relevant authored notes, claims, and assessments using `reasoning open --kind ... --item-id ... --version ...`. Inspect pinned observations and query needed retained rows before relying on conclusions.
4. Preserve counterevidence, review warnings, limitations and remaining unknowns. Decide whether the user needs a read, further investigation, or a report; do not reopen merely to read history.

Recall is metadata, not the full authored text or evidence. A complete recall is not an independent observation. Continuations remain tied to their original revision after later edits; do not merge pages from different source pins.

Example, with `$folder` an absolute existing path and `$investigationId` from `open`:

```powershell
$continuation = $null
$pinnedRevision = $null
$recallPages = @()
do {
 $argv = @('investigation','recall',$folder,'--id',$investigationId,'--budget-bytes','16384')
 if ($continuation) { $argv += @('--continuation',$continuation) }
 # Preserve stdout/stderr/exit status as described in the evidence reference.
 $page = & musoq @argv | ConvertFrom-Json
 if ($LASTEXITCODE -ne 0) { throw 'Inspect recall failure before continuing.' }
 if ($null -eq $pinnedRevision) { $pinnedRevision = $page.revision }
 if ($page.revision -ne $pinnedRevision) { throw 'Do not combine different recall revisions.' }
 if ($page.investigationId -ne $investigationId) { throw 'Unexpected recall identity.' }
 $recallPages += $page
 # For large inventories, persist each page rather than keeping all pages in memory.
 if ($page.hasMore -and -not $page.continuation) { throw 'Incomplete recall without continuation.' }
 $continuation = $page.continuation
} while ($continuation)
```

If a complete item cannot fit, increase the supported byte budget; do not silently skip it. `musoq investigation show <folder> --raw --revision <revision>` reads the complete saved scratchpad, but does not substitute for expanding all authored bodies and tables. `changes --take ... --before-revision ...` pages committed notifications newest first without delivering effects or repairing storage.

## Inspect pending or failed captures

`observation attempt <folder> --id <id> --capture-id <capture-id>` inspects an attempt, including a failed replacement. Reuse the saved operation/request after a lost response; do not issue fresh SQL just to learn its outcome.

For a stopped capture, inspect first, establish that its writer is stopped, then use `observation recover` with the current workspace revision, capture ID and a saved operation identity. Recovery never reruns the query. It can publish a valid sealed result or record interrupted/unavailable retention. It rejects an active writer. An unknown execution is not proof of zero source rows; a failed replacement leaves the prior current observation intact.

On `INVESTIGATION_CONFLICT`, reopen and review concurrent state. On corruption/checksum errors, preserve the folder and report the affected pin or artifact; do not edit manifests, discard evidence, or attempt silent repair. If no immutable original result exists, promotion reports `ORIGINAL_RESULT_UNAVAILABLE`; a new source execution needs explicit capture and a distinct identity.

## Applicability, imports, and deletion

These operations are conditional on the task, not mandatory stages. Read `musoq describe command investigation observation review` or `import` and the reuse manual before constructing their current request.

| Operation | Required judgment |
| --- | --- |
| Review applicability | State current, changed, or unknown with explicit scope, reason, author and role. Reading a checksum or calculating from old rows does not establish present source applicability. |
| Import original observation | Use existing authorization to reuse the exact source investigation/version/checksum in the target scope. Record the explicit cross-investigation authorization and attribution. Import reads saved files, preserving original execution lineage; it is not new corroboration or proof of another actor's authenticity. |
| Delete retained payload | Require authorization covering these specific payloads and its recorded deletion reason/authorization. Historical metadata and references remain; deleted rows cannot be restored by a later review. |

Reviews and parent replacement can flag dependent assessments and derivations. Revalidating an old result's current use is an attributed review; re-executing a source is a new explicit capture. Neither implies human approval.

Keep logical investigation deletion separate from payload deletion. Logical deletion preserves history and exports but prevents reopening. Copying an entire workspace is a portable history copy, not evidence of independent execution. Deletions do not revoke previous folder copies or exported reports.

## Reopen only for new work

A finished workspace reports `status: closed`. `reopen` creates a new revision for further authorized investigation while preserving the finished source. Use its returned revision for subsequent mutations. Finish again with an explicit outcome and unknowns when that work is actually complete; do not change an earlier report's immutable source pin.
