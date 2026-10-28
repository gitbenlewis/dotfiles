---
name: remove-low-value-validation
description: Review and remove snapshot-specific or duplicate validation that blocks expected updates to trusted inputs. Use when simplifying existing guards and their supporting stages, while preserving calculation, scientific, interface, security, and audit requirements.
---

# Remove Low-Value Validation

Classify a guard by the failure it prevents, not its syntax. Trace its producer, consumers, configuration, tests, reports, and documentation before removing it. Trusted mutable inputs may change legitimately; trust does not establish that their schema or relationships are valid.

## Decide what must remain

Preserve checks needed for correct calculations or scientific interpretation: required fields, parseability, nonblank and unique join keys, necessary null constraints, relationship cardinality, and domain invariants. Preserve authentication, authorization, compliance, explicit external interfaces, and cryptographic identifiers required by release or audit contracts.

A fixed count can express meaningful domain logic, such as the required number of approved shipment records. Do not mistake that for an obsolete source-file snapshot. When a guard's purpose is unclear, inspect its consumers and contract; retain it pending clarification if removal could change scientific meaning or security.

## Identify removal candidates

Candidates include fixed row, sample, feature, event, or shape expectations copied from an old snapshot; checksums or byte sizes used only to detect replacement of mutable files; blocking baseline manifests; modification-time checks; repeated changed-during-loading guards; and duplicate producer/consumer verification of the same trusted bytes.

First establish whether these checks instead protect a real contract, immutable release, concurrent-write hazard, or other documented operational risk. Retain or narrowly adapt a meaningful safeguard rather than deleting it because it resembles a candidate.

Do not introduce fixed source-count integrity guards for files smaller than 2 GiB solely to detect replacement or corruption. Report useful counts and validate functional invariants instead. Consider such a guard for a file of at least 2 GiB only when a documented operational risk justifies it; file size alone is not justification. This restriction does not apply to domain cardinality assertions.

## Remove the complete obsolete path

1. State each proposed removal, the expected source change it currently rejects, and the meaningful checks that will remain. Follow the repository's approval rules before editing.
2. Remove the obsolete guard and support used exclusively by it: configuration keys, manifests, pipeline stages, reports, tests, documentation, and generated artifacts tracked by the repository. Preserve shared utilities and unrelated outputs. Do not broadly delete generated data.
3. Update callers and runner dependencies so an absent validation stage cannot leave a broken workflow. Remove imports and parameters only when doing so respects public API constraints; flag incompatible changes for explicit approval.
4. Do not replace the guard with a new checksum, timestamp, shape, count, or baseline sentinel serving the same low-value purpose. Retain useful nonblocking diagnostics without turning them into new gates.
5. Verify that a legitimate source update now passes and malformed input still fails at the appropriate boundary. Use focused fixtures for preserved schema, parsing, key, and merge requirements; compare numerical results on unchanged valid input when calculations could be affected.
6. Search for remaining references to removed stages, settings, and reports. Report checks not run and any unresolved contract ambiguity.

## Related skills

Use [analysis-repo](../analysis-repo/SKILL.md) for the input and regeneration contract and [persistent-execution-plan](../persistent-execution-plan/SKILL.md) for substantial cleanup spanning sessions. Use [roadmap-oversight-implementation](../roadmap-oversight-implementation/SKILL.md) only when separate oversight and implementation roles are explicitly authorized. Companion skills are optional, not prerequisites.
