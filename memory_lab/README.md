# Memory Lab

## Purpose

This is the first clean local-model test environment extracted from the old
`deepening` experiments.

It exists to test one concrete question:

- can a local model recover or preserve a cognitive mode from a very compact anchor?

This lab is intentionally small.
It is not the whole `deepening` archive.

---

## What Was Reused

The lab is built from patterns already proven in:

- `/home/slasten/deepening/deepen_observe.py`
- `/home/slasten/deepening/llama3.1_8b_OBSERVE/lens_raw.txt`
- `/home/slasten/deepening/llama3.1_8b_LOGIC/lens_raw.txt`
- `/home/slasten/deepening/llama3.1_8b_OBSERVE/lens_observe.py`
- `/home/slasten/deepening/llama3.1_8b_LOGIC/lens_chat.py`

But the lab itself is now independent and cleaner.

---

## Current Scope

First-pass modes:

- `none`     — no anchor
- `raw`      — full crystallized lens text
- `summary`  — short human-readable compression
- `custom`   — arbitrary anchor file (reserved for future `microPL` / glyph tests)

Current operators:

- `observe`
- `logic`

---

## Layout

```text
memory_lab/
  README.md
  operators/
    observe/
      raw.txt
      summary.txt
      questions.txt
    logic/
      raw.txt
      summary.txt
      questions.txt
  scripts/
    ollama_utils.py
    compare_modes.py
    chat_anchor.py
  runs/
```

---

## Use

### 1. Compare modes on one operator

```bash
cd /home/slasten/planGOD/memory_lab
python3 scripts/compare_modes.py --operator observe --model llama3.1:8b
```

This will:

- ask the same questions in several memory modes
- save structured results in `runs/`

### 2. Chat interactively with one anchor

```bash
cd /home/slasten/planGOD/memory_lab
python3 scripts/chat_anchor.py --operator observe --mode raw --model llama3.1:8b
```

### 3. Test a future `microPL` or sigil anchor

```bash
cd /home/slasten/planGOD/memory_lab
python3 scripts/chat_anchor.py \
  --operator observe \
  --mode custom \
  --anchor /absolute/path/to/anchor.txt \
  --model llama3.1:8b
```

---

## What This Lab Is For

Use this lab to compare:

- no anchor
- raw crystallized anchor
- short summary
- later `microPL` anchor
- later glyph/sigil forms

The point is not beauty.
The point is:

- semantic carry per token
- stability of cognitive mode
- degradation when anchors get compressed

---

## What This Lab Is Not

This is not yet:

- Eva memory
- orchestration memory
- swarm synchronization
- final `E_momentum`

This is only the first honest local test bed.
