---
name: notebook-to-config-plot-script
description: Use when migrating plotting notebooks into config-driven plotting scripts, especially in data or bioinformatics pipelines where plot intent, filters, thresholds, output paths, runner wiring, generated artifacts, and validation need to be preserved.
---

# Notebook To Config Plot Script

## Purpose

Use this skill to migrate plot-generating notebooks into reproducible, config-driven scripts. Keep the workflow plan-first and scoped to plotting behavior, not arbitrary notebook cleanup.

## Workflow

1. Inspect local instructions first: read the relevant AGENTS.md, coding-guideline skills, config-driven script guidance, and any user-specified migration plan before editing.
2. Inspect the source notebook, target script, config file, comparable config-driven scripts, runners, gitignore, generated-output conventions, and recent plans or commits that explain local style.
3. Extract notebook intent before code changes: data inputs, saved artifacts, plotting functions, grouping variables, filters, thresholds, labels, x/y limits, figure sizes, legend settings, output names, warnings, and generated files.
4. Design the config contract before editing: keep paths, run flags, defaults, and run-specific plot calls in config; keep wrapper keys separate from plotting-function kwargs; if using shallow default merging, require dict-valued plotting args to be complete in each run-specific block.
5. Ask clarifying questions with the GUI question format when available. Prefer questions about scientific thresholds, whether to reuse saved upstream artifacts, generated-output commit policy, and validation expectations.
6. Write a plan and short diff summary before edits when the session rules require it. Include files to change, behavior that must stay fixed, validation commands, and assumptions.
7. Implement surgically: preserve the target script's format, logging style, public APIs, function signatures, and existing helper patterns; load configured input artifacts instead of recomputing upstream datasets unless explicitly requested.
8. Pass only plotting-function kwargs into plotting functions. Pop or handle wrapper-only keys such as run flags, file names, paths, labels, and output directories outside the plotting call.
9. Wire the runner only where the local pipeline convention expects it, and place the new script in the existing order without changing unrelated scripts.
10. Handle generated figures, logs, and summaries according to repo convention. Inspect tracked outputs and ignore rules before deciding what should be committed.
11. Validate fully after implementation: parse config, check every enabled run has required wrapper keys and nested params, compile the script, run the full script when feasible, verify expected outputs and logs, grep for stale hard-coded paths, and review warnings.
12. Review the final diff before commit. Summarize preserved behavior, generated artifacts, validation results, warnings, assumptions, and any residual risk; commit only when the user requested or approved it.

## Rules

1. Preserve scientific and statistical behavior by default, including thresholds, biological filters, collapse logic, numerical edge cases, and dataset-generation behavior.
2. Do not change public APIs, library functions, upstream dataset builders, or plotting-function semantics unless the user explicitly asks.
3. Avoid new dependencies, low-value helper functions, speculative abstractions, broad guards, and unrelated refactors.
4. Match existing repo patterns for config shape, path handling, logging, error handling, plotting cleanup, runner wiring, and generated artifacts.
5. Prefer deterministic outputs and explicit config-owned parameters over notebook globals or hidden state.
6. Keep exploratory notebook-only variants out of the production script unless the user approves them as first-class configured runs.
