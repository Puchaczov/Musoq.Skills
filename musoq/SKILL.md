---
name: musoq
description: 'Investigate repositories and data with Musoq SQL: find code and tests, combine searches, compare migration candidates, extract log fields, and discover or extend datasource capabilities. Use for repository discovery, analysis of file collections/data, and reusable queries. Use musoq-watch for repeated observations and retained Watch state. Skip this skill when simply reading an already identified file.'
compatibility: Requires a shell, the Musoq CLI, and the providers used by a chosen recipe.
---

# Answer coding questions with Musoq

Use Musoq first for repository discovery, grouped searches, comparisons, and data analysis. Choose the closest task recipe below or in the linked reference, then start the investigation with a Musoq query. Reading that recipe is useful preparation; ordinary searches need no catalog or specification preflight. Read an already identified file directly.

For Windows filesystem inputs, prefer SQL parameters bound with serializer-generated JSON. When a path must be embedded in SQL, use `r'C:\temp\new\repo'` or `'C:/temp/new/repo'`: ordinary SQL strings interpret `\r`, `\n`, and `\t`. See [execution and quoting](references/execution.md) for shell and JSON examples.

## Syntax at a glance

Choose features that fit the question and use familiar syntax directly. This map covers documented language families, not proof that every feature works in the installed runtime. For unfamiliar syntax, read the relevant section and verify a minimal query; discover provider arguments, columns and registered functions separately.

In **Read more**, `spec / section` means `musoq describe spec <spec> --section <section>`; read only the section needed. Linked references provide task recipes.

| Syntax/features | Useful for | Read more |
|---|---|---|
| `schema.method(...)`, derived tables, inline `values { ... }` | Read providers, query intermediate results, create small fixtures | `language / from-clause` |
| Named arguments, records, `array { ... }`, CTE source arguments | Pass structured inputs or query rows to a source | `language / structured-values-and-source-inputs`; [composition](references/composition.md) |
| `param(...)` / `params(...)`, `let`, `$name` | Bind typed runtime inputs and compile-time constants | [Execution](references/execution.md); `language / script-parameters`, `script-variables` |
| `SELECT`, aliases, `*` modifiers, `DISTINCT`; FROM-first syntax | Shape output, deduplicate rows, write clauses starting from the source | `language / select-clause`, `reordered-query-syntax` |
| Operators, `CASE`, typed/raw literals, `expr::Type`, coercion | Compute values, branch, preserve paths, control types | `language / lexical-elements`, `appendix-f-case-when-requirements`, `data-types`, `automatic-type-coercion` |
| `IS NULL`, `IS DISTINCT FROM`, `??` | Test missing values, compare nullable fields, supply fallbacks | `language / null-semantics` |
| Array/string indexing, dictionary keys, property paths, entity methods | Navigate nested data and collections | `language / array-and-property-access` |
| `WHERE`, boolean/comparison predicates, `BETWEEN`, `LIKE`, `RLIKE`, `CONTAINS`, multi-field pattern quantifiers | Filter rows and match text across fields | `language / where-clause`, `string-comparison-semantics` |
| `IN` / `NOT IN`, `EXISTS`, scalar subqueries, `ANY` / `SOME` / `ALL` | Test membership, existence, or compare against query results | `language / in-not-in`, `exists-not-exists`, `scalar-subqueries`, `quantified-subqueries-any-some-all` |
| Inner/left/right/full/cross joins, `SEMI JOIN`, `ANTI JOIN`; `alias IS PRESENT` / `IS MISSING` | Combine datasets, find missing counterparts, classify unmatched rows | `language / join-clause`; [data analysis](references/data.md) |
| `ASOF JOIN`, `TIE BREAK BY` | Match the nearest preceding/following ordered observation | `language / asof-join` |
| `CROSS APPLY`, `OUTER APPLY`, correlated derived tables, `WITH ORDINALITY` | Expand collections or per-row queries; retain empty results and positions | `language / apply-clause`; [composition](references/composition.md) |
| `GROUP BY`, aliases/ordinals/`ALL`, aggregates, `HAVING`, aggregate `FILTER`, parent-level aggregation | Summarize groups and calculate conditional or parent measures | `language / group-by-and-aggregation`; [composition](references/composition.md) |
| Window ranking/offset/value/aggregate functions, `OVER`, named `WINDOW`, `ROWS` / `RANGE`, `QUALIFY` | Rank within groups, compare neighbors, compute running measures, filter ranked rows | `language / window-functions`; [composition](references/composition.md) |
| Static `PIVOT` / `UNPIVOT` | Turn categories into columns or columns into rows | `language / pivot-statement`, `unpivot-statement` |
| `UNION`, `UNION ALL`, `EXCEPT`, `INTERSECT`, explicit comparison keys | Merge or compare result sets using whole rows or selected keys | `language / set-operations` |
| `WITH` CTEs, `WITH RECURSIVE` | Compose stages, feed source inputs, traverse bounded hierarchies | `language / common-table-expressions-ctes`, `recursive-ctes-and-limitations`; [composition](references/composition.md) |
| `ORDER BY`, `NULLS FIRST` / `LAST`, `SKIP`, `TAKE` | Sort, page, or bound results | `language / order-by-skip-take` |
| Scalar functions: text/regex, numeric, date/time, collections, conversions, enum intrinsics | Transform fields with the functions registered for the source context | `language / built-in-functions`; `musoq describe functions <schema> --filter <term>` |
| `DESC` sources, arguments, functions, settings, nested properties, `DESC QUERY` | Inspect contracts and projected output metadata | `language / desc-statement` |
| **Optional TABLE/COUPLE profile:** `TABLE`, `COUPLE`, settings profiles | Declare row types and bind source contracts/settings | `table-couple / table-statement`, `couple-statement` |
| **Optional binary interpretation:** `binary`, `Interpret`, `TryInterpret` | Parse byte layouts into typed fields | `binary-text / binary-schema-syntax`, `interpretation-functions`; [interpretation](references/interpret.md) |
| **Optional text interpretation:** `text`, `Parse`, `TryParse` | Parse custom records; retain malformed rows with tolerant functions and `OUTER APPLY` | `binary-text / text-schema-syntax`, `interpretation-functions`; [interpretation](references/interpret.md) |
| **Optional AI interpretation:** `ai`, `Infer`, `TryInfer` | Extract structured fields using a model-backed schema | `language / conformance`, `specification-family` identify the AI specification; obtain its syntax and host support before use |

