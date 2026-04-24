# Usage

Use this skill when one path contains too many changes for a single commit and the commit sequence should stay near a byte limit.

## Script Interface

- Positional argument:
  - `TARGET_PATH`
- Environment variables:
  - `LIMIT_BYTES`
  - `MESSAGE_PREFIX`
  - `REMOTE`
  - `BRANCH`
  - `PUSH_CHANGES`
  - `DRY_RUN`

## Safe Defaults

- `DRY_RUN=1`
- `PUSH_CHANGES=0`
- `LIMIT_BYTES=1000000000`

## Example Runs

Preview only:

```bash
DRY_RUN=1 PUSH_CHANGES=0 bash scripts/git_commit_in_chunks.sh repo/subdir
```

Create commits without pushing:

```bash
DRY_RUN=0 PUSH_CHANGES=0 MESSAGE_PREFIX="chunked commit" \
  bash scripts/git_commit_in_chunks.sh repo/subdir
```

Create commits and push after each commit:

```bash
DRY_RUN=0 PUSH_CHANGES=1 MESSAGE_PREFIX="chunked commit" \
  bash scripts/git_commit_in_chunks.sh repo/subdir
```

## Expected Behavior

- Refuse to run when unrelated staged changes already exist.
- Print a bucket summary before any mutating work.
- Create sequential chunk commits based on bucket size.
- Perform one final `git add --all` sweep for the target path to catch deletions and residual changes.
