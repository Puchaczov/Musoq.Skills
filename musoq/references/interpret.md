# Parse custom text and binary records

For substantial schema design, debugging, mixed payloads or unknown-format reverse engineering, use `musoq-interpretation` when available. Keep the introductory recipes below for small known-layout queries.

Use ordinary CSV or JSON sources for structured input. Use an interpretation schema for fixed widths, custom delimiters, mixed log lines, or a known binary layout. Run a known fixture directly, then edit its schema and input:

| Need | Executable SQL | Editable inputs | Result shape |
|---|---|---|---|
| Tokenized text | [parse-text](../recipes/parse-text.sql) | schema and `INFO ready` | Level, Message |
| Binary integer | [parse-binary](../recipes/parse-binary.sql) | widths, endianness, hex bytes | typed Value |
| Account for bad rows | [tolerant-text](../recipes/tolerant-text.sql) | input rows and accepted prefix | Id, nullable Message |

Resolve each recipe link relative to this reference and run its absolute path with `musoq run <absolute-path.sql> --from-file --format json`. Project skill folders such as `.agents/skills` may be hidden from ordinary file listings; use the linked path directly. Expected fixture values are checks, so report rows actually observed when asked to execute a query. Declarations precede use; Parse/Interpret bind through APPLY. The binary fixture supplies a byte-array CTE column to Interpret.

Choose **strict** Parse/Interpret when malformed input should fail. Choose TryParse/TryInterpret with **OUTER APPLY** when rejected records must remain countable; CROSS APPLY drops null parse results. Retain the original input identity and count accepted and rejected rows separately. Test one known valid record and one malformed or truncated record before widening input. Preserve original bytes when offsets matter, and keep framing, encoding, widths, and endianness as separate choices. A magic value alone does not establish a binary format.

For unfamiliar grammar, read only the relevant section: `musoq describe spec binary-text --section text-schema-syntax`, `--section binary-schema-syntax`, or `--section interpretation-functions`. TABLE/COUPLE declares row contracts and does not itself parse bytes. For `until`, check delimiter consumption before placing a literal delimiter after it.

For irregular logs, start with deterministic `musoq infer logs`; read its help only for unknown input or sample flags, bound the sample, and review the inferred draft against more than one line type. Model-backed inference may send data externally, so use it only within the user's authorized workflow. Group, join, or rank parsed fields in the same SQL investigation. Report the scope, layout assumptions, and rejected count.