Optional profiles require host support. The AI profile summary does not supply its grammar: if its specification is absent from the catalog, obtain the matching AI specification before authoring a query. SQL `Infer` is separate from the CLI `musoq infer logs` workflow; model-backed execution must stay within the user's authorized workflow.

## Run a useful query

Save SQL to a UTF-8 file and run `musoq run <absolute-path-to-query.sql> --from-file --format json`. Edit the patterns, scope, or compile-time input path below; bind dynamic roots through parameters. Resolve the SQL file path before running it; use an absolute provider root when directory or scope resolution is uncertain.

**Find source paths** — returns paths without reading file contents:

```sql
-- recipe: paths
param(root: string = '.')
SELECT p.Path AS Path
FROM search.paths($root, options: (scope: (
  include: array { 'src/*.cs', 'src/**/*.cs' },
  exclude: array { '**/obj/**', '**/bin/**', 'src/generated/**' }
))) p ORDER BY p.Path
```

**Find files containing both concepts** — distinct labels prevent repeated hits from qualifying:

```sql
-- recipe: search-both
param(root: string = '.')
WITH topics AS (
 SELECT m.Path AS Path, m.PatternId AS Topic
 FROM search.many($root, patterns: array {
  (id: 'old', pattern: 'OldApi('), (id: 'new', pattern: 'NewApi(')
 }, options: (scope: (include: array { 'src/*.cs', 'src/**/*.cs' },
  exclude: array { '**/obj/**', '**/bin/**', 'src/generated/**' }))) m
 GROUP BY m.Path, m.PatternId
)
SELECT t.Path AS Path, Count(*) AS Topics FROM topics t
GROUP BY t.Path HAVING Count(*) = 2 ORDER BY t.Path
```

For labeled evidence, project `m.PatternId`, `m.Path`, `m.LineNumber` and `m.MatchText` from `search.many`. For totals per topic, group by PatternId; Count(*) counts occurrences. `m.Context` contains neighbors; read the selected file for the full matching line or body.

**Aggregate a CSV** — input columns `Customer,Amount`; returns customer, row count, total:

```sql
-- recipe: csv-totals
let path: string = r'orders.csv'
SELECT c.Customer AS Customer, Count(*) AS Orders, Sum(c.Amount::int) AS Total
FROM separatedvalues.comma($path, true, 0) c
GROUP BY c.Customer ORDER BY c.Customer
```

