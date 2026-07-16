---
name: git-commits-that-push
description: Prevent GitHub pushes from being blocked by regular Git objects larger than 100 MiB. Use when Codex prepares, reviews, creates, or pushes commits and must find oversized working-tree, staged, tracked, or outgoing files; add precise .gitignore rules for files that should remain local; and identify oversized blobs already present in commit history.
---

# Git Commits That Push

Prepare commits that GitHub can accept without deleting local large files or silently rewriting history.

## Limit

Treat a regular Git blob as oversized only when its size is greater than 100 MiB, or 104857600 bytes. GitHub enforces this limit for individual regular Git objects. See [About large files on GitHub](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github).

Do not confuse this object limit with GitHub's separate push-size limit. Do not introduce Git LFS unless the user explicitly requests it.

## Workflow

1. Resolve the repository root, inspect local instructions, and run `git status --short`. Preserve unrelated staged and unstaged work.
2. Identify the intended remote, branch, and upstream before reasoning about what a later push will contain.
3. Scan working-tree files outside `.git` for sizes greater than 104857600 bytes. Use byte-accurate checks; for example:
   `find . -path './.git' -prune -o -type f -size +104857600c -print0`
4. Inspect the index separately. For each staged or tracked candidate, obtain its index object ID with `git ls-files --stage -- <path>` and inspect the blob with `git cat-file -s <object-id>`. Do not assume the working-tree size matches the staged blob.
5. Classify every oversized path as untracked, staged-new, tracked, or already committed before changing `.gitignore`.
6. Add a precise repository-relative rule to the appropriate existing `.gitignore`, or to the repository-root `.gitignore` when no narrower file is appropriate. Prefer a root-anchored rule such as `/results/run/output.bin`.
7. Avoid broad extension or directory rules unless the user intends every matching artifact to remain untracked. Preserve existing ordering, comments, negations, and repository conventions.
8. Verify each new rule with `git check-ignore -v --no-index -- <path>`.
9. For a staged-new file, run `git restore --staged -- <path>` after adding the ignore rule. Confirm the local file still exists and is now ignored.
10. For a tracked file, remember that `.gitignore` has no effect while Git tracks it. Use `git rm --cached -- <path>` only when the user has authorized removing it from version control, and confirm the working copy remains.
11. Inspect blobs in every commit that will be included in the intended push. Enumerate the outgoing range with `git rev-list --objects <remote-base>..HEAD`, then query each blob's type and size with `git cat-file`. If no upstream exists, identify the intended remote base or conservatively scan all history reachable from `HEAD`.
12. Stop if any outgoing commit contains a blob greater than 104857600 bytes. Adding the path to `.gitignore` or committing a later deletion does not remove that blob from history.
13. Report the offending commit, object size, and path. Ask for explicit approval before amending, rebasing, using `git filter-repo`, migrating to Git LFS, or force-pushing.
14. Re-run the working-tree, index, and outgoing-history checks after remediation. Stage the intended `.gitignore` changes and confirm no oversized regular Git blob remains in the proposed push.
15. Commit or push only when the user requested it and all preflight checks pass.

## Rules

- Never delete a local oversized file merely to make a push succeed.
- Never use `git add -f` to bypass the new ignore rule.
- Never assume `.gitignore` removes a staged, tracked, or committed blob.
- Never rewrite history or force-push without explicit approval.
- Never modify global Git excludes when a repository-owned `.gitignore` is appropriate.
- Keep ignore patterns minimal, deterministic, and limited to confirmed oversized artifacts.
- Preserve unrelated index and working-tree changes.
