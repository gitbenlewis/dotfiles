---
name: "config-driven-script"
description: "Use when adding or updating YAML-backed Python or Bash scripts that load config/config.yaml, follow config-first execution, support single-task or named-run workflows, honor run flags and default overrides, and use config/local_env.sh for environment bootstrap."
---

# Config-Driven Script

Build or modify scripts that take behavior from config instead of hard-coded paths, hard-coded run matrices, or runner-local assumptions. Outside Codex, ignore the frontmatter and use the rest of this file as a plain reference.

## When To Use

- Add a new script that should read `config/config.yaml`.
- Convert a hard-coded script into a YAML-backed entrypoint.
- Add a new named run under an existing config block.
- Update a Bash runner that activates an environment and calls scripts in sequence.
- Review a repo to confirm whether its workflow is truly config-driven or only partially wired.

## Inspect First

- `config/config.yaml`:
  identify the top-level `*_params` block the script owns.
- `config/local_env.sh`:
  confirm which environment variable the runner expects.
- `scripts/*.py`:
  decide whether the repo already uses a single-block pattern or a multi-run/defaults pattern.
- `scripts/000_*.bash`:
  confirm logging, repo-root `cd`, environment activation, and call order.
- Existing results layout:
  reuse the current `results/.../logs` convention instead of inventing a new output layout unless the repo clearly needs a new one.

## Core Contract

1. Resolve repo root from `__file__`.
2. Load `config/config.yaml` once near the top of the script.
3. Read one top-level config block for the script instead of scattering key lookups across the file.
4. Create output and log directories from config values, not from duplicated literals.
5. Use a single-block pattern for one task, or a named-run pattern for many related runs.
6. If the script supports multiple runs, gate each run with `run: true/false`.
7. Merge run-specific overrides with `default_params` before execution.
8. Keep the Bash runner responsible for bootstrap and call order, not for analysis logic.

## Config Contract To Expect

Use one top-level block per script. Keep paths, output locations, and run toggles in YAML so the code only consumes config.

```yaml
task_params:
  input_path: /path/to/repo/input/source.csv
  output_dir: /path/to/repo/results/task
  save_path: /path/to/repo/results/task/output.csv

batch_task_params:
  output_dir: /path/to/repo/results/batch_task
  default_params:
    input_path: /path/to/repo/results/base/input.h5ad
    output_dir: /path/to/repo/results/batch_task
  task_runs:
    baseline:
      run: true
      save_path: /path/to/repo/results/batch_task/baseline.csv
    alternate:
      run: false
      save_path: /path/to/repo/results/batch_task/alternate.csv
```

Use the single-block pattern when the entrypoint owns exactly one task. Use the multi-run pattern when one entrypoint executes a family of named runs that share most parameters.

## Python Entry Script

### Single-Block Pattern

Use this when one script owns one config block and one main output area.

- Load one top-level `*_params` block.
- Create `output_dir` and `output_dir/logs`.
- Read `input_path`, write `save_path`, and keep the script logic focused on the task itself.

### Multi-Run And Defaults Pattern

Use this when one script runs several named jobs with small differences.

- Store shared values in `default_params`.
- Store named jobs in `task_runs`.
- Merge run-specific overrides with defaults before each run.
- Skip disabled runs with `run: false`.

```python
#!/usr/bin/env python3
from __future__ import annotations

import logging
import sys
from collections import ChainMap
from datetime import datetime
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent
CONFIG_PATH = REPO_ROOT / "config" / "config.yaml"
with CONFIG_PATH.open("r", encoding="utf-8") as handle:
    CFG = yaml.safe_load(handle) or {}

TASK_CFG = CFG["task_params"]
BATCH_CFG = CFG.get("batch_task_params", {})

OUTPUT_DIR = Path(TASK_CFG["output_dir"])
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

LOG_DIR = OUTPUT_DIR / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)
LOG_PATH = LOG_DIR / f"{Path(__file__).stem}_{datetime.now():%Y%m%d_%H%M%S}.log"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[
        logging.FileHandler(LOG_PATH),
        logging.StreamHandler(sys.stdout),
    ],
    force=True,
)
LOGGER = logging.getLogger(__name__)


def run_single_task(params: dict) -> None:
    input_path = Path(params["input_path"])
    save_path = Path(params["save_path"])
    LOGGER.info("Reading %s", input_path)
    LOGGER.info("Writing %s", save_path)
    # load input, run task, save output


def run_named_task(run_name: str, run_params: dict, default_params: dict) -> None:
    params = dict(ChainMap(run_params, default_params))
    if not params.get("run", False):
        LOGGER.info("Skipping %s because run=false", run_name)
        return

    input_path = Path(params["input_path"])
    output_dir = Path(params["output_dir"])
    save_path = Path(params["save_path"])
    output_dir.mkdir(parents=True, exist_ok=True)

    LOGGER.info("Running %s", run_name)
    LOGGER.info("Reading %s", input_path)
    LOGGER.info("Writing %s", save_path)
    # load input, run task, save output


if __name__ == "__main__":
    run_single_task(TASK_CFG)

    default_params = BATCH_CFG.get("default_params", {})
    task_runs = BATCH_CFG.get("task_runs", {})
    for run_name, run_params in task_runs.items():
        run_named_task(run_name, run_params, default_params)
```

