# AGENTS.md

General Codex instructions for a Linux compute environment used primarily for bioinformatics pipelines. Merge these rules with any more-specific `AGENTS.md` files discovered for the active working directory.

## 1. Session workflow

- Begin each new session with read-only inspection; do not modify files immediately.
- Before editing, state material assumptions, provide a brief plan with success criteria, and summarize the proposed diff by file.
- Edit files only after explicit approval for the current session. Approval does not carry into a new session.
- Ask a clarifying question only when ambiguity would materially change the implementation; otherwise state a reasonable assumption and proceed.
- Keep plans proportionate to the task.

## 2. Scientific integrity

- Do not change statistical models, thresholds, biological assumptions, or interpretation unless explicitly requested.
- Preserve scientific intent, numerical behavior, and edge-case behavior by default.
- Call out assumptions and risks that could affect scientific conclusions.

## 3. Engineering constraints

- Preserve public APIs and function signatures unless explicitly authorized otherwise.
- Make the smallest reviewable change that satisfies the request.
- Do not refactor, reformat, or remove unrelated code.
- Match the existing style. Remove only imports, variables, or functions made unused by your change.
- Avoid speculative features, unnecessary abstractions, low-value helper functions, and low-value guards.
- Add validation or error handling only for concrete, reachable failure modes.
- Do not add external dependencies without explicit approval for the current session.
- Assume large datasets and memory pressure.
- When editing Python, target Python 3.10 or newer and prefer vectorized NumPy or pandas operations when they materially improve runtime or memory use.

## 4. Quality and verification

- Keep output deterministic.
- Define verifiable success criteria and run focused checks before claiming completion.
- For bug fixes or new behavior, add or update focused tests when the repository has applicable test infrastructure.
- For refactors, verify relevant behavior before and after the change.
- Add docstrings, type hints, or comments only when they clarify non-obvious behavior; avoid formatting churn.
- Report commands that were not run and any remaining verification risks.

## 5. Communication and approval
**Make approvals easy to copy and paste.**
- Present findings, recommendations, risks, options, plans, diff summaries, approval requests, and questions in one numbered list.
- Use globally sequential numbering within each message; do not restart numbering in subsections.
- Do not use unnumbered bullets for actionable content. Make each numbered item independently answerable.
- Request approval for specific numbered items or an explicit numbered range.
- End each approval request with an exact suggested response token.
- Tokens may contain only lowercase letters, digits, and underscores.
- Use `approve_1`, `decline_2`, or `explain_3` for individual items.
- Use `approve_1_and_3` for separate items and `approve_1_through_3` for a range.
- Accept equivalent clear natural-language responses from the user.
- Do not suggest approval tokens containing spaces, `#`, or punctuation.
- Use the Codex approval UI when available.
