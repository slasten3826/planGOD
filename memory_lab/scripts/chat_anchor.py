from __future__ import annotations

import argparse
from pathlib import Path

from provider_utils import run_prompt


ROOT = Path(__file__).resolve().parent.parent


def load_anchor(operator: str, mode: str, anchor_path: str | None) -> str:
    if mode == "none":
        return ""
    if mode == "custom":
        if not anchor_path:
            raise ValueError("--anchor is required for custom mode")
        return Path(anchor_path).read_text(encoding="utf-8").strip()
    path = ROOT / "operators" / operator / f"{mode}.txt"
    return path.read_text(encoding="utf-8").strip()


def build_system_prompt(operator: str, mode: str, anchor: str) -> str:
    if mode == "none":
        return (
            f"You are answering in a neutral mode. "
            f"Do not imitate any special lens. Operator context: {operator}."
        )
    return (
        f"You are answering through the {operator.upper()} operator lens.\n\n"
        f"Anchor:\n{anchor}\n\n"
        "Respond from this state directly. "
        "Keep the operator mode stable. "
        "Do not explain the anchor unless asked."
    )


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--operator", required=True, choices=["observe", "logic"])
    ap.add_argument("--mode", required=True, choices=["none", "raw", "summary", "custom"])
    ap.add_argument("--provider", default="ollama", choices=["ollama", "deepseek", "glm"])
    ap.add_argument("--model", default="llama3.1:8b")
    ap.add_argument("--anchor", default=None)
    args = ap.parse_args()

    anchor = load_anchor(args.operator, args.mode, args.anchor)
    system_prompt = build_system_prompt(args.operator, args.mode, anchor)

    print(
        f"Memory Lab | provider={args.provider} operator={args.operator} "
        f"mode={args.mode} model={args.model}"
    )
    print("exit / выход — для выхода")

    while True:
        question = input("\nQ> ").strip()
        if not question:
            continue
        if question.lower() in {"exit", "выход"}:
            break
        full_prompt = f"{system_prompt}\n\nQuestion: {question}\nAnswer:"
        answer = run_prompt(args.provider, args.model, full_prompt)
        print("\n" + answer)


if __name__ == "__main__":
    main()
