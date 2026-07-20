#!/usr/bin/env bash
set -euo pipefail

# Split changed files under one target path into roughly size-limited commits.

if [[ "$#" -lt 1 ]]; then
  echo "Usage: $(basename "$0") <target-path>" >&2
  exit 1
fi

TARGET_PATH="$1"
LIMIT_BYTES="${LIMIT_BYTES:-1000000000}"
MESSAGE_PREFIX="${MESSAGE_PREFIX:-chunked commit}"
REMOTE="${REMOTE:-origin}"
DRY_RUN="${DRY_RUN:-1}"
PUSH_CHANGES="${PUSH_CHANGES:-0}"
BUCKET_DIR="${BUCKET_DIR:-$(mktemp -d /tmp/git-buckets.XXXXXX)}"

cleanup() {
  if [[ -n "${BUCKET_DIR:-}" && -d "$BUCKET_DIR" && "$BUCKET_DIR" == /tmp/git-buckets.* ]]; then
    rm -rf -- "$BUCKET_DIR"
  fi
}
trap cleanup EXIT

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
BRANCH="${BRANCH:-$CURRENT_BRANCH}"

if ! [[ "$LIMIT_BYTES" =~ ^[0-9]+$ ]] || [[ "$LIMIT_BYTES" -le 0 ]]; then
  echo "LIMIT_BYTES must be a positive integer; got: $LIMIT_BYTES" >&2
  exit 1
fi

if ! git diff --cached --quiet; then
  echo "Refusing to run with staged changes already present." >&2
  echo "Commit, unstage, or stash them first so each chunk commit is isolated." >&2
  exit 1
fi

set +e
python - <<'PY' "$TARGET_PATH" "$LIMIT_BYTES" "$BUCKET_DIR"
import os
import pathlib
import subprocess
import sys
from typing import List, Tuple

target_path = sys.argv[1]
limit = int(sys.argv[2])
outdir = pathlib.Path(sys.argv[3])
outdir.mkdir(parents=True, exist_ok=True)

tracked_cmd = [
    "git",
    "ls-files",
    "-m",
    "-d",
    "--",
    target_path,
]
untracked_cmd = [
    "git",
    "ls-files",
    "-o",
    "--exclude-standard",
    "--",
    target_path,
]
tracked_proc = subprocess.run(tracked_cmd, check=True, capture_output=True, text=False)
untracked_proc = subprocess.run(untracked_cmd, check=True, capture_output=True, text=False)
paths = [
    os.fsdecode(path)
    for proc in (tracked_proc, untracked_proc)
    for path in proc.stdout.splitlines()
    if path
]
if not paths:
    summary_path = outdir / "bucket_summary.txt"
    with summary_path.open("w", encoding="utf-8") as summary:
        summary.write(f"target_path={target_path}\n")
        summary.write(f"limit_bytes={limit}\n")
        summary.write("changed_files=0\n")
        summary.write("bucket_count=0\n")
    print(
        f"No modified or untracked existing files found under {target_path}. "
        "A final git add --all sweep will still stage deletions.",
        file=sys.stderr,
    )
    sys.exit(2)

seen = set()
files: List[Tuple[str, int]] = []
for path in paths:
    if path in seen:
        continue
    seen.add(path)
    try:
        size = os.path.getsize(path)
    except FileNotFoundError:
        size = 0
    files.append((path, size))

files.sort(key=lambda item: item[1], reverse=True)

buckets: List[List[Tuple[str, int]]] = []
remaining: List[int] = []
for path, size in files:
    best_idx = None
    best_after = None
    for idx, rem in enumerate(remaining):
        if size <= rem:
            after = rem - size
            if best_after is None or after < best_after:
                best_idx = idx
                best_after = after
    if best_idx is None:
        buckets.append([(path, size)])
        remaining.append(max(limit - size, 0))
    else:
        buckets[best_idx].append((path, size))
        remaining[best_idx] -= size

summary_path = outdir / "bucket_summary.txt"
with summary_path.open("w", encoding="utf-8") as summary:
    summary.write(f"target_path={target_path}\n")
    summary.write(f"limit_bytes={limit}\n")
    summary.write(f"changed_files={len(files)}\n")
    summary.write(f"bucket_count={len(buckets)}\n")
    for i, bucket in enumerate(buckets, 1):
        bucket_path = outdir / f"bucket_{i:02d}.list"
        with bucket_path.open("wb") as fh:
            fh.write(b"\0".join(os.fsencode(path) for path, _ in bucket))
        total_size = sum(size for _, size in bucket)
        summary.write(f"{bucket_path.name}\t{total_size}\t{len(bucket)}\n")
        print(f"{bucket_path}\t{total_size / 1e9:.2f} GB\t{len(bucket)} files")
PY
python_status=$?
set -e

if [[ "$python_status" -ne 0 && "$python_status" -ne 2 ]]; then
  exit "$python_status"
fi

mapfile -t bucket_files < <(find "$BUCKET_DIR" -maxdepth 1 -type f -name 'bucket_*.list' | sort)

echo "Using repo root: $REPO_ROOT"
echo "Target path: $TARGET_PATH"
echo "Limit bytes: $LIMIT_BYTES"
echo "Branch: $BRANCH"
echo "Push after each commit: $PUSH_CHANGES"
echo "Dry run: $DRY_RUN"
echo "Bucket summary: $BUCKET_DIR/bucket_summary.txt"

if [[ "$DRY_RUN" == "1" ]]; then
  exit 0
fi

total_buckets="${#bucket_files[@]}"
for idx in "${!bucket_files[@]}"; do
  bucket_file="${bucket_files[$idx]}"
  bucket_name="$(basename "$bucket_file" .list)"
  commit_num="$((idx + 1))"

  echo "Staging $bucket_name ($commit_num/$total_buckets)"
  git add --all --pathspec-from-file="$bucket_file" --pathspec-file-nul

  if git diff --cached --quiet; then
    echo "Skipping $bucket_name because it staged no changes."
    continue
  fi

  git commit -m "$MESSAGE_PREFIX chunk ${commit_num}/${total_buckets} (${bucket_name})"

  if [[ "$PUSH_CHANGES" == "1" ]]; then
    git push "$REMOTE" "$BRANCH"
  fi
done

echo "Staging any remaining deletions or late changes under $TARGET_PATH"
git add --all -- "$TARGET_PATH"

if ! git diff --cached --quiet; then
  git commit -m "$MESSAGE_PREFIX cleanup remaining changes under $TARGET_PATH"

  if [[ "$PUSH_CHANGES" == "1" ]]; then
    git push "$REMOTE" "$BRANCH"
  fi
fi
