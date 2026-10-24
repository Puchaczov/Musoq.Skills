# Text records and variants

Start from [text variants](../recipes/text-variants.sql) or [tolerant text](../recipes/tolerant-text.sql); see [validation](validation.md) for exact answers. Read `musoq describe spec binary-text --section text-schema-syntax` for unfamiliar syntax.

## Frame before matching

Establish whether the source emits whole files, physical lines, multiline records or already-framed strings. Check newline conventions, blank records, Unicode, leading/trailing spaces and delimiter escaping. A parser for one line does not by itself recover multiline events. Preserve record identity and framing decisions before filtering inputs.

Choose the narrowest evidenced structure:

| Structure | Schema approach |
| --- | --- |
| Exact marker or punctuation | `literal` |
| Unescaped separators | `until` or `between` |
| Stable widths | Fixed-width fields; confirm whether source decoding has already happened |
| Space-separated atoms and remainder | `token`, `whitespace`, `rest` |
| Lexical constraints | A bounded `pattern` supported by the current grammar |
| Genuine optional segments or record families | Optional fields or alternatives after checking the exact grammar |

`until` consumes its delimiter; do not add a second literal for the same separator. `rest` accepts everything remaining, so it cannot validate a presumed suffix. Do not silently trim or normalize data merely to make a schema pass. Preserve raw text alongside parsed fields when interpretation is uncertain.

Use samples of every observed family, including missing fields, embedded delimiters, empty values and malformed records. Do not infer a field is optional simply because one line was truncated. For repetition, check progress, termination and limits; a malformed element must not be reported as a successfully parsed prefix. If quotation/escaping is ordinary CSV or input is standard JSON, use the existing datasource rather than building an imitation parser.

## Infer logs as a draft

Inspect `musoq infer logs --help` only for needed options. Bound sampling with `--sample-lines`; use `--no-llm --no-pager` for deterministic local inference. Save a generated query to a new path with `--save-script` when useful. Do not use `--run` merely to preview inference when the substantive execution should be captured as investigation evidence.

Review the draft against multiple line families and held-out inputs. Report sample selection and counts. An inferred query is a proposal, not an independently established layout. Model-backed `--llm` may send samples externally; use it only when authorized, and do not treat redaction as proof that sharing is permitted.

## Keep failures countable

Use strict `Parse` to diagnose a specific record. Use `OUTER APPLY TryParse` for batch acceptance/rejection accounting; `CROSS APPLY` removes failures. Select a required non-null field as the success marker only when the schema guarantees it. If every field may legitimately be null, obtain an explicit success indicator with a verified partial-result form instead of guessing from nullable values. Preserve IDs and report accepted/rejected counts over the original framed input population.
