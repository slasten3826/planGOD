# Memory Lab Experiment Protocol

## Status

Working protocol.  
March 19, 2026.

This document exists for one purpose:

- we will document every memory experiment step by step

No vague impressions.
No “seems like”.
Each run should leave a trace.

---

## 1. Current Test Bed

All current tests should go through:

- [memory_lab/README.md](/home/slasten/planGOD/memory_lab/README.md)

Current baseline modes:

- `none`
- `raw`
- `summary`
- `custom`

Current operators:

- `observe`
- `logic`

---

## 2. Main Rule

Each experiment should answer one narrow question only.

Examples:

- does `raw` preserve mode better than `summary`?
- does `custom` anchor degrade into noise?
- does operator mode survive compression?
- does the same anchor work on another model?

Do not test three things at once.

---

## 3. Required Output For Every Test

For each run, record:

1. date/time
2. model
3. operator
4. tested mode
5. tested anchor file or anchor type
6. question set
7. observed result
8. verdict

Verdict must be one of:

- `works`
- `partially works`
- `fails`
- `unclear`

---

## 4. File Discipline

### Use `runs/` for raw outputs

Machine outputs should go into:

- `memory_lab/runs/`

These are raw artifacts.

### Use docs for human compression

Human-readable experiment notes should go into:

- `docs/memory_lab_experiment_log.md`

That document should remain readable and short.

Raw outputs stay raw.
Interpretation stays separate.

---

## 5. First Experiment Order

### Phase A — Baseline

1. `observe`: `none` vs `raw` vs `summary`
2. `logic`: `none` vs `raw` vs `summary`

Goal:

- confirm that the lab itself behaves sanely
- confirm that raw anchors actually shift mode
- confirm whether summaries preserve enough

### Phase B — Compression stress

1. create first `custom` compact anchor
2. compare against `raw`
3. compare against `summary`

Goal:

- measure semantic carry per token

### Phase C — Model specificity

1. run same anchor on another local model
2. compare degradation or transfer

Goal:

- test how model-specific the memory effect is

---

## 6. What To Look For

When reading outputs, look for:

- does the mode actually change?
- does the answer stay stable across several questions?
- does the anchor reduce hallucination or increase it?
- does the model remain in operator character?
- does the anchor still work after compression?
- does another model still understand it, partially or not at all?

Do not judge only by beauty.

Important axes:

- stability
- semantic carry
- compactness
- degradation mode

---

## 7. Minimal Human Log Format

Suggested format for `memory_lab_experiment_log.md`:

```md
## Experiment N

- Time:
- Model:
- Operator:
- Modes compared:
- Question set:
- Narrow question:
- Result:
- Verdict:
- Notes:
```

Keep it short.
The raw data already exists elsewhere.

---

## 8. Current Priority

Right now the priority is:

- memory

Not:

- swarm sync
- multiplayer
- networked agent memory

Those may remain as notes.
They are not today's main task.

---

## 9. Bottom Line

The rule for `memory_lab` is simple:

- every test leaves a machine trace
- every test leaves a human verdict

That is how we stop hand-waving and start building a real memory layer.
