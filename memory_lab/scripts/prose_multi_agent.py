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


def read_text(path: str) -> str:
    return Path(path).read_text(encoding="utf-8").strip()


def initial_prompt(agent_name: str, task_text: str) -> str:
    return f"""You are {agent_name}.
Read the human task below.
Produce only one concise prose handoff line for the next agent.

Rules:
- output exactly one line
- start with: HANDOFF:
- no bullets
- no essay
- keep it short and information-dense
- summarize current architectural understanding and the next key point

Human task:
{task_text}
"""


def loop_prompt(agent_name: str, task_text: str, turn_log: list[dict], min_turns: int) -> str:
    history_lines = []
    for item in turn_log:
        history_lines.append(f"{item['agent']}: HANDOFF: {item['handoff']}")
        if item.get("final"):
            history_lines.append(f"{item['agent']}: FINAL: {item['final']}")
    history_block = "\n".join(history_lines)

    return f"""You are {agent_name}.
You are participating in a multi-agent prose coordination loop.
Read the human task and the chronological handoff exchange so far.

Rules:
- You may output either:
  1. one line starting with: HANDOFF:
  2. or, if the task is truly ready to close, two parts:
     - one line starting with: HANDOFF:
     - one line starting with: FINAL:
- internal coordination must stay concise prose
- no bullets
- no essay
- do not output FINAL before at least {min_turns} total turns have happened
- if coordination is not yet sufficient, output only HANDOFF
- if ready, FINAL must be brief and concrete

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


def agent_name(index: int) -> str:
    return f"Agent {index}"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--provider", default="deepseek")
    ap.add_argument("--model", default="deepseek-chat")
    ap.add_argument("--task", required=True)
    ap.add_argument("--label", default="prose_multi_agent")
    ap.add_argument("--agents", type=int, default=4)
    ap.add_argument("--max-turns", type=int, default=12)
    ap.add_argument("--min-turns", type=int, default=None)
    args = ap.parse_args()

    if args.agents < 2:
        raise RuntimeError("agents must be >= 2")

    min_turns = args.min_turns or args.agents
    task_text = read_text(args.task)

    first_agent = agent_name(1)
    first_raw = run_prompt(args.provider, args.model, initial_prompt(first_agent, task_text))
    first_handoff = extract_line("HANDOFF:", first_raw)

    turns = [
        {
            "turn": 1,
            "agent": first_agent,
            "raw": first_raw,
            "handoff": first_handoff,
            "final": None,
        }
    ]

    final = None
    next_index = 2

    for turn_idx in range(2, args.max_turns + 1):
        raw = run_prompt(
            args.provider,
            args.model,
            loop_prompt(agent_name(next_index), task_text, turns, min_turns),
        )
        handoff = extract_line("HANDOFF:", raw)
        maybe_final = None
        if "FINAL:" in raw:
            maybe_final = extract_line("FINAL:", raw)
            final = maybe_final

        turns.append(
            {
                "turn": turn_idx,
                "agent": agent_name(next_index),
                "raw": raw,
                "handoff": handoff,
                "final": maybe_final,
            }
        )

        if final:
            break

        next_index += 1
        if next_index > args.agents:
            next_index = 1

    record = {
        "timestamp": datetime.now(UTC).isoformat(),
        "provider": args.provider,
        "model": args.model,
        "label": args.label,
        "task": task_text,
        "agents": args.agents,
        "min_turns": min_turns,
        "max_turns": args.max_turns,
        "turns": turns,
        "final": final,
        "completed": bool(final),
    }

    RUNS.mkdir(parents=True, exist_ok=True)
    out_path = RUNS / f"{datetime.now(UTC).strftime('%Y%m%d_%H%M%S')}_prose_multi_agent_{args.label}.json"
    out_path.write_text(json.dumps(record, ensure_ascii=False, indent=2), encoding="utf-8")

    for item in turns:
        print(f"[{item['agent']} | turn {item['turn']}]")
        print(item["raw"])
        print("")
    if not final:
        print("[STATUS]")
        print("No FINAL produced within max-turns.")
        print("")
    print(f"saved: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
