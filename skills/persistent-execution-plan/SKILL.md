---
name: persistent-execution-plan
description: Create, save, update, and execute a persistent implementation plan with documented questions, provisional best guesses, phased verification, and an append-only implementation scratchpad. Use when the user requests a saved or executable plan, references a `.PLAN.md`, or requires work to continue from `agent_files/plans`; not for brief conversational plans.
---

# Persistent Execution Plan

Use a plan file as the durable source of truth for substantial implementation work. Keep it current enough that another Codex session can resume safely without reconstructing decisions from chat. The scratchpad records decisions and observable work, not private chain-of-thought reasoning.

## Locate or Create the Plan

1. Read all applicable `AGENTS.md` files and repository instructions before writing.
2. If the user supplies a plan path, use that exact file and read it completely.
3. Otherwise, save the plan under the active repository's `agent_files/plans/` directory and match its existing filename and numbering convention.
4. If no convention exists, use a concise descriptive filename ending in `.PLAN.md`.
5. Do not create or update a plan outside the authorized repository or requested path.

Creating a plan does not itself authorize implementation. Follow repository-specific approval rules and record the applicable boundary in the plan.

## Required Plan Content

Keep the structure proportional to the task, but include the following information when applicable:

1. Status, creation or update date, active repository, and related repositories.
2. Objective and user-visible outcome.
3. Scope, non-goals, and behavior that must remain unchanged.
4. Open questions and current best guesses.
5. Read-only findings and relevant existing behavior.
6. Target design or implementation approach.
7. Ordered phases or steps, each with an observable completion condition and focused verification.
8. Proposed diff by repository and file or file group.
9. Overall success criteria.
10. Risks, controls, assumptions, and authorization boundaries.
11. An `Implementation scratchpad` as the final top-level section.

Do not copy large logs, source files, or generic policy text into the plan. Link or cite exact local files and record only information needed to execute, review, or resume the work.

## Questions and Best Guesses

Classify unresolved questions before execution:

1. Ask the user when the answer materially changes scientific meaning, statistical behavior, destructive scope, security or privacy, external effects, cost, permissions, public APIs, or the fundamental design.
2. For a non-blocking ambiguity, state a reasonable assumption and proceed when repository instructions permit it.
3. When the user explicitly allows a best-guess fallback if they are slow to answer, ask the useful question with a bounded response window when the interface supports it. If no answer arrives, use the safest reversible guess.
4. Record the unanswered question, selected guess, rationale, affected scope, reversibility, and later validation in `Open questions and current best guesses`.
5. Revisit provisional guesses when new evidence or user input arrives. Do not silently rewrite the earlier decision.

A best-guess instruction never grants permission for destructive actions, external publication, job submission, scientific-design changes, credential use, or access beyond the authorized scope.

## Update Before Execution

Before implementation:

1. Incorporate user answers and approved scope into the plan.
2. Reconcile the plan with current Git state and repository contents.
3. Mark superseded assumptions explicitly rather than deleting decision history.
4. Confirm that each planned write is authorized for the current session.
5. Record deferred repositories, phases, or operations and the condition required to resume them.

If the implementation direction materially changes, update the plan and obtain any newly required approval before proceeding.

## Execute the Plan

1. Work in the plan's stated order unless dependency evidence requires a change.
2. Complete and verify one coherent phase before starting a dependent phase.
3. Preserve unrelated worktree changes and all scientific, statistical, numerical, and public-interface behavior not explicitly in scope.
4. Use the narrowest checks that demonstrate each phase's success criteria.
5. Update plan status and remaining work after each meaningful phase.
6. Route specialized work through applicable domain skills, such as cross-repository porting or long-running pipeline supervision, without duplicating their detailed rules in the plan.

Do not continue mechanically when observed repository state invalidates the plan. Record the discrepancy, update the affected phase, and request direction if the required decision exceeds the best-guess boundary.

## Implementation Scratchpad

Keep `Implementation scratchpad` as the final top-level section. Append dated entries in execution order. Each meaningful entry should record:

1. Phase or objective addressed.
2. Material decisions and provisional assumptions used.
3. Files or repositories changed.
4. Commands and focused checks run, with concise outcomes.
5. Deviations from the plan and why they were necessary.
6. Failures, warnings, and checks not run.
7. Current state and next action.

Append corrections instead of rewriting prior entries without explanation. Keep entries concise and evidence-based. Never store credentials, tokens, patient-identifying information, raw private prompts, hidden reasoning, or unnecessary sensitive log content.

## Resume and Complete

When resuming in a later turn or session, read the plan and scratchpad before acting. Verify current Git and process state rather than assuming the last recorded state still holds.

At completion:

1. Reconcile every success criterion with verification evidence.
2. Mark completed, deferred, blocked, and superseded phases accurately.
3. Resolve or carry forward open questions and provisional guesses.
4. Record the final focused checks, commands not run, and remaining risks.
5. Set the plan status to complete only when the requested objective is achieved and no required implementation work remains.

The final user report should summarize the outcome and link the plan; it should not require the user to reconstruct the result from the scratchpad.
