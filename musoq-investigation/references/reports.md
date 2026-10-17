# Compose a report from pinned evidence

Read `musoq describe manual investigations-reports` before authoring an unfamiliar composition. `musoq describe manual investigations-automation` is the complete executable client example, including invalid-draft correction and output checksums. Use the installed format contract; currently only format 2 is supported. Do not copy a generic visual template into every investigation.

## Establish the source

A report pins a finished investigation revision and checksum. If the investigation is complete, finish with an attributed outcome and explicit remaining unknowns; inconclusive is a valid outcome. If work remains, continue the investigation rather than declaring completion solely for presentation.

Request `report context` with folder, investigationId, sourceRevision, and an optional byte budget. Follow every continuation, preserving source revision and checksum. The first response's source inventory arrays may be empty because inventory is supplied through paged `entries`; do not mistake that for an empty investigation. Expand relevant exact authored reasoning and read/query selected retained evidence before composing.

## Author the visual argument

Choose a layout that explains this question: a timeline for sequence, a coverage map for gaps, a dependency diagram for relationships, or a comparison table for competing cases. Keep limitations and counterevidence beside the conclusion. Native disclosures can hold ancillary method details.

Musoq supplies a protected navigation/provenance shell. The agent supplies exactly one `h1`, an HTML body, scoped CSS, plain CommonMark fallback, export scope, and attribution. Supply `suppliedModel: null` when no exact model identity was supplied. Musoq does not call a model or certify authored conclusions.

Bind selected evidence-derived values instead of typing competing copies. A binding pins observationId, version, captureId, artifactSha256, zero-based capturedRow and columnOrdinal. Both the HTML placeholder and Markdown token must exist. Calculations use declared binding inputs; derive complex SQL results first. Exact arithmetic does not establish semantic truth.

Minimal composition fragment, using an inspected observation at the finished source revision:

```powershell
$binding = @{id='amount';label='Selected amount';units='units';scope='One synthetic captured row';
 evidence=@{observationId=$captured.observationId;version=$captured.version;captureId=$captured.captureId;
 artifactSha256=$opened.artifactSha256;capturedRow=0;columnOrdinal=0}}
$composition = @{formatVersion=2;
 htmlBody='<h1>Selected amount</h1><table><caption>Exact retained amount</caption><thead><tr><th scope="col">Measure</th><th scope="col">Value</th></tr></thead><tbody><tr><th scope="row">Amount</th><td data-musoq-value="amount"></td></tr></tbody></table><p>Coverage outside the selected row remains unknown.</p>';
 css=':root{--report-ink:#203040} table{color:var(--report-ink)}';
 markdown="# Selected amount`n`n[musoq-value:amount] units. Coverage outside the selected row remains unknown.";
 data=@($binding);exportAuthorization='Export only this selected synthetic amount and its provenance.';
 generatorAttribution='Externally authored by the investigating agent; exact model identity not supplied.'}
```

Tables need captions and explicit header scope (`row`, `col`, or appropriate grouped scopes). Missing structure produces `TABLE_CAPTION` or `TABLE_HEADERS`. Meaningful SVG requires accessible labeling; decorative graphics do not establish data verification. CSS is scoped away from the protected frame; root rules declare custom properties. Scripts, resource URLs, external fonts/images, forms, frames, event handlers, and fixed positioning are unsupported. Use current validation diagnostics rather than assuming arbitrary browser HTML/CSS is permitted.

Credential-like content is rejected by default. Use a binding's explicit redaction reason when authorized export needs a redacted derivative; do not alter retained evidence. Redacted values cannot supply arithmetic. Export only selected data within the authorized scope; local publication is not permission to upload or send a report.

## Submit, validate, correct, publish

Serialize requests to UTF-8 files. The new-report request is:

```powershell
$state = musoq investigation open $folder | ConvertFrom-Json
$submit = @{folder=$folder;investigationId=$state.id;expectedRevision=$state.revision;
 operationId=[Guid]::NewGuid().ToString();reportId=[Guid]::NewGuid().ToString();expectedReportRevision=0;
 source=@{investigationId=$state.id;revision=$finishedRevision;sha256=$sourceHash};
 title='Selected amount';author=$author;suppliedModel=$null;composition=$composition}
```

Use `report submit --request-file <path>`, then `report validate` with folder, investigationId, reportId, and optionally includePreview. Submission returns workspace state; `report open` returns `report`, `composition`, and `view`. An invalid validation can return exit code 1 with structured diagnostics and empty preview; retain stdout/stderr/status before deciding how to correct it.

For a correction, open the same report, read current workspace state, replace the composition, and submit with a new operation ID and the current `report.revision` as expectedReportRevision. Preserve reportId and source pin. Do not use presentationVersion as the concurrency token or create a new report merely to repair CSS or accessibility. Revalidate before publishing.

Publication takes folder, investigationId, expectedRevision, operationId, reportId, and expectedReportRevision. Use the current workspace and report revisions. Publication revalidates atomically, preserving a prior publication if a correction fails. Retry the identical saved publication request after a lost response. A report for a different finished source revision needs a new report identity.

## Verify the deliverable

Open the published report and resolve `view.htmlPath` and `view.markdownPath` against the absolute workspace folder. Independently hash both files and compare with `report.publication.htmlSha256` and `markdownSha256`. Check that selected values, limitations and attribution survived the export. Distinguish report revision, presentation version, and published presentation version.

Return the standalone HTML, Markdown fallback, and workspace location as requested. Test browser/print behavior when those qualities are part of the requested deliverable; checksum and text checks alone are not browser qualification. Reports disclose their selected integrity scope, execution lineage and applicability at publication. Later source changes or deletion do not update or revoke exported copies.
