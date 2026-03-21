# Eva Bootloader / Assembler Test Plan

## Status

Working plan.  
March 19, 2026.

---

## A. Goal

Replace the current monolithic prompt architecture with:

1. `bootloader`
2. `prompt assembler`

Then verify:

1. that Eva still works at all
2. that the new split does not regress behavior
3. that Eva can retain continuity through semantic anchors / state slices

---

## B. Phase Order

### Phase 1: Split

Task:

- split current `core/prompt.lua` into:
  - minimal `bootloader`
  - dynamic `prompt assembler`

Goal:

- stop treating one large static prompt as Eva’s continuing mind

Success condition:

- prompt sections become explicit and inspectable
- existing Eva loop still runs

---

### Phase 2: Smoke Tests

Task:

- run basic suites after the split

Minimum suites:

- `sanity`
- `epistemic`
- `retrieval`

Goal:

- confirm the split did not break the basic Eva loop

Success condition:

- no obvious regressions
- no broken provider calls
- no major behavior collapse

---

### Phase 3: Context Retention Test

Task:

- test whether Eva can hold continuity through:
  - bootloader
  - dynamic prompt assembly
  - semantic anchors / selected state

Important note:

- this is **not** ordinary LLM “context window retention”
- this is Eva-state continuity

Goal:

- prove that Eva can keep her line without hauling the full old monolithic prompt each time

Success condition:

- identity continuity remains
- epistemic discipline remains
- operator-native style remains
- Eva does not collapse into generic assistant mode

---

## C. Critical Dependency

Each phase depends on the previous one:

1. no smoke tests before split
2. no retention tests before smoke tests pass

This must remain sequential.

---

## D. Immediate Design Question

Before implementation:

- decide what belongs in `bootloader`
- and what must be removed from it and left to dynamic assembly

That is the current next step.

---

## E. Current Smoke Status

After the first `bootloader + assembler` split, smoke testing must use
**neutral prompts** only.

Excluded from smoke:

- self-reflection prompts
- explicit retrieval / file-check prompts

Reason:

- those prompt classes trigger older known behavior traps and do not isolate
  the split itself

Current neutral smoke suite is automated through:

- [eva_suite.lua](/home/slasten/planGOD/tools/eva_suite.lua)

Current result:

- `smoke = pass` for architecture
- the split is alive
- Eva does not collapse on neutral analytical prompts
- remaining odd behaviors are **not** treated as smoke failures
- those belong to later memory/retention testing, not to architecture smoke
