# Datasource contracts and verification

Read the installed host's relevant embedded contract first when it is available. For runtime-v2, use `musoq describe spec autonomous-plugin-development --section runtime-v2-public-contract-surface`; for .NET packaging use `musoq describe spec dotnet-plugins-zip --section package-structure`. The corresponding source guides below are supplementary when a target checkout exists; locate the relevant section instead of loading the whole documentation tree.

For the boundaries below, read the exact installed section with `musoq describe spec <spec> --section <section>`. Read only the sections needed to support the requested design. For an unlisted boundary, search a short public API or concept term, for example `musoq describe search "IChunkWriter" --kind spec --limit 2` or `"plugin cancellation"`. Select by title, excerpt and match metadata, follow the returned read action and check that the section actually establishes the needed contract. Public symbols such as SourcePlanResult are useful search terms; speculative internal implementation names are not an efficient contract-discovery route. If a lookup fails, simplify once or report the unresolved detail. Checkout headings may differ from installed catalog identities. A design request can finish with explicit implementation/verification steps without resolving absent project dependencies.

| Boundary | Installed spec | Section |
|---|---|---|
| Runtime-v2 public contract | autonomous-plugin-development | runtime-v2-public-contract-surface |
| Typed table metadata | autonomous-plugin-development | table-metadata |
| Streaming rows and cancellation | autonomous-plugin-development | rowsource-class |
| Schema registration and planning default | autonomous-plugin-development | schema-class |
| Secret/phase settings | autonomous-plugin-development | source-runtime-settings |
| Static XML discovery | autonomous-plugin-development | phase-4-xml-documentation-critical |
| SQL planning verification | autonomous-plugin-development | planning-tests |
| Settings verification | autonomous-plugin-development | runtime-settings-tests |
| .NET archive layout | dotnet-plugins-zip | package-structure |
| Python protocol | python-plugins-zip | python-dataplugin-v2-contract |
| Python archive layout | python-plugins-zip | package-structure |

When implementing in a checkout, supplementary guides include MusoqAutonomousPluginDevelopment.md, MusoqPluginsDevelopment.md, MusoqDotnetPluginsZipSpecification.md and MusoqThirdPartyDatasourceRepositorySetup.md. Resolve their paths and versions in the target project instead of using their headings as installed catalog identities.

**Metadata.** Public parameter names are API. Dynamic shape and execution must receive compatible TABLE/COUPLE and read-modifier information. Use dictionary rows only when dynamic shape requires them. Source metadata resolution can perform I/O; describe that behavior accurately.

**Planning.** Apply only accepted work from the execution plan. Keep unsupported predicates residual. Do not accept an early slice before unresolved predicate/order dependencies. Test null/case/type semantics and multi-key ordering; illustrative optimizer snippets are not a correctness proof.

**Lifetime.** Separate clients from metadata; stream bounded chunks. Honor cancellation and dispose owned resources. A pooled buffer cannot be reused while a consumer still observes it.

**Settings.** Declare phase/secret metadata and keep values out of SQL and diagnostics. Test missing settings and invalid values through actual compiled queries.

**Verification.** Cover constructor/column discovery, rows, dynamic shape, parameters, nulls, cancellation, diagnostics, accepted/residual planning, ordering and slicing. A successful project build alone does not prove host compatibility.

**Packaging.** Use the repository's scripts and resolved version train. Verify exact SemVer, XML, nested archive layout, dependency closure, notices and compatibility manifest. Exclude host-owned runtime assemblies according to the applicable package contract. Python uses a separate protocol; check the actual host's required files before packaging it.
