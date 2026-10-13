# Execute and bind inputs

Run a reviewed SQL file directly:

```powershell
$query = (Resolve-Path -LiteralPath 'query.sql').Path
musoq run $query --from-file --format json
musoq run $query --from-file --params-json (@{root='./repo'; needle="café O'Brien"} | ConvertTo-Json -Compress) --format json
```

Use an absolute SQL file path for portable invocation from either shell. Resolve it in the caller's directory before running, especially when the query file and provider inputs live in different directories.

The second command fits [literal-parameter.sql](../recipes/literal-parameter.sql), whose declaration is `param(root: string = '.', needle: string = 'TODO')`. Bind values with JSON; do not paste untrusted values into SQL or build shell command strings. SQL uses `$root`, not shell substitution. An inline PowerShell SQL block uses `@'` on its own opening line and `'@` on its own closing line.

SQL `r'path'` preserves backslashes. Double a literal apostrophe inside an SQL string. Use `param(...)` for runtime inputs supported by a source; a `let path: string = r'orders.csv'` value is fixed when the query compiles. The CSV recipe uses that form because its provider resolves columns at compilation.

Bash equivalents:

```bash
query=$(realpath -- query.sql)
musoq run "$query" --from-file --format json
musoq run "$query" --from-file --params-json '{"root":"./repo","needle":"café O'"'"'Brien"}' --format json
json_query=$(realpath -- json-paths.sql)
printf '%s' '{"user":{"name":"Ada"},"tags":["docs"]}' | musoq run "$json_query" --from-file --format json
```

For dynamic Bash parameters, use the environment's JSON serializer and pass the resulting JSON as one argument. A quoted heredoc `<<'SQL'` preserves SQL dollar signs.

JSON is useful for processing result rows; default Markdown keeps discovery responses compact. Check process exit status before consuming output. `TAKE` limits returned rows, not necessarily provider input work. A grouping/sort can still consume the full scoped source. Source discovery can read input to infer shape.
