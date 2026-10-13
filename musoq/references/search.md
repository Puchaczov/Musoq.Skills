# Answer investigation questions with Search

Choose the answer, edit the linked SQL's root/scope/patterns, and run it. Known recipes need no catalog preflight. Use absolute roots when resolution is uncertain.

| Question | Executable SQL | Edit | Output meaning |
|---|---|---|---|
| Which paths should I open? | [paths](../recipes/paths.sql) | root, include/exclude | Eligible paths without content search |
| Which files contain a literal? | [files](../recipes/files.sql) | literal, scope | Distinct matching paths |
| Where are matching lines? | [lines](../recipes/lines.sql) | literal, scope | Path, line number, full line text |
| Where are declarations, calls, tests and configuration candidates? | [coverage](../recipes/search-coverage.sql) | labels, literals, source/test/config scope | Occurrences per topic/path |
| Which files contain both concepts? | [both](../recipes/search-both.sql) | two labels/literals, scope | Paths with two distinct topic labels |
| Where is an old API present without its replacement? | [migration](../recipes/search-migration.sql) | old/new literals, scope | Candidate paths, including comments/strings |
| What values occur in matching records? | [captures](../recipes/search-captures.sql) | regex/group name, scope | Counts per named capture value |
| What are the first two locations per topic? | [ranked evidence](../recipes/search-ranked.sql) | root parameter, labels, order, cap | Deterministic locations and match text per topic |
| Which occurrences are nearby in the same file? | [proximity](../recipes/search-proximity.sql) | literals, line/gap window, small scope | Same-file bounded candidate pairs |
| Which same-file pairs fall outside that relationship? | [outside proximity](../recipes/search-proximity-outside.sql) | literals, permitted bounds, small scope | Pairs rejected by NOT; preview rather than absence proof |
| What do matching log lines mean? | [search then parse](../recipes/search-logs.sql) | prefilter, text schema, scope | Parsed fields and raw malformed candidates |
| How many matches, including zero per file? | [counts](../recipes/counts.sql) | literal, scope | Per-file occurrence totals |
| What surrounds a match? | [context](../recipes/context.sql) | path, literal, before/after | Neighbor lines; matching line is separate |
| Do hidden workflows run tests? | [hidden](../recipes/hidden.sql) | workflow glob, literal | Matching paths with hidden traversal enabled |
| Is a pattern absent from this exact scope? | [absence](../recipes/absence.sql) | literal, complete scope | Resolution, exhaustion, exactness, failures, hits |
| Is it absent across the whole root, including hidden/ignored entries? | [whole-root audit](../recipes/search-audit-all.sql) | root, needle as JSON | Complete audit fields with both exclusions explicitly disabled |
| Which nonempty C# paths qualify before scanning? | [metadata](../recipes/search-metadata.sql) | extension, size, globs | Eligible path manifest |
| How do I pass Unicode, quotes or dollar signs? | [literal parameter](../recipes/literal-parameter.sql) | root/needle as JSON | Matching coordinates with values bound as data |

## Choose a source and preserve evidence

`paths` traverses names; `files` emits matching files; `lines` emits physical lines with `LineText`; `matches` emits occurrences, coordinates, captures and optional context; `counts` reports per-file counts; `many` emits labeled occurrences. [many](../recipes/many.sql) counts occurrences per label. For unique files, first group by PatternId and Path, then count those rows. Repeating one pattern twice in a file cannot satisfy a two-topic question.

Keep Path and LineNumber beside derived values when reporting evidence. `MatchText` is the matched substring, not the complete line. `Context` excludes the matching line; CROSS APPLY over empty context drops the match. Read an identified file directly for method/test bodies. Text co-occurrence, regex extraction and proximity identify lexical candidates; inspect signatures, helpers and assertions before making semantic claims.

Coordinate ranking and pair classification are lexical answers. When the query supplies the requested coordinates and coverage without a diagnostic or contradiction, finish with those rows; another path query, full-file read or independent scan to recompute the same coordinates adds no behavioral evidence. Inspect bodies when interpreting behavior, and use [recovery](recovery.md) when results conflict with known evidence.

## Scope before scanning

Include direct and nested globs when both are intended (`src/*.cs`, `src/**/*.cs`). Exclude build/generated content when irrelevant. Repository ignores default to `respect`; set `repositoryIgnores: 'disabled'` when the claim explicitly includes ignored entries. Global ignores default to `disabled`; hidden entries and following links default to false. Set `hiddenEntries: true` for dot-directories. State these deliberate scope choices. A traversal is not proof of Git tracking.

Metadata filters constrain names, extensions, sizes and modification times before content reads. The [metadata recipe](../recipes/search-metadata.sql) shows extension and minimum size; discover more fields with `musoq describe arguments search.paths --filter metadata`. Preserve the scope in your explanation when exclusions affect coverage.

## Literal, regex and bounded work

Use literals for identifiers and exact tokens. For regex alternatives, use [regex](../recipes/regex.sql) with `text: (mode: 'regex')` and explicit physical-line framing. `search.many` selects mode per pattern: `(id: 'code', pattern: 'MQ[0-9]+', mode: 'regex')`; its argument shape differs from single-pattern sources. Case/whole-word/encoding options belong to `text`; inspect accepted values when changing defaults. Encoding `auto` does not authorize ignoring decoding failures.

Named captures become typed rows through `CROSS APPLY m.Captures c`; filter GroupName and Success. Repeated capture groups may produce multiple rows: decide whether the question counts captures, occurrences or lines. Avoid regexes that merely extract incidental text.

`TAKE` and `QUALIFY` bound returned evidence, not necessarily scans, sorts, grouping or joins. A CTE does not promise materialization; repeated references can rescan. The proximity recipe joins two scoped sources and combines line/column bounds. Dense joins can still produce many pairs: narrow input first, bound line/gap distance, and rank for nearest-evidence questions. One command or fewer source references is not proof of fewer scans.

The outside-proximity recipe negates the permitted relationship over same-file pairs with non-null coordinates. It preserves duplicate occurrences and rejects preceding, distant or incorrectly ordered matches. Pair filtering does not establish control flow or prove that a file lacks a pattern. For nullable fields in another provider, account for SQL null semantics before treating NOT as a complement.

Scan `limits` constrain files, bytes, records, matches and in-flight/context output according to the source contract. `search.paths` has its own `maxFiles` option. Discover fields with `musoq describe arguments search.many --filter limits`; a limit or source failure invalidates completeness claims. Output caps are for previews, not absence proofs.

## Absence and recovery

Require ScopeResolved, ScopeExhausted and CountsExact true, FilesFailed zero and Occurrences zero from `audit` before claiming absence. Audit the same pattern, text mode and scope as the claim. An empty preview, missing grouped label or old-without-new report is not a complete negative proof. Audit is a new scan, not certification of an earlier one.

Candidate reports need no audit unless a complete absence claim is requested. Read selected files in full when classifying comments or executable code; those direct reads can answer their local content questions. Do not add a global negative scan to a request for lexical candidates.

Use one `param(...)` block for all runtime values, as in the whole-root recipe. For a hidden workflow audit, retain `hiddenEntries: true` and add `include: array { '.github/workflows/*.yml' }` to its scope; remove that include only when auditing the whole root. A zero-hit exact audit supports absence; a positive hit disproves it without requiring another evidence query unless locations are requested.

For read/encoding/record failures, follow [recovery](recovery.md): correct one evidenced cause, retry narrowly, and fall back after two informed corrections without progress. Retain any lost completeness.

Read [advanced Search](search-advanced.md) only for byte signatures, bounded multiline records and their specific pitfalls.
