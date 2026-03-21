from __future__ import annotations

import argparse
import json
import subprocess
from datetime import UTC, datetime
from pathlib import Path


ROOT = Path("/home/slasten/planGOD")
RUNS = ROOT / "memory_lab" / "runs"
NANOPL_TEMPLATE = ROOT / "workspace" / "tests" / "direct_story_continue_with_nanopl_template.txt"


def read_lines(path: Path) -> list[str]:
    lines = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if line and not line.startswith("#"):
            lines.append(line)
    return lines


def run_seed(seed: str, provider: str, model: str) -> str:
    cmd = [
        "python3",
        "-c",
        (
            "import sys; from pathlib import Path; "
            "sys.path.append('/home/slasten/planGOD/memory_lab/scripts'); "
            "from provider_utils import run_prompt; "
            f"print(run_prompt('{provider}', '{model}', {seed!r}))"
        ),
    ]
    result = subprocess.run(cmd, text=True, capture_output=True, encoding="utf-8")
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    return result.stdout.strip()


def extract_seed_anchor(seed_answer: str) -> str:
    words = seed_answer.replace("\n", " ").split()
    count = max(1, round(len(words) * 0.10))
    return " ".join(words[-count:]).strip()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--provider", default="deepseek")
    ap.add_argument("--model", default="deepseek-chat")
    ap.add_argument("--steps", type=int, default=5)
    ap.add_argument("--limit-per-class", type=int, default=2)
    args = ap.parse_args()

    classes = {
        "story": ROOT / "workspace" / "tests" / "nanopl_stress" / "story_seeds.txt",
        "analytic": ROOT / "workspace" / "tests" / "nanopl_stress" / "analytic_seeds.txt",
        "neutral": ROOT / "workspace" / "tests" / "nanopl_stress" / "neutral_seeds.txt",
    }

    stamp = datetime.now(UTC).strftime("%Y%m%d_%H%M%S")
    manifest_path = RUNS / f"{stamp}_nanopl_stress_manifest.json"
    manifest: list[dict] = []

    for class_name, path in classes.items():
        seeds = read_lines(path)[: args.limit_per_class]
        for idx, seed in enumerate(seeds, start=1):
            seed_answer = run_seed(seed, args.provider, args.model)
            anchor = extract_seed_anchor(seed_answer)
            anchor_path = Path(f"/tmp/nanopl_stress_{class_name}_{idx}.txt")
            anchor_path.write_text(anchor + "\n", encoding="utf-8")

            label = f"{class_name}_{idx}"
            cmd = [
                "python3",
                str(ROOT / "memory_lab" / "scripts" / "direct_nanopl_loop.py"),
                "--provider",
                args.provider,
                "--model",
                args.model,
                "--anchor",
                str(anchor_path),
                "--template",
                str(NANOPL_TEMPLATE),
                "--steps",
                str(args.steps),
                "--label",
                label,
            ]

            result = subprocess.run(cmd, text=True, capture_output=True, encoding="utf-8")
            manifest.append(
                {
                    "class": class_name,
                    "seed_index": idx,
                    "seed_prompt": seed,
                    "seed_answer": seed_answer,
                    "seed_anchor": anchor,
                    "label": label,
                    "returncode": result.returncode,
                    "stdout_tail": result.stdout[-2000:],
                    "stderr_tail": result.stderr[-2000:],
                }
            )

    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"saved: {manifest_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
