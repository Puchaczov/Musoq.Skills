# Capture evidence and assess scoped claims

Use `musoq describe manual investigations-capture`, `investigations-reasoning`, or `investigations-saved-evidence` for the current operation contracts. The complete client at `musoq describe manual investigations-automation` demonstrates structured error handling; do not rebuild that entire client for a small task.

## Paths and invocation outcomes

In PowerShell, `Set-Location` changes the provider location without necessarily changing the process directory used by `.NET` relative paths. Resolve filesystem paths before passing them to either native commands or `.NET` file APIs:

```powershell
# Choose this output root outside the investigated inputs. This example starts fresh.
$PSNativeCommandUseErrorActionPreference = $false
if ($PWD.Provider.Name -ne 'FileSystem') { throw 'Choose a filesystem location.' }
$artifactRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('./amount-review-artifacts')
if (Test-Path -LiteralPath $artifactRoot) { throw 'Choose a new artifact root or open the existing workspace.' }
New-Item -ItemType Directory -Path $artifactRoot | Out-Null
$folder = Join-Path $artifactRoot 'workspace'
$author = 'investigating-agent'
```

Example blocks below form one session. Save exact requests before invoking mutations. Capture native stdout and stderr separately, record `$LASTEXITCODE` immediately, then parse stdout when present. Check process status before using a successful-result shape. For a nonzero outcome, retain any parsed JSON and inspect its execution/retention or validation fields; do not discard it in a generic exception. For repeated calls, use the installed automation walkthrough's recorder or equivalent logging, including both streams and exit codes.

## Create, record the oracle, capture once

This example's independent oracle is one decimal cell, `123.4500`; doubling it should produce `246.9000`. Record such expectations in an attributed note before executing substantive probes.

```powershell
$createdText = musoq investigation create $folder --title 'Amount review' --objective 'Retain and compare an exact decimal' --scope 'One synthetic row' 2> (Join-Path $artifactRoot 'create.stderr')
$createdExit = $LASTEXITCODE
$createdText | Set-Content -LiteralPath (Join-Path $artifactRoot 'create.json') -Encoding utf8
if ($createdExit -ne 0) { throw 'Inspect create.stderr before continuing.' }
$created = ($createdText -join "`n") | ConvertFrom-Json
$investigationId = $created.id
$oraclePath = Join-Path $artifactRoot 'oracle.md'
'One retained decimal should be 123.4500; doubling the saved value should be 246.9000. Synthetic fixture only.' | Set-Content -LiteralPath $oraclePath -Encoding utf8
$noteText = musoq investigation note add $folder --id $investigationId --expected-revision $created.revision --title 'Independent fixture oracle' --content-file $oraclePath --author $author --author-role agent 2> (Join-Path $artifactRoot 'oracle.stderr')
$noteExit = $LASTEXITCODE
$noteText | Set-Content -LiteralPath (Join-Path $artifactRoot 'oracle.json') -Encoding utf8
if ($noteExit -ne 0) { throw 'Inspect the note outcome before capturing.' }
$noted = ($noteText -join "`n") | ConvertFrom-Json
$queryPath = Join-Path $artifactRoot 'amount.sql'
"select 123.4500 as Amount from system.dual()" | Set-Content -LiteralPath $queryPath -Encoding utf8
$operationId = [Guid]::NewGuid().ToString()
# Save these exact argv and operationId if capture might need a retry.
$captureArgs = @('investigation','capture',$folder,'--id',$investigationId,
 '--expected-revision',([string]$noted.revision),'--operation-id',$operationId,
 '--title','Selected amount','--query-file',$queryPath)
$captureArgs | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $artifactRoot 'capture-argv.json') -Encoding utf8
$captureText = & musoq @captureArgs 2> (Join-Path $artifactRoot 'capture.stderr')
$captureExit = $LASTEXITCODE
$captureText | Set-Content -LiteralPath (Join-Path $artifactRoot 'capture.json') -Encoding utf8
$captured = if (($captureText -join "`n").Trim()) { ($captureText -join "`n") | ConvertFrom-Json }
if ($captureExit -ne 0 -or -not $captured -or $captured.pending -or
 $captured.outcome.execution.status -ne 'succeeded' -or $captured.outcome.retention -ne 'full') {
 throw 'Inspect the saved capture outcome and stderr; do not treat partial evidence as complete.'
}
if ($captured.outcome.execution.observedRows -ne 1 -or $captured.outcome.retainedRows -ne 1) {
 throw 'The fixture must retain exactly one observed row.'
}
```

The note publishes a revision before capture; capture uses that returned revision rather than the creation revision. For a real investigation, adapt its authored method/oracle and scope before running the source.

When inputs are not synthetic, consider normal provider side effects before capture. Do not interpret `TAKE` as proof of bounded provider work. Unsupported complex types can prevent retention even if SQL execution succeeds. A failed attempt is evidence about that attempt, not a full result table.

## Pin and query retained rows

```powershell
$opened = musoq investigation observation open $folder --id $investigationId --observation-id $captured.observationId --version $captured.version | ConvertFrom-Json
$pin = @{alias='amount';observationId=$captured.observationId;version=$captured.version;
 captureId=$captured.captureId;artifactSha256=$opened.artifactSha256}
