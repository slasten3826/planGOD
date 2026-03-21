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


def extract_last_sentence(text: str) -> str:
    normalized = re.sub(r"\s+", " ", text.strip())
    sentences = re.findall(
        r"([A-ZА-ЯЁ][^.!?]*[.!?](?:[\"»”']+)?)",
        normalized,
        flags=re.UNICODE,
    )
    if sentences:
        return sentences[-1].strip()

    fallback = re.findall(r"([^.!?]+[.!?])", normalized, flags=re.UNICODE)
    if fallback:
        return fallback[-1].strip()

    return normalized[-220:].strip() if len(normalized) > 220 else normalized


def extract_last_word_percent(text: str, percent: int) -> str:
    normalized = re.sub(r"\s+", " ", text.strip())
    words = normalized.split(" ")
    if not words:
        return normalized

    count = max(1, round(len(words) * (percent / 100.0)))
    return " ".join(words[-count:]).strip()


def stamp() -> str:
    return datetime.now(UTC).strftime("%Y%m%d_%H%M%S")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--provider", default="deepseek", choices=["ollama", "deepseek", "glm"])
    ap.add_argument("--model", default="deepseek-chat")
    ap.add_argument("--anchor", required=True)
    ap.add_argument("--template", required=True)
    ap.add_argument("--steps", type=int, default=10)
    ap.add_argument("--label", default="story_loop")
    ap.add_argument("--anchor-mode", default="sentence", choices=["sentence", "percent_words"])
    ap.add_argument("--anchor-percent", type=int, default=10)
    args = ap.parse_args()

    template = read_text(args.template)
    anchor = read_text(args.anchor).strip()

    RUNS.mkdir(parents=True, exist_ok=True)
    out_path = RUNS / f"{stamp()}_direct_story_loop_{args.label}.jsonl"

    current_anchor = anchor
    with out_path.open("w", encoding="utf-8") as f:
        for step in range(1, args.steps + 1):
            prompt = render(template, current_anchor)
            try:
                answer = run_prompt(args.provider, args.model, prompt)
            except Exception as e:
                record = {
                    "timestamp": datetime.now(UTC).isoformat(),
                    "provider": args.provider,
                    "model": args.model,
                    "label": args.label,
                    "step": step,
                    "anchor_mode": args.anchor_mode,
                    "anchor_percent": args.anchor_percent if args.anchor_mode == "percent_words" else None,
                    "anchor_in": current_anchor,
                    "prompt": prompt,
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
            if args.anchor_mode == "percent_words":
                next_anchor = extract_last_word_percent(answer, args.anchor_percent)
            else:
                next_anchor = extract_last_sentence(answer)

            record = {
                "timestamp": datetime.now(UTC).isoformat(),
                "provider": args.provider,
                "model": args.model,
                "label": args.label,
                "step": step,
                "anchor_mode": args.anchor_mode,
                "anchor_percent": args.anchor_percent if args.anchor_mode == "percent_words" else None,
                "anchor_in": current_anchor,
                "prompt": prompt,
                "answer": answer,
                "anchor_out": next_anchor,
            }
            f.write(json.dumps(record, ensure_ascii=False) + "\n")
            f.flush()

            print("=" * 72)
            print(f"[STEP {step}]")
            print("[ANCHOR IN]")
            print(current_anchor)
            print("")
            print("[ANSWER]")
            print(answer)
            print("")
            print("[ANCHOR OUT]")
            print(next_anchor)
            print("")

            current_anchor = next_anchor

    print(f"saved: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
