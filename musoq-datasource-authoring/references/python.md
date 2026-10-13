# Build a specialized Python adapter

Choose Python when the host's supported plugin protocol expresses the adapter's arguments, scalar columns, environment/settings and row delivery. Choose .NET when typed runtime-v2 planning or .NET libraries are required; Python templates do not implement those .NET contracts.

## Inspect, then scaffold within the requested scope

Read `musoq data-sources create --help` and `musoq describe spec python-plugins-zip --section python-dataplugin-v2-contract`. For packaging, read `musoq describe spec python-plugins-zip --section package-structure`. Compare the host's template and a version-matched example before coding. Design-only requests need those relevant contracts, not a template creation or a whole-spec dump.

When creation is authorized, the CLI supports these Python templates:

```text
musoq data-sources create <chosen-name> --template basic --format json
musoq data-sources create <chosen-name> --template api --format json
musoq data-sources create <chosen-name> --template database --format json
```

Choose one template, inspect the returned directory and generated files, and implement there only when that destination is within the user's requested scope. The command may create a provider in the instance's datasource storage; it is not a read-only preview or a .NET scaffolder. For a requested repository-local build, author the same inspected contract in that repository instead of silently provisioning the live instance.

## Python DataPlugin v.2

The v.2 specification requires a module-level `plugin` instance in `main.py`, with schema_name, data_sources, schemas, initialize, get_required_env_vars, get_required_execute_arguments, execute and dispose. Confirm signatures against the target host before copying them. `execute(method_name, environment_variables, *args)` yields dictionaries whose keys and values match the declared columns; returning a list is not the documented generator contract. Declare supported scalar types and argument names explicitly.

Keep schema/argument discovery separate from opening network/database clients. Declare required environment inputs and keep credentials out of SQL, fixtures and diagnostics. Bound pagination, retries and row batches to the actual host/client contract; close owned resources in dispose and on failed initialization. Do not assume .NET cancellation or predicate-pushdown APIs exist in Python.

Test through the target host: metadata and arguments, representative rows, empty results, null/type handling, missing settings, malformed responses, bounded error recovery and owned-resource disposal. Use stubbed external services for deterministic tests; a syntactically valid Python module is not proof of SQL integration.

## Package and verify

Use the Python ZIP specification for the outer metadata and inner Plugin.zip layout and requirements.txt dependencies. Avoid .NET DLL/runtime manifests unless the Python specification requires them. Build the archive in the requested output directory; inspect contents before importing.

When import is requested, use `musoq data-sources import <absolute-package-or-directory> --non-interactive --format json`. Quote PowerShell paths as `$pluginPath` and Bash paths as `"$plugin_path"`. Then confirm the loaded SQL schema, describe arguments/result columns, and run a representative query. Publication is a separate operation.