Notes:

- If the repo needs dual log files, add a second file handler under `scripts/logs` in addition to `output_dir/logs`.
- Do not reload YAML inside helper functions.
- Do not keep fallback path literals in code after moving those values into config.

## Bash Runner

The runner should set up the environment, capture logs, switch to repo root, and call scripts in order. Keep data logic inside Python, not in Bash conditionals.

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOCAL_ENV_FILE="${LOCAL_ENV_FILE:-${REPO_ROOT}/config/local_env.sh}"

if [[ -f "${LOCAL_ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${LOCAL_ENV_FILE}"
else
  echo "[ERROR] Missing LOCAL_ENV_FILE: ${LOCAL_ENV_FILE}" >&2
  exit 1
fi

WORKFLOW_ENV="${WORKFLOW_ENV:-<conda_env>}"

source "${HOME}/miniconda3/etc/profile.d/conda.sh"
conda activate "${WORKFLOW_ENV}"

PYTHON_BIN="$(command -v python3 || command -v python || true)"
if [[ -z "${PYTHON_BIN}" ]]; then
  echo "[ERROR] No python interpreter found on PATH." >&2
  exit 1
fi

mkdir -p "${SCRIPT_DIR}/logs"
LOG_PATH="${SCRIPT_DIR}/logs/$(basename "${BASH_SOURCE[0]}").log"
exec > >(tee -a "${LOG_PATH}") 2>&1

cd "${REPO_ROOT}"

"${PYTHON_BIN}" ./scripts/parse_inputs.py
"${PYTHON_BIN}" ./scripts/build_dataset.py
"${PYTHON_BIN}" ./scripts/run_analysis.py
```

Keep the runner thin. If the workflow needs branching, prefer toggles and paths in `config/config.yaml` rather than growing Bash control flow.

## Add A New Config-Driven Run Safely

1. Add the new run to YAML before changing Python logic.
2. Put shared values in `default_params` and only override what changes for that run.
3. Start with `run: false` if the wiring is incomplete or unvalidated.
4. Make sure the script already consumes the per-run keys you are adding:
   `input_path`, `output_dir`, `save_path`, layer names, or comparison labels should come from the merged run params, not from stale globals.
5. Keep branch-local outputs isolated when the new run should not overwrite shared summary files.
6. If downstream scripts consume the new outputs, add new config entries there too instead of hard-coding a special case.

## Validation Before Edits

- Confirm which top-level config block the script should own.
- Confirm whether the current script already respects run-specific overrides.
- Confirm where logs are written today.
- Confirm whether the runner expects an environment variable from `config/local_env.sh`.
- Confirm whether downstream scripts already accept run-specific inputs or still read one global path.

## Validation After Edits

- Run one enabled job and confirm outputs land in the configured `output_dir`.
- Leave one job disabled and confirm the script logs a skip for `run=false`.
- Confirm `default_params` values are used only when the run does not override them.
- Confirm logs are written where the repo expects them.
- Confirm the Bash runner still activates the environment, resolves Python, and runs from repo root.
- Grep for stale hard-coded paths, stale run names, or duplicate output filenames that should now live in config.

## Anti-Patterns To Avoid

- Hard-coding input or output paths in code after adding them to YAML.
- Defining named runs in YAML but still special-casing one run in Python.
- Ignoring `run: false` and executing every run anyway.
- Repeating the same shared values in every run instead of using `default_params`.
- Mixing branch-specific outputs into a shared file when separate outputs are expected.
- Hiding config reads inside scattered helpers instead of loading config once near the top.
- Letting the Bash runner own data transforms, comparisons, or output naming logic.
- Adding new config keys that the script never reads.
