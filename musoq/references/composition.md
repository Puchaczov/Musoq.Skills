# Compose answers in SQL

| Need | Executable SQL | Editable inputs | Result |
|---|---|---|---|
| Feed patterns from a query | [cte-patterns](../recipes/cte-patterns.sql) | root and CTE Id/Pattern rows | Pattern, Hits; fixme=1, todo=2 |
| Generate bounded recursive rows | [recursive](../recipes/recursive.sql) | seed, step, terminating predicate | N = 1, 2, 3 |
| Conditional counts | [conditional](../recipes/conditional.sql) | group and FILTER condition | Component, Total, Errors |
| Static pivot | [pivot](../recipes/pivot.sql) | dimension, explicit IN values, aggregate | Component, Info, Errors |
| Expand collections | [apply-lines](../recipes/apply-lines.sql) | input and collection expression | One row per member |
| Rank groups | [rank](../recipes/rank.sql) | partition and ordered metric | Selected ranked rows |
| Search → aggregate → evidence | [composed](../recipes/composed.sql) | labels, threshold, scope | Focused source evidence |
| First locations per Search topic | [ranked evidence](../recipes/search-ranked.sql) | root parameter, labels, order, cap | Coordinates with RowNumber and QUALIFY |
| Values extracted from matching records | [captures](../recipes/search-captures.sql) | regex group, scope | Capture expansion and grouped values |

## Learn the feature needed by the question

| Need | Short catalog term | Authoritative route |
|---|---|---|
| Pass records/arrays to a source | `source arguments` | language source-arguments section; exact fields from describe arguments |
| Feed query rows into another source | `CTE` | language CTE sections and table-couple with-cte-as-argument |
| Compare sets or correlate evidence | `JOIN` | language join-clause |
| Expand captures/collections | `APPLY` | language apply-clause |
| Retain failed parses | `interpretation` | binary-text interpretation-functions (read directly for TryParse) |
| Compute conditional measures | `FILTER` | language filter-clause-on-aggregates |
| Rank/sample within topics | `window` or `QUALIFY` | language window-functions and qualify-clause |
| Follow bounded dependencies | `recursive` | language recursive-ctes-and-limitations |

Search one short term with `musoq describe search "window" --kind spec --limit 2`, then read the returned URI using `musoq describe resource "<returned-uri>"`. With `--read`, combine lookup and reading. If no match is found, simplify the term or use the named section; do not invent a feature or dump all specifications. Verify a minimal query before composing it into the task, then reuse the observed syntax.

Language specs explain SQL; installed source contracts explain provider arguments and columns. Checkout guides are supplementary, not proof of installed capabilities. Ranked Search queries accept runtime parameters: bind the recipe's root through `--params-json`, as shown in [execution](execution.md).

The CTE source argument is `patterns: patterns`, not a quoted CTE name. Discover unknown structural arguments with `musoq describe arguments search.many --filter patterns`; preserve the returned field names and types. CTEs clarify dependencies but do not promise materialization or a single scan.

Give recursion a terminating predicate. For graph traversal also handle cycles; the numeric fixture does not implement cycle detection. The smallest relevant specification can be found with:

```text
musoq describe search "recursive" --kind spec --limit 1
musoq describe spec language --section recursive-ctes-and-limitations
```

This is a two-command unknown-capability route; reuse the section after reading it. With a qualified CLI supporting it, `musoq describe search "recursive" --kind spec --read` performs the lookup and read together.

Function discovery is scoped: `musoq describe functions system --filter Split` before trying an unfamiliar split function. If the namespace is unknown, search one task recipe first. Avoid reading every function or specification just to start a query.

For fixed output columns use the pivot's explicit IN list. Use conditional aggregates when only a few measures are needed. For irregular logs, follow [interpretation](interpret.md) to parse once into fields, then aggregate those fields.
