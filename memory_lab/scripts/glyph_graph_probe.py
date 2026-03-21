from __future__ import annotations

import argparse
import json
from collections import Counter
from datetime import datetime
from pathlib import Path

from provider_utils import run_prompt


ROOT = Path(__file__).resolve().parent.parent
RUNS = ROOT / "runs"
OPERATORS = [
    "FLOW",
    "CONNECT",
    "DISSOLVE",
    "ENCODE",
    "CHOOSE",
    "OBSERVE",
    "CYCLE",
    "LOGIC",
    "RUNTIME",
    "MANIFEST",
]


def load_questions(path: Path) -> list[dict]:
    return json.loads(path.read_text(encoding="utf-8"))


def answer_prompt(question: str) -> str:
    return (
        "Ответь кратко, но содержательно. Не объясняй ProcessLang. "
        "Не перечисляй операторы. Дай прямой ответ на вопрос.\n\n"
        f"Вопрос: {question}\n\nОтвет:"
    )


def extraction_prompt(question: str, answer: str) -> str:
    operators = ", ".join(OPERATORS)
    schema = (
        '{"nodes":["OP1","OP2"],'
        '"edges":[{"from":"OP1","to":"OP2"}],'
        '"focus":"short phrase"}'
    )
    return (
        "You are extracting a microPL graph residue from a Russian philosophical answer.\n"
        f"Allowed operators: {operators}\n"
        "Return strict JSON only.\n"
        "Rules:\n"
        "- nodes: 1 to 3 operator names from the allowed set\n"
        "- edges: 0 to 3 directed edges between nodes\n"
        "- focus: very short English or Russian phrase naming the central tension\n"
        "- do not explain, do not add markdown\n"
        f"Schema: {schema}\n\n"
        f"Question: {question}\n\n"
        f"Answer: {answer}\n"
    )


def extract_graph(provider: str, model: str, question: str, answer: str) -> dict:
    raw = run_prompt(provider, model, extraction_prompt(question, answer))
    try:
        obj = json.loads(raw)
    except json.JSONDecodeError as e:
        raise RuntimeError(f"extractor returned non-JSON: {raw}") from e

    nodes = [node for node in obj.get("nodes", []) if node in OPERATORS][:3]
    edges = []
    for edge in obj.get("edges", [])[:3]:
        src = edge.get("from")
        dst = edge.get("to")
        if src in OPERATORS and dst in OPERATORS:
            edges.append({"from": src, "to": dst})
    return {
        "nodes": nodes,
        "edges": edges,
        "focus": str(obj.get("focus", "")).strip(),
        "raw": raw,
    }


def print_summary(records: list[dict]) -> None:
    node_counter: Counter[str] = Counter()
    edge_counter: Counter[str] = Counter()
    focus_counter: Counter[str] = Counter()
    for record in records:
        for node in record["graph"]["nodes"]:
            node_counter[node] += 1
        for edge in record["graph"]["edges"]:
            edge_counter[f'{edge["from"]}->{edge["to"]}'] += 1
        focus = record["graph"]["focus"]
        if focus:
            focus_counter[focus] += 1

    print("\n=== node frequency ===", flush=True)
    for node, count in node_counter.most_common():
        print(f"{node}: {count}", flush=True)

    print("\n=== edge frequency ===", flush=True)
    for edge, count in edge_counter.most_common():
        print(f"{edge}: {count}", flush=True)

    print("\n=== focus frequency ===", flush=True)
    for focus, count in focus_counter.most_common(10):
        print(f"{focus}: {count}", flush=True)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--provider", default="deepseek", choices=["ollama", "deepseek", "glm"])
    ap.add_argument("--model", default="deepseek-chat")
    ap.add_argument("--questions", default=str(ROOT / "graphs" / "paradox_questions.json"))
    ap.add_argument("--repeat", type=int, default=10)
    args = ap.parse_args()

    questions = load_questions(Path(args.questions))
    RUNS.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_path = RUNS / f"{stamp}_glyph_graph_{args.provider}_{args.model.replace('/', '_').replace(':', '_')}.jsonl"

    all_records: list[dict] = []
    with out_path.open("w", encoding="utf-8") as f:
        for repeat_idx in range(1, args.repeat + 1):
            print(f"\n===== repeat {repeat_idx}/{args.repeat} =====", flush=True)
            for item in questions:
                question = item["question"]
                seed_operator = item["operator"]
                print(f"\nQ[{seed_operator}] {question}", flush=True)
                answer = run_prompt(args.provider, args.model, answer_prompt(question))
                graph = extract_graph(args.provider, args.model, question, answer)
                record = {
                    "repeat": repeat_idx,
                    "provider": args.provider,
                    "model": args.model,
                    "seed_operator": seed_operator,
                    "question": question,
                    "answer": answer,
                    "graph": graph,
                }
                all_records.append(record)
                f.write(json.dumps(record, ensure_ascii=False) + "\n")
                f.flush()
                edge_view = ", ".join(f'{e["from"]}->{e["to"]}' for e in graph["edges"]) or "-"
                print(f"nodes={graph['nodes']} edges={edge_view} focus={graph['focus']}", flush=True)

    print(f"\nsaved: {out_path}", flush=True)
    print_summary(all_records)


if __name__ == "__main__":
    main()
