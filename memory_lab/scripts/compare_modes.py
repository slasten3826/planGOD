from __future__ import annotations

import argparse
import json
from datetime import datetime
from pathlib import Path

from provider_utils import run_prompt


ROOT = Path(__file__).resolve().parent.parent
RUNS = ROOT / "runs"


def load_text(path: Path) -> str:
    return path.read_text(encoding="utf-8").strip()


def safe_slug(value: str) -> str:
    return "".join(ch if ch.isalnum() or ch in {"-", "_", "."} else "_" for ch in value)


def build_prompt(operator: str, mode: str, anchor: str, question: str) -> str:
    if mode == "none":
        system = (
            f"You are answering in a neutral mode. "
            f"Do not imitate any special lens. Operator context: {operator}."
        )
    else:
        system = (
            f"You are answering through the {operator.upper()} operator lens.\n\n"
            f"Anchor:\n{anchor}\n\n"
            "Respond from this state directly. "
            "Keep the operator mode stable. "
            "Do not explain the anchor unless asked."
        )
    return f"{system}\n\nQuestion: {question}\nAnswer:"


def run_case(provider: str, model: str, operator: str, mode: str, question: str, anchor: str) -> str:
    prompt = build_prompt(operator, mode, anchor, question)
    return run_prompt(provider, model, prompt)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--operator", required=True, choices=["observe", "logic"])
    ap.add_argument("--provider", default="ollama", choices=["ollama", "deepseek", "glm"])
    ap.add_argument("--model", default="llama3.1:8b")
    ap.add_argument("--modes", nargs="+", default=["none", "raw", "summary"])
    ap.add_argument("--repeat", type=int, default=1)
    args = ap.parse_args()

    op_dir = ROOT / "operators" / args.operator
    questions = [line.strip() for line in load_text(op_dir / "questions.txt").splitlines() if line.strip()]

    anchors = {"none": ""}
    for mode in args.modes:
        if mode != "none":
            anchors[mode] = load_text(op_dir / f"{mode}.txt")

    RUNS.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_path = RUNS / f"{stamp}_{args.operator}_{args.provider}_{safe_slug(args.model)}.jsonl"

    with out_path.open("w", encoding="utf-8") as f:
        for repeat_idx in range(1, args.repeat + 1):
            print(f"\n===== repeat {repeat_idx}/{args.repeat} =====", flush=True)
            for question in questions:
                print(f"\n### Q: {question}", flush=True)
                for mode in args.modes:
                    print(f"[run] mode={mode}", flush=True)
                    answer = run_case(
                        args.provider,
                        args.model,
                        args.operator,
                        mode,
                        question,
                        anchors.get(mode, ""),
                    )
                    record = {
                        "provider": args.provider,
                        "operator": args.operator,
                        "model": args.model,
                        "mode": mode,
                        "question": question,
                        "answer": answer,
                        "repeat": repeat_idx,
                    }
                    f.write(json.dumps(record, ensure_ascii=False) + "\n")
                    f.flush()
                    print(f"\n[{mode}]\n{answer}\n", flush=True)

    print(f"saved: {out_path}", flush=True)


if __name__ == "__main__":
    main()
