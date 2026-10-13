# Code and history investigations

Start with paths when the location is unknown; read an identified file directly. Use [grouped search](../recipes/many.sql) with labels for declarations, candidate callers, tests and configuration strings sharing an input scope. Match names as literals first; use regex only for a specific syntax question.

## Declarations and C# collections

[csharp-methods.sql](../recipes/csharp-methods.sql) expands a solution's Projects → Documents → Classes → Methods through CROSS APPLY. Edit the `solution` value to a .sln path. Output: Class, Method; the fixture returns Calculator / Add.

For other fields use the narrow relevant contract or a selected row. `musoq describe source "csharp.solution('Example.sln')" --top-level-only` describes the root; a missing Methods field at the root does not mean nested Methods are unavailable. Provider identifier: Roslyn; SQL schema: csharp.

Text matches and a declaration inventory produce candidates. Before reporting a resolved call, behavior change or missing protection, inspect the actual signature, overload, helper, test input and assertions. A same-named method is not necessarily the same symbol. Use semantic tooling if the task requires binding and the queried provider does not expose it.

## History

[git-history.sql](../recipes/git-history.sql) takes a repository root and returns the two latest commit subjects ordered by CommittedWhen. The fixture returns Update sample, then Add sample. Change the projection and TAKE for the question.

For unknown Git columns, use `musoq describe source "git.commits('.')" --top-level-only`. Read the selected commit/diff with Git when a subject alone cannot establish the change. Working-tree changes are separate from committed history.

## Compose a change-impact investigation

1. Choose the relevant roots and labels (changed API, configuration key, test marker).
2. Run one grouped query to find concentrated evidence.
3. Inspect selected source/test bodies and, when useful, the related history.
4. Report observed dependencies separately from candidates and uncertainty.

[composed.sql](../recipes/composed.sql) is an executable example: search TODO/FIXME together, aggregate by file, keep files with at least two hits, and join selected FIXME line evidence. Inputs: root, labels, scope and threshold. Output: Path, Hits, Line, Text. The fixture returns only Alpha.cs, two hits, line 2. It performs two scoped source reads inside one command; one CLI invocation does not imply one physical scan.

Stop once the requested impact conclusion is supported. Do not inventory the entire solution to answer a question about one known method.