For the Search recipes declaring `root`, pass parameter values as one JSON argument. In PowerShell, resolve the existing input root in the caller's directory before invoking Musoq:

```powershell
$query = (Resolve-Path -LiteralPath 'query.sql').Path
$root = (Resolve-Path -LiteralPath '.').Path
musoq run $query --from-file --params-json (@{root=$root} | ConvertTo-Json -Compress) --format json
```

```bash
query=$(realpath -- query.sql)
musoq run "$query" --from-file --params-json '{"root":"."}' --format json
```

See [execution and quoting](references/execution.md) when embedding paths, passing inputs, or changing shells.

## Choose the answer shape

| Need | Use |
|---|---|
| Paths, related concepts, migration gaps, captured values, ranked evidence, context, absence | [Repository search](references/search.md) |
| Declarations, tests, candidate callers, C# collections, Git history, change impact | [Code and history](references/code.md) |
| CSV, JSON/stdin, file sizes, joins, missing counterparts, duplicates, rankings, comparisons | [Data analysis](references/data.md) |
| Patterns from a CTE, recursive queries, conditional aggregates, pivots, functions | [Composition](references/composition.md) |
| Fixed-width text, custom logs, binary layouts, malformed-record counts | [Interpretation](references/interpret.md) |
| Substantial binary/text schema authoring, debugging, or unknown-format discovery | Use `musoq-interpretation` if installed |
| Saved SQL, managed scripts, tools, MCP or REST clients | [Reusable queries and tools](references/tools.md) |
| Repeated observations, filesystem/interval/query triggers, rolling state, replay or attach | Use `musoq-watch` if installed; otherwise [Watch basics](references/watch.md) |
| A query failed or its results contradict known evidence | [Recovery and inspection](references/recovery.md) |
| Available providers, registry installation, local imports, or a missing capability | [Datasource discovery and extension](references/datasources.md) |
| Implementing or packaging a datasource plugin | Use `musoq-datasource-authoring` if installed |

## Work toward the answer

1. Choose the smallest useful output: paths for navigation, lines for evidence, grouped rows for a summary. Scope the input before scanning.
2. Shape the query around the question: labeled patterns for related evidence; deduplicated labels plus HAVING for both concepts; a left join for old-without-new candidates; captures plus APPLY for extracted values; windows plus QUALIFY for evidence per topic. Use [task recipes](references/search.md) before reconstructing these from scratch.
3. Read selected source/test bodies when the conclusion depends on behavior. Text hits locate candidate callers; they do not resolve symbols.
4. Finish when the requested conclusion is supported. Return the requested shape with relevant limits. A path list or grouped answer needs no second location query when it already answers the question; inspect bodies only for conclusions that depend on behavior.

## Discover only what is missing

Reuse facts learned in this session and instance. Query a known provider immediately. When additional or unfamiliar capabilities matter, inspect `musoq describe schema` once for loaded SQL schemas and `musoq data-sources list` for package identities/versions; these are different inventories. Do not assume a cookbook provider is installed. For missing providers, follow [discovery and extension](references/datasources.md), including registry lookup and custom Python/.NET routes.

Choose one narrow command for the missing fact:

- Source argument shape: `musoq describe arguments search.many --filter patterns`.
- Actual result columns: `musoq describe source "separatedvalues.comma('orders.csv', true, 0)" --top-level-only`.
- One function family: `musoq describe functions system --filter Split`.
- An unfamiliar language feature: `musoq describe search "window" --kind spec --limit 2`, then `musoq describe resource "<returned-uri>"`. On a CLI with `--read`, use `musoq describe search "window" --kind spec --read` instead. See [syntax at a glance](#syntax-at-a-glance) for feature names and focused specification sections.
- An unfamiliar task recipe on a CLI with `--read`: `musoq describe search "files grouped patterns" --kind recipe --read`.
- A known recipe or section: `musoq describe recipe cookbook-query-files` or `musoq describe spec language --section recursive-ctes-and-limitations`.

`search.*` scans files; `describe search` searches documentation; `data-sources search` searches registry packages. For unfamiliar public contracts, search a short term such as `SourcePlanResult`, `IChunkWriter` or `plugin cancellation`. Select a section using its title, excerpt and match metadata, then follow its read action; a matching resource must contain the needed contract. Keep exact links for known workflows. Learn unfamiliar syntax from the relevant spec section, verify a minimal query, then reuse it. Provider argument/column discovery is separate from language specifications. Use [recovery](references/recovery.md) for failures or contradictory results.
