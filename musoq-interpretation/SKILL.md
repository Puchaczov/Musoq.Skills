---
name: musoq-interpretation
description: 'Author, debug, and reverse engineer Musoq binary/text interpretation schemas from layouts or samples, including mixed payloads and unknown formats. Use for substantial parsing-schema work and validation; ordinary data queries belong to musoq, datasource plugins to musoq-datasource-authoring, and language or engine changes require their own task.'
---

# Turn bytes and text into verified queryable records

Requires a shell and a compatible Musoq CLI. Reverse engineering normally also uses the investigations extension and the `musoq-investigation` skill. Keep small schema edits lightweight; do not create an investigation merely to change a known field width.

## Choose the entry point

| Request | Start here |
| --- | --- |
| Implement a supplied layout | [Binary and mixed payloads](references/binary.md) or [text](references/text.md) |
| Discover an unknown format | [Reverse engineering](references/reverse-engineering.md), then the relevant schema guide |
| Explain a failing or incorrect schema | [Validation and diagnostics](references/validation.md) |

Establish the input identity, requested fields, record framing, encoding, expected output, and selected runtime from the task and available samples. Ask only for missing facts that affect the result. Preserve original inputs; put generated SQL, fixtures and evidence outside scanned inputs. Respect restrictions on copying, extraction, external requests and writes.

## Read the contract you need

Use `musoq describe spec binary-text --section binary-schema-syntax`, `--section text-schema-syntax`, or `--section interpretation-functions` for the relevant grammar. Use `musoq describe search "substream" --kind spec --limit 2` and read the returned resource for a narrower topic. Discover provider arguments and result columns separately through `describe arguments` and `describe source`.

Installed documentation describes the selected installation; a supplied source specification defines the requested contract. If they differ, record both identities and verify the smallest disputed behavior. Do not silently substitute one for the other. Repository tests show harness mechanics and observed behavior, not an independent correctness oracle. Do not assume that every documented construct works in every runtime.

## Build and check incrementally

1. Record the layout or hypothesis and independent expected values before parsing. Establish one record boundary before interpreting a whole corpus.
2. Implement the smallest useful schema, declaring referenced schemas before use. Interpretation functions bind on the right of APPLY, not as scalar SELECT expressions.
3. Check values, types, row counts and consumed positions against an independent calculation, format description or decoder. Successful parsing alone does not confirm a layout.
4. Add variable lengths, nested records and alternatives only as supported by evidence. Test malformed/truncated inputs and preserve rejected-row counts when using tolerant parsing.
5. Check held-out samples when available. Report tested coverage, unknown ranges, layout assumptions and runtime limitations.

For unknown formats, use `musoq-investigation` for capture, pinned evidence, claims and continuation; [reverse engineering](references/reverse-engineering.md) supplies the domain-specific workflow. Reuse a supplied workspace. If durable capture is unavailable, retain local SQL/results and identify the missing capability rather than calling them investigation observations.

## Reuse a runnable fixture

[Validation](references/validation.md) maps the recipes to their independently specified answers. Run a linked SQL file by absolute path with `musoq run <absolute-file.sql> --from-file --format json`. The fixture suite includes nested binary records, text variants, mixed payloads, tolerant rejection accounting, partial results, intentional strict failures and ambiguous discovery samples.

## Deliver at the requested boundary

For a completed discovery, provide reusable SQL, representative permitted fixtures, expected results, concise layout notes and the durable workspace location. Identify confirmed fields, competing/rejected hypotheses, unexplained ranges, rejected inputs and remaining questions. A partial layout can satisfy a bounded request; do not claim complete format recovery.

Use `musoq` for broader query composition and installed datasource discovery, `musoq-datasource-authoring` for requested plugin work, and `musoq-investigation` for evidence mechanics. A schema task does not authorize language changes, engine fixes, plugin installation or publication. Reduce suspected engine defects to exact SQL/input/expected-versus-actual evidence for the selected version.
