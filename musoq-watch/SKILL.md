---
name: musoq-watch
description: 'Run and troubleshoot Musoq Watch observations with filesystem, interval, or query triggers, rolling comparisons, retained state, replay, and attach consumers. Use when the user wants repeated SQL observations, monitoring until a condition, or management of existing Watch state. Ordinary one-off SQL analysis belongs to musoq; Watch engine implementation and general background scheduling are outside this skill.'
---

# Observe a question until its stopping condition

Requires the Musoq CLI with its compatible Watch extension and the datasources used by the chosen SQL. Watch is a foreground session; its connection owns the work. Use the installed command help and discoverable documentation as the version authority.

## Establish the observation

- Identify the input, query, trigger, expected result, and stopping boundary from the request. Reuse an explicit duration or condition already supplied. When neither is supplied, ask for one before starting an open-ended watch. Preparing a command alone does not require choosing a session lifetime.
- Use filesystem triggers for local changes, intervals for periodic snapshots, and query triggers for scalar transitions. A polling interval and `--keep-for` do not limit session lifetime.
- Validate an ordinary source query once with `musoq run`. Validate `watch.events()` and rolling actions inside a bounded Watch session: ordinary execution has no event batch or rolling preparation. Use `musoq` for substantial SQL discovery when available.
- Omit `--state` unless persistence is requested. Inspect an existing named state before reuse; use a fresh name for a separate observation. Keep output, cursor files, and durable state outside watched inputs.

## Read the relevant workflow

| Task | Read |
| --- | --- |
| Choose a trigger, inspect events, bind action inputs | [Triggers and runnable observations](references/triggers.md) |
| Compare snapshots, read history, retain generations | [Rolling results and state](references/rolling-state.md) |
| List, replay, attach, export, reset/delete, diagnose, or cancel | [Operations and recovery](references/operations.md) |

Run a known example directly. For an unfamiliar option, read only the relevant `musoq watch <route> --help`. For a missing workflow, use a focused search such as `musoq describe search 'durable rolling state' --kind manual --read`; follow the returned resource rather than guessing manual section IDs. Empty ordinary function discovery is not proof that a Watch-only rolling source is unavailable.

## Own the session and its effects

- Keep Watch/provider options before nested `run`, and action options such as `--from-file`, `--params-json`, and `--format` after it. Watch actions cannot consume repeatable input from `stdin`.
- Resolve existing filesystem inputs and SQL files to absolute paths. Bind dynamic action paths with serializer-generated JSON. When embedding a path in SQL, use a raw literal such as `r'C:\temp\new\input'` and double embedded apostrophes; ordinary SQL strings interpret backslash escapes.
- Choose trigger cadence and input scope for the actual workload. Bound output per turn and history separately. Repeated remote or model-backed queries inherit the source's costs and the user's existing authorization.
- Stop at the agreed boundary through the owning process, normally `Ctrl+C`, and verify it exits. Cancel only task-owned sessions. A requested cancellation can return exit code 130; report the observed result and cancellation separately.
- Inspect state after ambiguous publication or delivery failures before retrying. Reset/delete, decrypted exports, and replay with recommit have effects beyond reading history; use the user's applicable authorization, without adding a blanket approval step to ordinary authorized work.

Return the observed answer, duration or completed turns, relevant scope/limitations, and whether the session stopped. Include retained state, cursor/export locations, and an exact continuation command when they are part of the requested deliverable. Do not imply that a short successful observation qualifies an unattended service.
