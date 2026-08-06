---
name: git-commit-in-chunks
description: Split large Git changes into size-limited commits for a specific path when a user, repository policy, or operational constraint requires an aggregate byte budget per commit. Use when Codex needs to commit many changed files safely in sequential chunks, preview bucket plans with a dry run, avoid mixing unrelated staged changes, or optionally push each chunk after commit. Do not use this skill to enforce GitHub's per-blob 100 MiB limit.
---

# Git Commit In Chunks

Use the bundled script to split changes under one target path into sequential commits that stay near a byte limit.

## Applicability

- Use this skill only when the user, repository policy, or operational workflow requires an aggregate byte budget per commit, or when independently reviewable sequential commits are otherwise requested.
- Do not split a commit solely because the combined size of multiple files exceeds 100 MiB.
- GitHub's 100 MiB restriction applies to each individual Git blob, not to the aggregate size of a commit. Multiple files below that per-blob limit may be included in one commit.
- Use `git-commits-that-push` when the concern is GitHub's per-blob limit, oversized tracked files, or pushability.

## Workflow

1. Confirm the repository root and the exact path to commit.
2. Confirm the index is clean before starting. This skill refuses to run when unrelated staged changes already exist.
3. Start with a dry run:
   `DRY_RUN=1 PUSH_CHANGES=0 bash scripts/git_commit_in_chunks.sh repo/subdir`
4. Read the bucket summary and confirm the commit count looks reasonable.
5. Run the real commit sequence only after the dry run looks correct:
   `DRY_RUN=0 PUSH_CHANGES=0 MESSAGE_PREFIX="chunked commit" bash scripts/git_commit_in_chunks.sh repo/subdir`
6. Enable pushing only when the user explicitly wants each chunk pushed:
   `DRY_RUN=0 PUSH_CHANGES=1 MESSAGE_PREFIX="chunked commit" bash scripts/git_commit_in_chunks.sh repo/subdir`

## Rules

- Run the script from inside the target repository.
- Pass an explicit `TARGET_PATH`. Do not rely on a hard-coded default.
- Keep `DRY_RUN=1` for previews and first-pass validation.
- Keep `PUSH_CHANGES=0` unless the user explicitly asks to push.
- Treat `LIMIT_BYTES` as an aggregate bucket-size policy chosen for the current task, not as GitHub's per-blob size limit.
- Review the generated bucket summary before mutating Git state.
- Use the cleanup sweep at the end to catch deletions and residual path changes instead of inventing a second manual workflow.

## Resources

- Use `scripts/git_commit_in_chunks.sh` for execution.
- Read `references/usage.md` for parameter details and test expectations.
