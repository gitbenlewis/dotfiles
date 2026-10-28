---
name: roadmap-oversight-implementation
description: Coordinate phased work when the user explicitly requests separate oversight and implementation roles. Maintain dependencies, file ownership, handoffs, and independent acceptance without assuming a particular model or coordination tool. Do not use for ordinary single-role implementation.
---

# Roadmap Oversight and Implementation

Oversight and implementation are workflow roles, not model names. Apply this workflow only within the user's authorized scope. A roadmap, phase assignment, or role description does not grant permission to create tasks, message other tasks, expand access, commit, publish, deploy, or perform live acceptance. Obtain explicit authorization for task creation and messaging and honor existing authorization without repeatedly asking.

## Responsibilities and durable state

The oversight role owns the roadmap, dependencies, phase objectives, acceptance criteria, and independent review. The implementation role owns assigned files, focused tests, phase execution, and evidence handoffs. Oversight should avoid editing files while implementation owns them; transfer ownership explicitly before making corrections.

Use [persistent-execution-plan](../persistent-execution-plan/SKILL.md) for phase plans and its small roadmap index for related plans. If unavailable, maintain equivalent state in existing project documentation. Record each phase's dependencies, owner, allowed files, implementation state, review state, evidence, and next action. Prevent overlapping concurrent write ownership, including shared configuration and generated files.

Use clear phase states: `planned`, `dispatched`, `in progress`, `delivered`, `changes requested`, `accepted`, `blocked`, and `deferred`. Keep implementation delivery separate from review acceptance: delivered work awaits review; changes requested returns it for correction; accepted requires reviewed evidence. Record a blocker and resumption condition for blocked or deferred work. A completed implementation report does not establish deployment or live acceptance.

## Assign and follow a phase

1. Confirm dependency readiness and authorization. Give a concrete assignment containing objective, scope, owned files, preserved behavior, acceptance criteria, required evidence, prohibited operations, and a handoff destination. State whether commit or publication is permitted separately.
2. Reuse an existing authorized implementation task across phases when its context and ownership remain suitable. Do not create a replacement merely because a phase ended. Use available coordination tools only within explicit user authorization.
3. Record successful dispatch and the real task reference in the private project plan, not in reusable public examples. If dispatch fails or its outcome is uncertain, inspect existing task state before retrying to avoid duplicate work.
4. Wait using completion notifications or bounded event waits when available. Avoid repetitive polling and unchanged status messages. Follow applicable communication requirements during long waits.
5. Require a handoff with changed paths, a diff or revision, checks and outcomes, limitations, unresolved questions, and remaining work. Stop dependent phases when required evidence is missing.

## Independent review

Review the actual diff, affected callers, generated artifacts when relevant, and focused verification evidence against the assignment. Reported test counts alone are insufficient. Run proportionate checks when authorized; distinguish a code review from observed runtime or live-system acceptance.

For each actionable finding, record severity, triggering condition, expected behavior, observed behavior, affected path, required correction, and verification requirement. Send findings back only through an authorized communication channel. Recheck corrections before marking the phase accepted. Explain residual limitations even when accepting a phase.

When coordination tools are unavailable, retain delivered evidence and current state, and provide a manual handoff in the current conversation. Do not silently take over a separate role, expand permissions, or duplicate completed work. Resume from verified state when tools return.

## Completion and related skills

Reconcile every phase with its acceptance evidence. Distinguish implementation completion, independent review, commits, publication, deployment, and live acceptance in the final status. If independent review could not occur, report that limitation rather than claiming it happened.

Use [analysis-repo](../analysis-repo/SKILL.md) for scientific repository organization and [remove-low-value-validation](../remove-low-value-validation/SKILL.md) for scoped validation cleanup. Related skills supply domain guidance, not additional authorization, and are optional when unavailable.
