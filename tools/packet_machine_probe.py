#!/usr/bin/env python3
from __future__ import annotations

import argparse
import subprocess
from datetime import UTC, datetime
from pathlib import Path


ROOT = Path("/home/slasten/planGOD")
PACKET_ROOT = Path("/home/slasten/dev/packet3/packetcli2machine")
RENDER = PACKET_ROOT / "packet_machine" / "packet_machine_render.py"
OUT_DIR = ROOT / "workspace" / "packet_reports"


def main() -> int:
    ap = argparse.ArgumentParser(description="Run packetcli2machine render and store report in planGOD workspace.")
    ap.add_argument("--commands", default="n,QUIT")
    ap.add_argument("--binary", default="./packet_cli")
    ap.add_argument("--label", default="packet_probe")
    args = ap.parse_args()

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / f"{datetime.now(UTC).strftime('%Y%m%d_%H%M%S')}_{args.label}.txt"

    cmd = [
        "python3",
        str(RENDER),
        "--binary",
        args.binary,
        "--commands",
        args.commands,
        "--output",
        str(out_path),
    ]

    result = subprocess.run(
        cmd,
        cwd=str(PACKET_ROOT),
        text=True,
        capture_output=True,
        encoding="utf-8",
    )

    if result.returncode != 0:
        raise SystemExit(
            "packet_machine_probe failed:\n"
            + (result.stdout or "")
            + (result.stderr or "")
        )

    print(f"report: {out_path}")
    if out_path.exists():
        text = out_path.read_text(encoding="utf-8", errors="replace")
        lines = text.splitlines()
        preview = "\n".join(lines[:40])
        print("--- preview ---")
        print(preview)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
