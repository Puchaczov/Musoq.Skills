# Validate results and diagnose discrepancies

Record an independent expected result before running a probe. Check values, logical types/nullability where exposed, input/output row counts and cursor positions. Add zero lengths, absent branches, changed tags, malformed encodings, truncated input and boundary cases as the target layout requires. Do not make every simple edit a full conformance campaign.

## Executable fixtures and independent answers

Each recipe is self-contained and uses invented data without external providers. [Expected results](../recipes/expected.json) contain exact row objects or the expected nonzero diagnostic. The integers below follow directly from byte arithmetic; they are not copied from interpreter output.

| Recipe | Independent oracle |
| --- | --- |
| [Binary records](../recipes/binary-records.sql) | `02` records; IDs 7/9; two-byte bounded payloads; LE values `3412` = 4660 and `0201` = 258; trailer `EE` = 238 |
| [Text variants](../recipes/text-variants.sql) | `I:ready` has null Trace; `[trace-7]W:retry later` has Trace `trace-7`; kind/message split at `:` after optional trace |
| [Mixed payload](../recipes/mixed-payload.sql) | Length 5; ASCII `k=oak`; trailer `7F` = 127 |
| [Tolerant binary](../recipes/tolerant-binary.sql) | Two input IDs remain; `2A000000` = 42, one-byte input is rejected |
| [Tolerant text](../recipes/tolerant-text.sql) | Two input IDs remain; `OK:ready` succeeds, `bad` is rejected |
| [Partial binary](../recipes/partial-binary.sql) | One complete byte `07`; two-byte Value fails with only `34` remaining; terminal byte cursor 1 |
| [Partial text](../recipes/partial-text.sql) | `OK:` completes at code-unit 3; required `!` fails on `x`; terminal cursor 3 |
| [Strict binary failure](../recipes/strict-binary-failure.sql) | Reading a four-byte integer from one byte fails, ISE0001 |
| [Strict text failure](../recipes/strict-text-failure.sql) | `bad` cannot match literal `OK:`, ISE0004 |
| [Discovery samples](../recipes/discovery-samples.sql) | All candidate lengths = 2; raw byte pairs differ; constant-prefix and length hypotheses remain indistinguishable |

Use an isolated artifact directory for actual outputs, stderr, exit status, runtime identity and comparison results. Execute recipes by absolute path using `musoq run <file> --from-file --format json`. Compare named projected fields and ordered rows; intentional failures must exit nonzero and contain the specified diagnostic. Keep expected answers unchanged if the selected runtime disagrees: investigate and report the discrepancy.

## Strict, tolerant and partial are different tools

- `Interpret`/`Parse`: fail on malformed input; useful for a minimal failing record.
- `TryInterpret`/`TryParse`: return no parsed record on interpretation failure. OUTER APPLY retains rejected source rows with null parsed fields; CROSS APPLY drops them. These functions do not suppress arbitrary compilation, provider or infrastructure failures.
- `PartialInterpret`/`PartialParse`: expose `IsSuccess`, `ErrorField`, `ErrorMessage`, `ParsedFields`, `CompletedFields`, `BytesConsumed` and `BitOffset` where supported. Check the selected runtime before depending on a particular metadata field.

Only members identified by `CompletedFields` are valid partial values. Failed nested fields and arrays do not establish successful child prefixes. A resolved absent field can be completed with null. Do not infer completion from a CLR default value or a non-null object. The partial recipes project only known-completed scalar fields and metadata, avoiding complex-value retention.

Some installations bind only the original partial-result columns (`ParsedFields`, `ErrorField`, `ErrorMessage`, `BytesConsumed`) even when their documentation describes newer metadata. The recipes use those original columns and a fixture with an independently known completed prefix. If `IsSuccess`, `CompletedFields` or `BitOffset` cannot bind, record the limitation; do not treat guessed completion as general partial-result support.

`BytesConsumed` is a terminal cursor, not necessarily the number of distinct bytes read or the furthest visited position. Binary uses byte positions plus `BitOffset`; text uses UTF-16 code units despite the column's name. An `at` can move backward. Diagnostic error location can differ from the cursor. Check nested and substream origins before reporting offsets against the original file.

## Narrow the failure

Preserve exact SQL, parameters, original bytes/text, expected/actual rows, exit code, stdout/stderr, runtime identity and diagnostic IDs. First distinguish source/framing errors, schema grammar/binding errors, interpretation failures and internal engine errors. Read the specific diagnostic and specification section; correct one evidenced cause and rerun the smallest case.

Do not switch to Try-functions, lax substreams or broad optional fields merely to hide a mismatch. Reproduce suspicious engine behavior in a provider-independent literal fixture. Source-built tests qualify that checkout only; installed CLI runs qualify that installation only. Retain a minimal reproducer and any validated workaround; engine repair needs its own authorized task.

For durable discovery, retain scalar projections through capture, then query pinned evidence to verify retained values. Validate continuation by reopening/recalling the same workspace and reading its original pinned observations without executing source SQL again. Follow the investigation skill for revisions, retries and outcome recording.
