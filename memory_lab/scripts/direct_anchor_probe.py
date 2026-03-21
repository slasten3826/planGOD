from __future__ import annotations

import argparse
import json
from datetime import datetime
from pathlib import Path

from provider_utils import run_prompt


ROOT = Path("/home/slasten/planGOD")
RUNS = ROOT / "memory_lab" / "runs"


def read_text(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def render(template: str, anchor: str) -> str:
    return template.replace("{{ANCHOR}}", anchor)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--provider", default="deepseek", choices=["ollama", "deepseek", "glm"])
    ap.add_argument("--model", default="deepseek-chat")
    ap.add_argument("--anchor", required=True)
    ap.add_argument("--template", required=True)
    ap.add_argument("--label", required=True)
    args = ap.parse_args()

    anchor = read_text(args.anchor).strip()
    template = read_text(args.template)
    prompt = render(template, anchor)
    answer = run_prompt(args.provider, args.model, prompt)

    record = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "provider": args.provider,
        "model": args.model,
        "label": args.label,
        "anchor": anchor,
        "prompt": prompt,
        "answer": answer,
    }

    RUNS.mkdir(parents=True, exist_ok=True)
    out_path = RUNS / f"{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}_direct_anchor_{args.label}.json"
    out_path.write_text(json.dumps(record, ensure_ascii=False, indent=2), encoding="utf-8")

    print(answer)
    print("")
    print(f"saved: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
