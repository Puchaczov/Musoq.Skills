---
name: musoq-investigation
description: 'Create, continue, and report durable Musoq investigations with retained query evidence, scoped claims, assessments, and pinned history. Use when the user wants an investigation workspace, saved evidence, continuation across sessions, or an evidence-backed investigation report. Ordinary one-off SQL searches and generic debugging without durable evidence belong to the musoq skill.'
---

# Keep an investigation that another session can continue

Requires the Musoq CLI with the investigations extension and workspace filesystem access. Examples use PowerShell; discover installed MCP or REST contracts when those transports are requested.

Use Musoq's investigation workspace as the record of observations and attributed interpretations. Follow the requested scope: a saved observation, continuation, or report need not become a complete new investigation. Do not create a workspace merely because a request contains the word "investigate".

## Start with the question and existing state

- Establish the question, scope, and requested deliverable from the conversation. Record an independent expected-result oracle before a behavioral probe when one is available.
- Open a supplied workspace before changing it. Otherwise choose a durable folder outside scanned or watched inputs; never overwrite an investigation. Keep query/request artifacts beside the workspace when useful, rather than adding them to the investigated repository.
- For repository conclusions, record HEAD and relevant worktree state. Distinguish inspected source, installed-runtime behavior, and source-built tests; a passing installed query does not qualify another checkout.
- Check `musoq investigation capabilities` once for the current installation. It already emits JSON. For an unfamiliar operation, use `musoq describe command investigation <path>` or native help; do not invent flags or request fields.

## Read only the relevant workflow

| Task | Guidance |
| --- | --- |
| Start a workspace, capture SQL, query saved rows, derive evidence, write claims or assessments | [Evidence and reasoning](references/evidence-and-reasoning.md) |
| Resume work, expand history, inspect a stopped attempt, review applicability, import evidence | [Continuation and recovery](references/continuation-and-recovery.md) |
| Compose, correct, validate, or publish an evidence-backed report | [Reports](references/reports.md) |

For a complete runnable client example, read `musoq describe manual investigations-automation`. Treat installed documentation as the version authority; this skill supplies workflow decisions rather than a copy of every contract. If using MCP or REST, discover their advertised schemas instead of mechanically translating CLI flags. REST/MCP folder addresses are absolute.

For source discovery and SQL composition, use the existing `musoq` skill when available. Run useful durable queries through `investigation capture` directly instead of first executing them with `run`: ordinary results cannot currently be promoted into retained evidence. A separate exploratory execution is a different observation, not the earlier result.

## Keep evidence and interpretation separate

- Require successful execution, completed capture, and full retention before relying on a table. Process success alone is insufficient. Metadata inspection reports `payloadIntegrity: not-checked`; query retained evidence to validate the chunks it consumes.
- A retained result establishes what that execution emitted. Source coverage and current applicability remain unknown unless independently established. A summary, imported copy, or shared execution lineage is not independent corroboration.
- Use scoped claims and assessments with explicit author/role, pinned evidence relationships, limitations, and unknowns. Preserve competing and rejected interpretations. Store concise authored justifications, not private chain-of-thought. Confidence labels are judgments, not probabilities or human approval.
- Keep complete evidence in the workspace while showing bounded summaries. Text-search matches locate candidate code; read and retain relevant implementation and assertion bodies before interpreting behavior.
- Preserve exact caller-supplied SQL separately when replay matters. Safe query displays withhold literals and parameters; request files and response logs may contain sensitive inputs even when safe displays do not.

## Mutate and retry deliberately

Read current identity and revision for a new intentional mutation. Keep workspace revision, observation version, report revision, and presentation version distinct. Capture and derivation publish reservation and completion revisions; do not calculate the next revision from memory.

After a lost response, reuse the original operation ID and identical arguments, including the original expected revision. Do not generate a new operation identity just to retry. On `INVESTIGATION_CONFLICT`, reopen, review concurrent changes, and reconcile before issuing a new mutation. If the outcome remains ambiguous, inspect it rather than repeatedly executing the source.

Preserve stdout, stderr, and exit status before parsing or rejecting a response. Nonzero validation/capture outcomes can carry useful JSON; rejected input or transport failures may have only stderr. Use UTF-8 query/request files for complex inputs and absolute filesystem paths, especially after changing PowerShell location.

Use existing authorization for source effects, cross-investigation reuse, or payload deletion. Investigation scope does not authorize fixes, releases, or external sharing. Do not add a blanket permission question to ordinary authorized work.

## Finish at the requested boundary

For a completed investigation, record an attributed outcome and explicit remaining unknowns, including an inconclusive outcome when appropriate. Do not finish work that is still ongoing solely to produce a report. Resume through `reopen` when further investigation is needed.

Reports are appropriate when requested or needed for the deliverable; they are not mandatory. Local publication creates files, not an upload. Return the result, qualification limits, workspace location, and any requested exports. Report which checks actually ran; never imply human approval or full-suite qualification from focused tests.
