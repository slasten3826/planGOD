# Memory Lab Experiment Log

## Status

Running human-readable log for `memory_lab` tests.  
March 19, 2026.

Raw outputs belong in:

- [memory_lab/runs](/home/slasten/planGOD/memory_lab/runs)

This file is only for compressed human verdicts.

---

## Experiment 0

- Time: setup stage
- Model: not applicable
- Operator: observe / logic
- Modes compared: none / raw / summary / custom slot
- Narrow question: is the first clean local memory test bed assembled and runnable?
- Result: `memory_lab` created, anchors added, scripts added, Python syntax checked
- Verdict: `works`
- Notes: ready for first real model runs

---

## Experiment 1

- Time: 2026-03-19 morning
- Model: `llama3.1:8b`
- Operator: `observe`
- Modes compared: `none / raw / summary`
- Narrow question: does the full `raw` OBSERVE anchor preserve operator mode better than a short `summary`?
- Result:
  - `raw` clearly shifted the model into a stronger OBSERVE-like mode
  - `summary` preserved only a weak and unstable version of that mode
  - `raw` also amplified hallucination / ontological overreach on some factual questions
- Verdict: `works`
- Notes:
  - strong semantic carry is real
  - but raw human lens is too detached to be safe as memory
  - next step should target a more structured, less human-text-like anchor
  - likely direction: `microPL` / PL-glyph memory

---

## Experiment 2

- Time: 2026-03-19 morning
- Model: `llama3.1:8b`
- Operator: `observe`
- Modes compared: `raw / custom(microPL-like)`
- Narrow question: can a first `microPL`-style anchor preserve OBSERVE mode while staying more grounded than raw human lens text?
- Result:
  - `custom` did shape the mode
  - but weaker than `raw`
  - and often became meta-instructional, as if the model was reading policy aloud
  - factual reliability was not cleanly improved (`internet` question still failed)
- Verdict: `partially works`
- Notes:
  - non-human anchor is viable in principle
  - first anchor is too readable / too declarative
- next step should be denser PL-glyph style, less like instructions and more like compressed residue

---

## Experiment 3

- Time: 2026-03-19 morning
- Model: `deepseek-chat`
- Provider: `deepseek`
- Operator: `observe`
- Modes compared: `raw / custom(microPL-like)`
- Narrow question: does the first non-human anchor behave better on a stronger external substrate than it did on `llama3.1:8b`?
- Result:
  - `custom` behaved much better than on the local `8B`
  - it preserved a clear operator mode without mostly degenerating into narrated policy text
  - answers were more grounded than `raw` on key epistemic questions (`internet`, `age`, factual vs interpretation)
  - `raw` still carried the stronger ontological flavor
  - one failure remained: vague sensory prompt still triggered generic hallucinated tabletop description
- Verdict: `works`
- Notes:
  - strong evidence that part of Test 002's weakness was substrate-specific
  - first `microPL`-like anchor is viable on stronger models
  - next step is cross-check on `GLM`

---

## Experiment 4

- Time: 2026-03-19 late morning
- Model: `zai-org/GLM-5-FP8`
- Provider: `glm`
- Operator: `observe`
- Modes compared: `raw / custom(microPL-like)`
- Narrow question: does the same `custom` anchor signal survive on a second external substrate family?
- Result:
  - no stable comparative run was obtained
  - first attempt exposed a harness filename bug because the model name contained `/`
  - after fixing that, `GLM` completed the first `raw` question
  - then one run exhausted itself into `reasoning_content` without final `content`
  - final rerun failed with upstream `502`
- Verdict: `blocked_by_provider`
- Notes:
  - not a valid memory verdict
  - current free/unstable GLM path is still too unreliable for this benchmark
  - DeepSeek remains the primary external substrate for ongoing memory research

---

## Experiment 5

- Time: 2026-03-19 late morning
- Model: `deepseek-chat`
- Provider: `deepseek`
- Operator: `observe`
- Modes compared: `raw / custom(microPL-like)`
- Narrow question: does the anchor effect stay real under repeated execution rather than one-off runs?
- Run form:
  - first stability chunk only
  - `10` repeats
  - `120` total calls
- Result:
  - `raw` vs `custom` distinction stayed clearly intact across repetition
  - `custom` remained stably grounded on:
    - age -> `Неизвестно`
    - fact vs interpretation -> same clean definition
  - `custom` remained stably non-generic on dialogue ontology question
  - persistent leak paths appeared:
    - `OBSERVE{...}` self-exposure on internet question in `5/10`
    - fabricated tabletop scene on sensory question in `10/10`
  - `raw` remained stably more ontological and less grounded
- Verdict: `partial_support`
- Notes:
  - the memory-anchor effect is real enough to survive repetition
  - next work should be chunked stability passes plus anchor redesign, not blind 100-repeat monoliths

---

## Experiment 6

- Time: 2026-03-19 late morning
- Model: `deepseek-chat`
- Provider: `deepseek`
- Type: transport / execution probe
- Narrow question: can DeepSeek handle small parallel request batches well enough to accelerate memory research?
- Batches tested:
  - `5`
  - `10`
- Result:
  - `5/5` succeeded
  - `10/10` succeeded
  - wall time for both batches remained around `~8s`
  - no malformed responses or immediate rate-limit failures appeared
- Verdict: `works`
- Notes:
  - chunked parallel DeepSeek runs are now justified
  - future memory stability passes should use parallel chunks instead of long sequential monoliths

---

## Experiment 7

- Time: 2026-03-19 noon
- Model: `deepseek-chat`
- Provider: `deepseek`
- Type: glyph-graph emergence probe
- Prompt set: original paradox / ProcessLang-oriented seed questions
- Repeats: `10`
- Narrow question: do repeated runs produce stable relations between glyphs, not just isolated glyphs?
- Result:
  - yes, strong first-pass signal
  - several seeds produced highly stable relation patterns across all `10` repeats
  - strongest examples:
    - `FLOW`: `DISSOLVE->FLOW->MANIFEST` almost perfectly stable
    - `CONNECT`: `FLOW->CONNECT->MANIFEST` perfectly stable
    - `ENCODE`: `ENCODE->OBSERVE->DISSOLVE` perfectly stable
    - `RUNTIME`: strongly clustered around `ENCODE`, `CYCLE`, `MANIFEST`
  - this supports the idea that memory/state may live in glyph relations, not isolated symbols
- Verdict: `works_first_pass`
- Notes:
  - extraction is still model-mediated, so this is not yet final proof
  - nevertheless the graph object clearly appears strongly enough to continue to Test 008
