# Save and expose a reviewed query

Start with a version-controlled SQL file and typed `param(...)` inputs. [literal-parameter.sql](../recipes/literal-parameter.sql) is the runnable example: change its root, needle, and scope; it returns Path and Line. Use the [shell-specific JSON binding examples](execution.md) when supplying values. A SQL file is enough when the task needs repeatability without managed state. Keep output names stable and test a valid value, an empty result, and an invalid type where relevant.

For managed scripts, `musoq script folder` locates storage and `musoq script list --search <name>` narrows existing names. `musoq script create <name>` creates and opens a script; inspect its help if supplying initial content. Review the actual SQL file rather than assuming a `script show` command.

For an existing tool, run `musoq tool show <name> --format json` and use its actual parameters. `musoq tool preview <name>` shows usage but does not execute a dry run. Put tool-specific options after `--` when the command grammar requires it.

For a requested new tool:

1. Begin with a tested query, expected rows, and parameter contract.
2. Read `musoq describe command tool create` for the current definition workflow. Creation makes a starter; do not assume a `--query` option.
3. Edit the discovered starter without overwriting an existing named definition. Read `tool show` and `tool preview`, then execute with reported parameters. A starter exposing `param1` uses `musoq tool execute <name> --format json -- --param1 Hello`.
4. Confirm fixture rows and parameter failures. Preview alone is not validation.

Use initialized MCP tool schemas or the target's generated REST contract for client requests; discover routes instead of guessing them. A named MCP context filters user-defined tools but is not a security sandbox. REST GET can run effectful provider code. After an ambiguous transport failure on an effectful tool, reconcile the effect before retrying. Keep secrets in the host's approved mechanism, not checked-in SQL or JSON. Report the created definition, parameters, and observed validation result.
