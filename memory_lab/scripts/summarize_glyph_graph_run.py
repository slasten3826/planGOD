from __future__ import annotations

import argparse
import json
from collections import Counter, defaultdict
from pathlib import Path


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("run_file")
    args = ap.parse_args()

    path = Path(args.run_file)
    node_counter: Counter[str] = Counter()
    edge_counter: Counter[str] = Counter()
    focus_counter: Counter[str] = Counter()
    seed_to_nodes: dict[str, Counter[str]] = defaultdict(Counter)
    seed_to_edges: dict[str, Counter[str]] = defaultdict(Counter)

    with path.open("r", encoding="utf-8") as f:
        for line in f:
            record = json.loads(line)
            seed = record["seed_operator"]
            graph = record["graph"]
            for node in graph.get("nodes", []):
                node_counter[node] += 1
                seed_to_nodes[seed][node] += 1
            for edge in graph.get("edges", []):
                edge_name = f'{edge["from"]}->{edge["to"]}'
                edge_counter[edge_name] += 1
                seed_to_edges[seed][edge_name] += 1
            focus = graph.get("focus", "").strip()
            if focus:
                focus_counter[focus] += 1

    print("=== global node frequency ===")
    for node, count in node_counter.most_common():
        print(f"{node}: {count}")

    print("\n=== global edge frequency ===")
    for edge, count in edge_counter.most_common():
        print(f"{edge}: {count}")

    print("\n=== seed -> top nodes ===")
    for seed, counter in sorted(seed_to_nodes.items()):
        top = ", ".join(f"{node}:{count}" for node, count in counter.most_common(5))
        print(f"{seed}: {top}")

    print("\n=== seed -> top edges ===")
    for seed, counter in sorted(seed_to_edges.items()):
        top = ", ".join(f"{edge}:{count}" for edge, count in counter.most_common(5))
        print(f"{seed}: {top}")

    print("\n=== top focus labels ===")
    for focus, count in focus_counter.most_common(20):
        print(f"{focus}: {count}")


if __name__ == "__main__":
    main()
