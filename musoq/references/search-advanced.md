# Byte signatures and multiline records

Use these sources only when text-line search does not express the question.

| Need | Recipe | Edit | Meaning and limits |
|---|---|---|---|
| Find a raw signature | [bytes](../recipes/search-bytes.sql) | root, patternHex, scope | Original-byte offset/length; independent of text encoding |
| Search across a delimited record | [multiline](../recipes/search-multiline.sql) | regex, delimiters, maxBytes, scope | Matches within explicitly bounded records |

For masks or neighboring byte windows, inspect `musoq describe arguments search.bytes --filter window` and `--filter maskHex`, then describe the concrete source before projecting unfamiliar columns. Byte offsets are not UTF-16 columns. Keep Path and offsets beside any interpreted fields; use [binary interpretation](interpret.md) for a typed layout.

For multiline matching, `text.mode` controls regex while `records.mode` controls framing. The recipe uses `bounded-multiline`, explicit delimiters, a 4096-byte cap and `allowUnterminatedEof: false`. Framing delimiters are excluded from the searchable record body; the recipe searches its interior. Do not replace framing with an unbounded whole-file regex. Test oversized and unterminated records, boundary-crossing matches and malformed encoding before claiming coverage.

Provider constructor shapes are available through `describe arguments`; accepted enum values and behavior require provider diagnostics/help or version-matched contract documentation. Language and interpretation specifications explain SQL composition, not every Search provider option. Check checkout examples against the installed provider before adopting them.
