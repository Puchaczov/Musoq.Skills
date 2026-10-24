# Discover a format through falsifiable hypotheses

Use this workflow when the layout is unknown, including iterative binary discovery. A known-layout implementation needs only its ordinary fixture checks.

## Establish the corpus and record

Inspect sample identities, sizes and permitted access before selecting a bounded comparison set. Include examples differing in size, content or known application state; reserve some for validation when possible. Record why each was selected and which populations are absent. Use byte-preserving reads for binary input and keep text decoding separate.

Use the installed `musoq-investigation` skill for workspace creation, capture, reasoning, pinned evidence and continuation. Read its entrypoint and only the references needed for the current operation. Keep the workspace outside scanned inputs, and open a supplied workspace before creating another. If that skill is unavailable, discover `musoq investigation capabilities` and `musoq describe manual investigations-automation`; do not invent mutation contracts.

Keep exact SQL/parameters, source paths and sizes, hashes of the bytes actually inspected, runtime identity (`musoq --version`), sample-selection notes and independent-check artifacts beside the workspace. For mutable sources, record the read time and ensure the hash describes the inspected bytes; hashing another read later does not establish their identity. Copy samples only when permitted. Record original and derived identities if an authorized transformation is needed.

## Propose, discriminate, retain

1. Locate candidate boundaries using repeated markers, structural changes and record-size relationships. Compare aligned and unaligned samples; a repeated byte sequence may occur inside payloads.
2. Write competing interpretations before probing: width/order/signedness, byte length versus element count, absolute versus relative offset, delimiter versus padding, tag versus flag, checksum versus unknown integer. State what observation would distinguish them.
3. Use the smallest discriminating query and an independent calculation or decoder. Prefer samples where predictions differ; do not count agreement between two copies of the same schema as independent confirmation.
4. Capture substantive SQL directly through `investigation capture`, avoiding a preceding `run` of the same observation. Capture scalar offsets, values, tags, lengths and input IDs when nested values cannot be retained. Full execution and full retention must both succeed before treating rows as retained evidence.
5. Pin claims and assessments to exact observation versions/checksums through the investigation contracts. Separate observed facts from attributed hypotheses; preserve rejected candidates and counterexamples. Attach external decoder calculations as attributed artifacts/notes, not fabricated captured SQL observations.
6. Grow the schema only after a hypothesis survives discriminating tests. Check held-out samples and rejection counts. Retain raw unexplained ranges rather than assigning invented semantics.

For text, use record-family comparisons and held-out variants, not just a pattern that fits all sampled lines. For binary, validate lengths against the next boundary, offsets against their candidate origins, and counts against fully consumed records. A checksum hypothesis needs a specified algorithm, covered byte range and tests across changing samples; a single match is insufficient.

When passive comparisons leave multiple layouts plausible, use controlled samples from a producer when available within the task: change one known value or record count at a time and compare changed byte ranges. Group samples by evidenced version/tag before assuming one layout fits every file. Track candidate field ranges, offset origins, predictions and counterexamples in concise layout notes. High-entropy or unreadable regions alone do not prove compression or encryption; preserve them as unknown payloads until a discriminator is available.

## Exercise ambiguity explicitly

[Discovery samples](../recipes/discovery-samples.sql) contain three four-byte inputs. Interpret the first two bytes as a candidate little-endian length and the following two bytes as a raw range. Independently, `02001122`, `02003344`, and `0200AABB` all predict a length of two and a four-byte total. This is also consistent with a constant two-byte prefix; it does **not** establish that the prefix is a length, or the meaning of either remaining byte.

Retain both hypotheses. Request a different-sized sample, a controlled producer experiment or an authoritative layout to discriminate them. The supplied fixture has no held-out size variation, so report that limitation instead of claiming a recovered format. See [validation](validation.md) for the observed-value oracle.

## Continue and finish honestly

On continuation, recall the supplied workspace, expand relevant authored bodies and read pinned retained rows before trusting prior claims. Verify whether current inputs still match the recorded identities. New executions are new observations, even when SQL is unchanged.

Finish when requested fields and framing are supported on the agreed corpus, or record a bounded inconclusive outcome when progress needs new samples, producer knowledge or missing runtime support. Deliver SQL, permitted fixtures, expected results, layout notes, rejection counts, workspace location and unresolved questions. Do not make report publication a mandatory stage. Do not mark a still-active discovery finished just to export a report.
