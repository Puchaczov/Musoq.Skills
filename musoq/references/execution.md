# Execute and bind inputs

Resolve the SQL file and an existing provider root in the caller's directory before invoking Musoq; the provider may execute from another working directory. With [literal-parameter.sql](../recipes/literal-parameter.sql) saved as `query.sql` and an input directory `./repo`:

```powershell
$query = (Resolve-Path -LiteralPath 'query.sql').Path
$root = (Resolve-Path -LiteralPath './repo').Path
musoq run $query --from-file --params-json (@{root=$root; needle="café O'Brien"} | ConvertTo-Json -Compress) --format json
```

The recipe declares `param(root: string = '.', needle: string = 'TODO')`. Bind dynamic paths with serializer-generated JSON rather than interpolating them into SQL. Pass the JSON as one argument; the serializer escapes backslashes and quotes for JSON without changing the path value. Do not manually double the backslashes in the value before serialization.

SQL uses `$root`, not shell substitution. An inline PowerShell SQL block uses `@'` on its own opening line and `'@` on its own closing line.

## Windows paths: SQL, shell, and JSON

Ordinary SQL strings interpret escapes such as `\r`, `\n`, and `\t`; embedding a Windows path can therefore introduce control characters. For a fixed filesystem path inside SQL, use a raw literal to preserve backslashes, or forward slashes for an ordinary drive path. Double a literal apostrophe inside an SQL string, including a raw string.

PowerShell string syntax is separate: `$path = 'C:\temp\new\repo'` preserves backslashes already. Pass native command paths, such as `$query` above, as separate arguments. The `r'...'` prefix belongs only inside SQL. Preserve UNC paths exactly with raw SQL or JSON-bound parameters; do not normalize them by replacing their separators.

Save this string-only round-trip query as `path.sql`:

```sql
param(path: string)
SELECT $path AS BoundPath,
       r'C:\temp\new\O''Brien café\repo' AS RawDrivePath,
       r'\\server\share\temp\new\O''Brien café' AS RawUncPath,
       'C:/temp/new/repo' AS ForwardPath
FROM system.dual() d
```

Bind the UNC value through JSON:

```powershell
$query = (Resolve-Path -LiteralPath 'path.sql').Path
$path = '\\server\share\temp\new\O''Brien café'
musoq run $query --from-file --params-json (@{path=$path} | ConvertTo-Json -Compress) --format json
```

`BoundPath` and `RawUncPath` return the same UNC string; `RawDrivePath` retains its backslashes and single apostrophe. This query returns strings without opening any path or contacting a network share. Keep intentional escapes in text and regex expressions unchanged; this guidance concerns filesystem path values.

Use `param(...)` for runtime inputs supported by a source. Keep compile-time paths where metadata discovery requires them: the CSV recipe uses `let path: string = r'orders.csv'` because its provider resolves columns at compilation.

## Bash

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
