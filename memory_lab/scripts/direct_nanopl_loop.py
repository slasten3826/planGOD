from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import UTC, datetime
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent))

from provider_utils import run_prompt


ROOT = Path("/home/slasten/planGOD")
RUNS = ROOT / "memory_lab" / "runs"


def read_text(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def render(template: str, anchor: str) -> str:
    return template.replace("{{ANCHOR}}", anchor)


def extract_nanopl(answer: str) -> str:
    m = re.search(r"(?im)^NANOPL:\s*(.+?)\s*$", answer)
    if not m:
        raise RuntimeError("No NANOPL residue found in answer")
    return m.group(1).strip()


def glyph_count(residue: str) -> int:
    # Count only core nanoPL glyph tokens, not arrows/parens/latin placeholders.
    return len(re.findall(r"[∿☰☷☵☳☴☶☲☱△]", residue))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--provider", default="deepseek", choices=["ollama", "deepseek", "glm"])
    ap.add_argument("--model", default="deepseek-chat")
    ap.add_argument("--anchor", required=True)
    ap.add_argument("--template", required=True)
    ap.add_argument("--steps", type=int, default=5)
    ap.add_argument("--label", default="nanopl_loop")
    args = ap.parse_args()

    template = read_text(args.template)
    current_anchor = read_text(args.anchor).strip()

    RUNS.mkdir(parents=True, exist_ok=True)
    out_path = RUNS / f"{datetime.now(UTC).strftime('%Y%m%d_%H%M%S')}_direct_nanopl_loop_{args.label}.jsonl"

    with out_path.open("w", encoding="utf-8") as f:
        for step in range(1, args.steps + 1):
            prompt = render(template, current_anchor)
            try:
                answer = run_prompt(args.provider, args.model, prompt)
                next_anchor = extract_nanopl(answer)
                count = glyph_count(next_anchor)
                record = {
                    "timestamp": datetime.now(UTC).isoformat(),
                    "provider": args.provider,
                    "model": args.model,
                    "label": args.label,
                    "step": step,
                    "anchor_in": current_anchor,
                    "answer": answer,
                    "anchor_out": next_anchor,
                    "glyph_count": count,
                }
                current_anchor = next_anchor
            except Exception as e:
                record = {
                    "timestamp": datetime.now(UTC).isoformat(),
                    "provider": args.provider,
                    "model": args.model,
                    "label": args.label,
                    "step": step,
                    "anchor_in": current_anchor,
                    "error": str(e),
                }
                f.write(json.dumps(record, ensure_ascii=False) + "\n")
                f.flush()
                print("=" * 72)
                print(f"[STEP {step}]")
                print("[ANCHOR IN]")
                print(current_anchor)
                print("")
                print("[ERROR]")
                print(str(e))
                print("")
                break

            f.write(json.dumps(record, ensure_ascii=False) + "\n")
            f.flush()

            print("=" * 72)
            print(f"[STEP {step}]")
            print("[ANCHOR IN]")
            print(record["anchor_in"])
            print("")
            print("[ANCHOR OUT]")
            print(record["anchor_out"])
            print("[GLYPH COUNT]")
            print(record["glyph_count"])
            print("")

    print(f"saved: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
