from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path


GLYPHS = "▽☰☷☵☳☴☶☲☱△"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("jsonl", nargs="+")
    args = ap.parse_args()

    glyph_counter = Counter()
    form_counter = Counter()
    error_count = 0

    for path_str in args.jsonl:
        path = Path(path_str)
        for line in path.read_text(encoding="utf-8").splitlines():
            row = json.loads(line)
            if row.get("error"):
                error_count += 1
                continue
            residue = row.get("anchor_out", "")
            glyphs = re.findall(f"[{GLYPHS}]", residue)
            glyph_counter.update(glyphs)
            form = re.sub(f"[{GLYPHS}]", "G", residue)
            form_counter[form] += 1

    print("Glyph frequencies:")
    for glyph, count in glyph_counter.most_common():
        print(f"  {glyph}: {count}")

    print("\nTop residue forms:")
    for form, count in form_counter.most_common(20):
        print(f"  {form}: {count}")

    print(f"\nErrors: {error_count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
