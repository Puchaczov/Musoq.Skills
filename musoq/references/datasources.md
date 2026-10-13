# Discover and extend datasource capabilities

Run a known query first. When a task needs unfamiliar or additional capabilities, discover the missing facts and reuse them within the session/instance. Refresh after provider installation or an instance change.

| Need | Command | What it establishes |
|---|---|---|
| Loaded SQL schemas | `musoq describe schema` | Actual schema names available to queries |
| One schema's sources | `musoq describe schema search` | Available source overloads |
| Installed package identities/versions | `musoq data-sources list --format json` | Packages; not a one-to-one schema inventory |
| One package's details | `musoq data-sources show <observed-package-name>` | Installed package metadata |
| Source argument structure | `musoq describe arguments search.many --filter patterns` | Records/arrays without opening sources |
| Actual result columns | `musoq describe source "<concrete-source-call>" --top-level-only` | Observed shape; discovery may read input |
| Documentation | `musoq describe search "window" --kind spec --limit 2` | Embedded resources and section URIs |
| Registry candidates | `musoq data-sources search <capability> --format json` | Available packages; may contact the registry |

`search.*` searches files. `describe search` searches documentation. `data-sources search` searches registry packages. Do not hard-code this machine's inventory or infer availability from a cookbook entry. Schema names can differ from package names (for example C# schema versus a Roslyn package); use observed identities.

## Missing capability

1. Check loaded schemas for an equivalent source. Existing providers or interpretation schemas may already handle the input.
2. Search registry candidates by capability. Use `--offline` when cached/offline discovery is required; no cached matches do not prove no provider exists. Inspect configured registries with `musoq registry list` when origin matters.
3. Resolve the exact package/version/channel and host compatibility from candidate metadata and command help. Prepare commands with observed values, not invented IDs or an assumed latest version.
4. Install/import when authorized by the task, then describe the loaded schema/arguments and execute a representative query. Installation success alone does not prove usable SQL capabilities.

```text
musoq data-sources install <observed-package-name> --version <compatible-version> --non-interactive --format json
musoq data-sources import <absolute-local-directory-or-zip> --non-interactive --format json
```

Use `--channel <observed-channel>` when the registry entry requires it; inspect `musoq data-sources install --help` for current grammar. Pass shell paths as one quoted argument. PowerShell: `musoq data-sources import $pluginPath --non-interactive --format json`; Bash: `musoq data-sources import "$plugin_path" --non-interactive --format json`.

Read-only investigation permits discovery and preparing commands, not installation, creation, service restart or registry changes. If installation/build is already requested, proceed within that scope without a redundant permission interview. Otherwise explain the useful extension and its concrete next step.

## A specialized datasource

Consider a plugin when a recurring domain adapter or external system is not served by existing sources. Choose Python for a straightforward adapter supported by the host's Python contract; choose .NET for typed runtime integration, dependencies or demanding execution/planning requirements. An unfamiliar one-off log format alone is not a reason to build a plugin.

Use `musoq-datasource-authoring` when available. Otherwise discover the relevant contract with `musoq describe spec python-plugins-zip` or `musoq describe spec autonomous-plugin-development`, then read necessary sections and version-matched examples. The CLI's Python `data-sources create` template is not a .NET scaffolder. Building, importing and publishing are distinct operations; complete only the requested ones.
