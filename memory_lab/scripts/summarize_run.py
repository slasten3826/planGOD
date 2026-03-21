from __future__ import annotations

import argparse
import json
from collections import Counter, defaultdict
from pathlib import Path


def normalize(text: str) -> str:
    return " ".join(text.split())


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("run_file")
    args = ap.parse_args()

    path = Path(args.run_file)
    buckets: dict[tuple[str, str], list[str]] = defaultdict(list)

    with path.open("r", encoding="utf-8") as f:
        for line in f:
            record = json.loads(line)
            key = (record["mode"], record["question"])
            buckets[key].append(record["answer"])

    for (mode, question), answers in sorted(buckets.items()):
        print(f"\n=== mode={mode} ===")
        print(f"Q: {question}")
        print(f"count: {len(answers)}")
        counts = Counter(normalize(answer) for answer in answers)
        for idx, (answer, count) in enumerate(counts.most_common(5), start=1):
            print(f"{idx}. [{count}] {answer[:400]}")


if __name__ == "__main__":
    main()
