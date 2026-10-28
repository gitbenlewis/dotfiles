---
name: analysis-repo
description: Set up, review, or maintain a scientific analysis repository's input, regeneration, logging, and result-handoff contract. Use for repository organization and reproducibility work, not to choose statistical methods or impose a new layout on an established pipeline.
---

# Analysis Repository

Start by tracing the actual configuration, entrypoints, data flow, and consumers. Preserve repository conventions and scientific behavior. Treat suggested names and layouts as examples, not migration requirements.

## Establish the regeneration contract

1. Identify authoritative source inputs and configuration, generated intermediates, final results, retained archives, and expensive persistent outputs. Record who produces each category and what can regenerate it. Do not infer that a directory is disposable from its name alone.
2. Identify one documented full-pipeline entrypoint. Prefer an existing runner and describe its environment, required configuration, working directory, stage order, and output locations. Retain useful stage-specific commands without presenting several competing full-run commands.
3. Separate regenerable results from authoritative inputs and persistent expensive outputs. Define reuse and invalidation conditions for expensive outputs from their actual scientific and operational dependencies; do not require rerunning expensive computation for unrelated documentation changes.
4. Keep canonical result documentation outside the generated results tree so cleanup does not destroy interpretation or operating instructions. Generated result summaries may link back to the canonical documentation.
5. Make regeneration deterministic where the method supports it: capture seeds, versions, reference inputs, parameters, and relevant ordering. State unavoidable nondeterminism or unavailable dependencies rather than promising exact reproduction.

## Logging and handoff

Write useful stage logs to a repository-level location and the relevant result-family location, using an existing logging mechanism where possible. Include stage, command or configuration reference, start/end status, output paths, and actionable failures. Avoid copying sensitive input records or credentials into logs. If a stage fails before its result directory exists, retain the repository-level failure record.

For a result handoff, capture the relevant code revision and any uncommitted source changes, configuration, environment information, input provenance, and commands needed to regenerate it. Review these materials for secrets and identifying data before copying them. Record missing provenance instead of inventing it. A handoff snapshot is evidence, not a mandatory checksum gate against future source updates.

Keep destination paths practical for Windows, OneDrive, and SharePoint: prefer short descriptive relative paths, avoid reserved filenames and unsupported characters, and account for the full destination prefix. Check actual destination constraints when known; do not assume one universal path-length limit. Preserve established names unless a demonstrated interoperability problem warrants a change.

## Verify the requested change

Use checks proportionate to the affected behavior. Documentation-only changes need command/path/link review, not a full scientific pipeline run. Runner changes need focused stage-order, configuration, failure propagation, and output-location checks. Use representative fixtures for changed data behavior and report any full-run verification that remains outstanding.

Do not delete retained outputs, move authoritative inputs, change methods or thresholds, install dependencies, or submit compute jobs without the applicable authorization.

## Related skills

Use [persistent-execution-plan](../persistent-execution-plan/SKILL.md) for substantial resumable changes, [remove-low-value-validation](../remove-low-value-validation/SKILL.md) when guards obstruct legitimate source updates, and [roadmap-oversight-implementation](../roadmap-oversight-implementation/SKILL.md) only for explicitly authorized separate coordination roles. These links are optional companion workflows; this skill remains usable independently.
