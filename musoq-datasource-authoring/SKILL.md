---
name: musoq-datasource-authoring
description: Design, implement, migrate, test or package a specialized Musoq datasource when requested. Use Python for straightforward adapters or .NET for typed runtime-v2 integration, source planning, XML discovery and compatible plugin archives.
compatibility: Requires the target repository's SDK/toolchain and a shell; SQL contract checks require a compatible Musoq CLI.
---

# Build a datasource that matches the target host

First establish the required input/system, schema/method names, arguments, rows, settings and ownership. Prefer an installed provider or interpretation schema when sufficient. Use this skill for a recurring specialized adapter or requested plugin work, not simply because a log format is unfamiliar.

For binary/text layout authoring or reverse engineering that existing sources can supply as bytes or strings, use `musoq-interpretation` when available. A custom layout alone does not require a datasource plugin.

## Choose the implementation route

| Need | Route |
|---|---|
| Straightforward API/database/domain adapter supported by the Python host | [Python adapter](references/python.md) |
| Typed runtime integration, .NET dependencies or demanding execution/planning requirements | .NET workflow below and [contracts](references/contracts.md) |

Resolve the installed host contract and target repository's instructions before selecting versions or dependencies. A guide's illustrative package version is not a target selection. Designing/building, importing into a live instance and publishing are separate actions; complete only the requested ones. If installation/build is already authorized, do not ask for that authorization again.

For a design-only request without a target project, verify the relevant public contracts and propose interfaces, tests and packaging. Leave dependency pinning and host execution as implementation steps; do not inventory unrelated providers or repeatedly search for internal class names to finish a design.

## .NET datasource

For implementation, start with project references and a version-matched sibling provider. Read `musoq describe spec autonomous-plugin-development --section runtime-v2-public-contract-surface` for the public runtime contract and `musoq describe spec dotnet-plugins-zip --section package-structure` when packaging. Use [contracts](references/contracts.md) for other boundaries. If a source checkout exists, compare its guides to the target host before adopting examples.

1. Define schema/method names, constructor arguments, row shape, settings, input scope and ownership.
2. Keep metadata and I/O separate. Align columns/indexes, row type, constructors, DescribeSource and GetRowSource<T>.
3. Begin source planning with `SourcePlanResult.RejectAll(request)`; accept only operations actually performed and preserve unsupported work as residual.
4. Emit bounded typed RowSource<T> chunks, honor cancellation and keep row buffers alive while consumers can observe them.
5. Keep XML discovery, assembly registration and runtime metadata synchronized.
6. Run compiled-SQL contract tests and package through the inspected repository tooling.

Use [contracts and verification](references/contracts.md) for the relevant implementation boundary. Complete the requested build or package with exact test results and compatibility evidence. Installation or publication is a separate action unless already part of the request.

For capability discovery and authorized installation, the `musoq` skill provides a datasource route when installed. This skill remains self-contained: the authoritative plugin specifications and target repository establish the implementation contract.
