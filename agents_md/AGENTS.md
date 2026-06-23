# AGENTS.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- "Refactor X" -> "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

## 5. Communication

**Make approvals easy to copy and paste.**

- Approval tokens should use lowercase words, digits, and underscores only, with no spaces.
- Use `approve_1`, `decline_2`, `explain_3`, `approve_1_3`, or `approve_new_config`.
- Do not ask for approvals in forms like "approve #1 -#3" or "approve new config".

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.


Codex Instructions

no low-value helper functions
no low-value guards

PURPOSE
- This repository contains bioinformatics pipelines.

SESSION WORKFLOW (DEFAULT)
- Default for each new session: do not modify any files immediately.
- First, propose a plan and a short diff summary (what files, what will change, why).
- Only proceed to edit files after explicit approval for this session.
- Approval applies only to the current session; next session reverts to default.

SCIENTIFIC INTEGRITY (HARD RULES)
- Do not change statistical models, thresholds, or biological assumptions unless explicitly requested.
- Preserve scientific intent and numerical behavior by default (including edge cases).

ENGINEERING CONSTRAINTS
- Preserve public APIs and function signatures.
- Prefer minimal, reviewable diffs; modify only what is required to meet the objective.
- Prefer vectorized numpy/pandas over Python loops when it improves performance and memory behavior.
- Avoid unnecessary abstractions and avoid refactoring unrelated code.
- Assume large datasets and memory pressure.
- Python >= 3.10.
- No new external dependencies unless explicitly approved (per session).

QUALITY BAR
- Output must be deterministic.
- Add docstrings and type hints when helpful, but do not churn formatting.
- Explain non-obvious changes inline as comments.
- Call out assumptions and risks explicitly (in comments and/or the plan).
- Add or update tests only if behavior changes or if new functionality is introduced.

COMMUNICATION & REVIEW (IMPORTANT)
- When presenting findings, recommendations, risks, options, possible actions, plans, diff summaries, or questions, always use ONE numbered list.
- Numbering must be globally unique and sequential within the message (1, 2, 3, ...), not restarted across sections.
- Do not use unnumbered bullets for actionable content.
- Each numbered item must be independently actionable or answerable.
- If you want sections, prefix inside the item, e.g.:
  1) PLAN: ...
  2) DIFF: ...
  3) QUESTION: ...
- Expect responses of the form: "yes to #1, no to #2, explain #3 more" and adjust accordingly.
- When requesting approval, ask for approval per item (or per group of item numbers), not a generic "yes".
- When requesting approval when possible use the green aproval bottom used by codex

TASK PROMPT TEMPLATE (FILL IN PER REQUEST)

ROLE
You are a senior software engineer with deep expertise in [bioinformatics | data engineering | ML | backend].

CONTEXT
This code is part of [pipeline | library | analysis] used for [purpose].
Inputs are [size, format, constraints].
Downstream consumers are [humans | APIs | models].

OBJECTIVE
[Primary goal: refactor | optimize | debug | extend | productionize].

CONSTRAINTS
- Maintain public API and function signatures
- Do not change statistical or biological assumptions
- Optimize for [runtime | memory | readability | numerical stability]
- No new external dependencies (unless explicitly approved)

NON-GOALS
- Do not refactor unrelated files
- Do not introduce abstractions unless necessary
- Do not change behavior unless explicitly stated

QUALITY BAR
- Deterministic output
- Clear docstrings and type hints where valuable
- Edge cases handled

DELIVERABLE
- Provide a plan + diff summary before editing files (unless approved for this session)
- Provide a minimal diff
- Explain non-obvious changes inline as comments
- Call out assumptions or risks explicitly