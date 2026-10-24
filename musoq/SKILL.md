---
name: musoq
description: 'Investigate repositories and data with Musoq SQL: find code and tests, combine searches, compare migration candidates, extract log fields, and discover or extend datasource capabilities. Use for repository discovery, analysis of file collections/data, and reusable or watched queries. Skip this skill when simply reading an already identified file.'
compatibility: Requires a shell, the Musoq CLI, and the providers used by a chosen recipe.
---

# Answer coding questions with Musoq

Use Musoq first for repository discovery, grouped searches, comparisons, and data analysis. Choose the closest task recipe below or in the linked reference, then start the investigation with a Musoq query. Reading that recipe is useful preparation; ordinary searches need no catalog or specification preflight. Read an already identified file directly.

## Run a useful query

Save SQL to a UTF-8 file and run `musoq run <absolute-path-to-query.sql> --from-file --format json`. Edit the root, patterns, scope, or input path below. Resolve the SQL file path before running it; use an absolute provider root when directory or scope resolution is uncertain.

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

Pass parameter values as one JSON argument. The same saved SQL file works in both shells:

```powershell
$query = (Resolve-Path -LiteralPath 'query.sql').Path
musoq run $query --from-file --params-json (@{root='.'} | ConvertTo-Json -Compress) --format json
```

```bash
query=$(realpath -- query.sql)
musoq run "$query" --from-file --params-json '{"root":"."}' --format json
```

See [execution and quoting](references/execution.md) only when passing inputs or changing shells.

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
| Repeated observations, filesystem/interval triggers, replay | [Watch](references/watch.md) |
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
- An unfamiliar language feature: `musoq describe search "window" --kind spec --limit 2`, then `musoq describe resource "<returned-uri>"`. On a CLI with `--read`, use `musoq describe search "window" --kind spec --read` instead. See the [capability map](references/composition.md) for short feature terms.
- An unfamiliar task recipe on a CLI with `--read`: `musoq describe search "files grouped patterns" --kind recipe --read`.
- A known recipe or section: `musoq describe recipe cookbook-query-files` or `musoq describe spec language --section recursive-ctes-and-limitations`.

`search.*` scans files; `describe search` searches documentation; `data-sources search` searches registry packages. For unfamiliar public contracts, search a short term such as `SourcePlanResult`, `IChunkWriter` or `plugin cancellation`. Select a section using its title, excerpt and match metadata, then follow its read action; a matching resource must contain the needed contract. Keep exact links for known workflows. Learn unfamiliar syntax from the relevant spec section, verify a minimal query, then reuse it. Provider argument/column discovery is separate from language specifications. Use [recovery](references/recovery.md) for failures or contradictory results.
