# Binary layouts and mixed payloads

Read the relevant binary-schema section through `describe spec binary-text` before using unfamiliar constructs. Start from [nested records](../recipes/binary-records.sql) for a length-prefixed container or [mixed payload](../recipes/mixed-payload.sql) for text inside bytes. Fixture answers are in [validation](validation.md).

## Separate the layout decisions

- Establish the input origin and active boundary: whole file, framed record, or bounded payload. A signature hit is a candidate start, not proof of framing. Use `search.bytes` for original-byte signature offsets when that provider is available; inspect its actual arguments before adapting it.
- Specify signedness and byte order for numeric fields; multibyte primitives need `le` or `be`. Compare a nonsymmetric value under both interpretations. A plausible timestamp or small integer alone is weak evidence.
- String widths count bytes, including UTF-8 and UTF-16 input. Specify encoding. Distinguish fixed padding, terminator handling and decoded-character trimming; `nullterm` still consumes the declared byte range. Preserve original bytes for decoding failures.
- Lengths may count bytes, records or code units and may include their own header. Write down which interpretation is being tested. Check bounds, zero length, changing lengths and following fields. Correlation between a length and file size is not sufficient to establish its meaning.

## Compose without losing cursor meaning

Use preceding fields for dynamic sizes and guards. A false/unknown conditional guard yields null and consumes no input; dependent sizes and computed expressions must handle absence. Declare nested schemas first and expand arrays with APPLY, checking that the resulting row count matches the container count. Test an empty array separately.

Ordinary nesting shares its input origin. `at` positions relative to that origin and may move backward. Use `substream[Length] as Body` when a nested payload must not read into following parent fields: exact mode is the default; `lax` explicitly permits skipped remainder. Preserve unknown bytes with a raw range instead of switching to lax merely to suppress a mismatch. Substreams establish a local origin, and nested failures are rebased to the parent input.

Query-level `InterpretAt` changes the starting cursor, not the coordinate origin. Its offset must meet the installed binding contract; do not assume a nullable or 64-bit expression is accepted without conversion and a deliberate null policy.

For bit fields, confirm packing, bit order and alignment with a byte whose bits differ. Musoq's specified first consumed bit is the least significant result bit. Byte reads after partial bit fields align; check bit metadata rather than rounding a cursor by guesswork. Tagged payloads, repeat conditions, parent-field references and validations need their specific specification sections and a small executed probe.

## Mix binary and text deliberately

Use a length-delimited string with an explicit encoding and `as TextSchema` when the binary field contains structured text. The [mixed fixture](../recipes/mixed-payload.sql) consumes five ASCII bytes as `k=oak`, then reads a separate trailer. Check both the inner fields and trailer: this detects a wrong payload length that might otherwise look successful.

If payload kind determines whether bytes contain text or another binary record, preserve the raw payload and apply the appropriate parser using the observed tag. Decoding arbitrary bytes as text first can destroy the evidence needed for binary interpretation. Compression and encryption are separate transformations; do not invent native schema support for them. Record any authorized transformation and retain its relationship to the original bytes.
