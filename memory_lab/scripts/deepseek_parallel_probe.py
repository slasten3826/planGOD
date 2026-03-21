from __future__ import annotations

import argparse
import json
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from provider_utils import run_prompt


ROOT = Path(__file__).resolve().parent.parent
RUNS = ROOT / "runs"


def worker(model: str, prompt: str, idx: int) -> dict:
    started = time.time()
    try:
        answer = run_prompt("deepseek", model, prompt)
        return {
            "idx": idx,
            "ok": True,
            "latency_sec": round(time.time() - started, 3),
            "answer": answer,
        }
    except Exception as e:
        return {
            "idx": idx,
            "ok": False,
            "latency_sec": round(time.time() - started, 3),
            "error": str(e),
        }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default="deepseek-chat")
    ap.add_argument("--parallel", type=int, default=5)
    ap.add_argument(
        "--prompt",
        default="Ответь кратко: что можно знать точно, не додумывая лишнего?",
    )
    args = ap.parse_args()

    RUNS.mkdir(parents=True, exist_ok=True)
    stamp = time.strftime("%Y%m%d_%H%M%S")
    out_path = RUNS / f"{stamp}_deepseek_parallel_probe_{args.parallel}.jsonl"

    started = time.time()
    results: list[dict] = []
    with ThreadPoolExecutor(max_workers=args.parallel) as pool:
        futures = [
            pool.submit(worker, args.model, args.prompt, idx)
            for idx in range(1, args.parallel + 1)
        ]
        for future in as_completed(futures):
            record = future.result()
            results.append(record)
            print(json.dumps(record, ensure_ascii=False), flush=True)

    with out_path.open("w", encoding="utf-8") as f:
        for record in sorted(results, key=lambda item: item["idx"]):
            f.write(json.dumps(record, ensure_ascii=False) + "\n")

    success = sum(1 for item in results if item["ok"])
    failure = len(results) - success
    wall = round(time.time() - started, 3)
    print(
        json.dumps(
            {
                "parallel": args.parallel,
                "success": success,
                "failure": failure,
                "wall_sec": wall,
                "saved": str(out_path),
            },
            ensure_ascii=False,
        ),
        flush=True,
    )


if __name__ == "__main__":
    main()
