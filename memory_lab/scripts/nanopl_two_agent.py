from __future__ import annotations

import argparse
import json
import sys
from datetime import UTC, datetime
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent))

from provider_utils import run_prompt


ROOT = Path("/home/slasten/planGOD")
RUNS = ROOT / "memory_lab" / "runs"
NANOPL = (ROOT / "nanoPL.txt").read_text(encoding="utf-8").strip()


def read_text(path: str) -> str:
    return Path(path).read_text(encoding="utf-8").strip()


def agent1_prompt(task_text: str) -> str:
    return f"""nanoPL:
{NANOPL}

You are Agent 1.
Read the human task below.
Think about the situation and produce only a nanoPL handoff for Agent 2.

Rules:
- output only one line
- start with: NANOPL:
- no prose
- no explanation
- use nanoPL as compact state handoff

Human task:
{task_text}
"""


def loop_prompt(agent_name: str, task_text: str, turn_log: list[dict]) -> str:
    history_lines = []
    for item in turn_log:
        history_lines.append(f"{item['agent']}: NANOPL: {item['handoff']}")
    history_block = "\n".join(history_lines)

    return f"""nanoPL:
{NANOPL}

You are {agent_name}.
You are participating in a two-agent nanoPL-only coordination loop.
Read the human task and the chronological nanoPL exchange so far.

Rules:
- You may output either:
  1. one line starting with: NANOPL:
  2. or two parts:
     - one line starting with: NANOPL:
     - one line starting with: FINAL:
- internal reasoning/handoff must stay nanoPL-only
- no prose explanation of glyphs
- if coordination is not yet sufficient, do not output FINAL
- if the task is ready to close, output FINAL briefly and concretely

Human task:
{task_text}

Chronological exchange so far:
{history_block}
"""


def extract_line(prefix: str, text: str) -> str:
    for line in text.splitlines():
        if line.startswith(prefix):
            return line[len(prefix):].strip()
    raise RuntimeError(f"Missing line with prefix {prefix!r}")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--provider", default="deepseek")
    ap.add_argument("--model", default="deepseek-chat")
    ap.add_argument("--task", required=True)
    ap.add_argument("--label", default="two_agent")
    ap.add_argument("--max-turns", type=int, default=6)
    args = ap.parse_args()

    task_text = read_text(args.task)

    a1_raw = run_prompt(args.provider, args.model, agent1_prompt(task_text))
    a1_handoff = extract_line("NANOPL:", a1_raw)
    turns = [
        {
            "turn": 1,
            "agent": "Agent 1",
            "raw": a1_raw,
            "handoff": a1_handoff,
            "final": None,
        }
    ]

    final = None
    next_agent = "Agent 2"
    raw_outputs = {"Agent 1": a1_raw}

    for turn_idx in range(2, args.max_turns + 1):
        raw = run_prompt(args.provider, args.model, loop_prompt(next_agent, task_text, turns))
        handoff = extract_line("NANOPL:", raw)
        maybe_final = None
        if "FINAL:" in raw:
            maybe_final = extract_line("FINAL:", raw)
            final = maybe_final

        turns.append(
            {
                "turn": turn_idx,
                "agent": next_agent,
                "raw": raw,
                "handoff": handoff,
                "final": maybe_final,
            }
        )
        raw_outputs[f"{next_agent} turn {turn_idx}"] = raw

        if final:
            break

        next_agent = "Agent 1" if next_agent == "Agent 2" else "Agent 2"

    if not final:
        raise RuntimeError("No FINAL produced within max-turns")

    record = {
        "timestamp": datetime.now(UTC).isoformat(),
        "provider": args.provider,
        "model": args.model,
        "label": args.label,
        "task": task_text,
        "turns": turns,
        "final": final,
    }

    RUNS.mkdir(parents=True, exist_ok=True)
    out_path = RUNS / f"{datetime.now(UTC).strftime('%Y%m%d_%H%M%S')}_nanopl_two_agent_{args.label}.json"
    out_path.write_text(json.dumps(record, ensure_ascii=False, indent=2), encoding="utf-8")

    for item in turns:
        print(f"[{item['agent']} | turn {item['turn']}]")
        print(item["raw"])
        print("")
    print(f"saved: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