$savedQuery = @{folder=$folder;investigationId=$investigationId;
 query="select e.c0 * 2 as Amount from evidence.rows('amount') e";bindings=@($pin)}
$requestPath = Join-Path $artifactRoot 'saved-query.json'
$savedQuery | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $requestPath -Encoding utf8
musoq investigation evidence query --request-file $requestPath --format jsonl
```

Preserve the JSONL stream and verify process success and its final completion outcome, not merely the presence of row frames. Here the exact row value should be `246.9000`. Saved queries read only explicitly bound observations; ordinary source providers and ambient clock/random/UUID functions are unavailable.

`rows` exposes `c0`, `c1`, etc., and zero-based `__captured_row`, preserving duplicate/unnamed original columns. Inspect original names/types through observation metadata. For heterogeneous values, use `evidence.cells('amount')`: `CapturedRow`, `ColumnOrdinal`, `Kind`, `ClrType`, `NullableValueType`, `ValueText`, and `ExactJson` expose the retained representation without coercion.

To retain the calculation, read current state and derive explicitly:

```powershell
$state = musoq investigation open $folder | ConvertFrom-Json
$derive = @{evidence=$savedQuery;expectedRevision=$state.revision;
 operationId=[Guid]::NewGuid().ToString();title='Doubled saved amount'}
$derivePath = Join-Path $artifactRoot 'derive.json'
$derive | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $derivePath -Encoding utf8
musoq investigation observation derive --request-file $derivePath
```

Check the same execution/retention conditions as capture. Retry with the unchanged saved request; a successful derivation retains exact parent pins and lineage without a new original-source read. Replacement or applicability changes can mark dependent derived observations and assessments for review; never clear those warnings merely because the old calculation remains readable.

## Claims and assessments

Observations are results; claims and assessments are attributed interpretations. A new claim request has:

```powershell
$state = musoq investigation open $folder | ConvertFrom-Json
$claimId = [Guid]::NewGuid().ToString()
$claim = @{folder=$folder;investigationId=$investigationId;expectedRevision=$state.revision;
 operationId=[Guid]::NewGuid().ToString();claimId=$claimId;expectedVersion=$null;
 title='The selected amount is retained';scope='One synthetic captured row';
 markdown='The capture retained the selected decimal amount.';author=$author;authorRole='agent'}
```

Write the request as UTF-8 JSON and invoke `musoq investigation claim write --request-file <path>`. Read the returned/current workspace revision before assessing. Response item metadata uses `id`; do not assume it contains `claimId` or `assessmentId`.

```powershell
$state = musoq investigation open $folder | ConvertFrom-Json
$assessment = @{folder=$folder;investigationId=$investigationId;expectedRevision=$state.revision;
 operationId=[Guid]::NewGuid().ToString();assessmentId=[Guid]::NewGuid().ToString();expectedVersion=$null;
 claimId=$claimId;claimVersion=1;title='Selected capture supports the scoped claim';
 disposition='supported';confidence='high';limitations='One synthetic row; no external source coverage established.';
 markdown='The pinned full observation supplies the selected result.';author=$author;authorRole='agent';
 evidence=@(@{observationId=$captured.observationId;version=$captured.version;captureId=$captured.captureId;
 artifactSha256=$opened.artifactSha256;relation='supports';firstCapturedRow=0;capturedRowCount=1})}
```

Serialize and invoke `musoq investigation assess --request-file <path>`. Dispositions are supported, contradicted, inconclusive, and rejected; confidence is unrated, low, medium, or high. Supported assessments need supporting links. Evidence relationships are supports, contradicts, or context. Row ranges refer to original captured order, not a sorted display.

For replacement, use the current positive authored version instead of null, a new operation ID and current workspace revision. Preserve earlier versions and counterevidence. Replacing a claim flags dependent assessments for review; re-assess intentionally against the chosen version rather than rewriting history.

## Qualification boundaries

Retain code coordinates plus relevant bodies and assertions for repository analysis. `search.lines` can include line terminators; normalize framing only for comparisons with APIs that remove terminators, and preserve original evidence. Lexical hit counts do not establish semantic behavior or complete coverage.

Preserve actual test output and artifacts when tests run; label any CSV/JSON projection with its transformation and source checksum. Focused test passes are not full-suite, release, arbitrary-provider, performance, or concurrency qualification. Source capture fingerprints identify inputs, not a cryptographic proof of source authenticity. Source coverage and applicability need separate evidence and scope.
