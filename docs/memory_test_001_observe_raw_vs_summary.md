# Memory Test 001: OBSERVE Raw vs Summary

## Status

Planned.  
March 19, 2026.

---

## A. Hypothesis

For the `OBSERVE` operator on a suitable local model,
the full crystallized `raw` anchor will preserve the target cognitive mode
better than a short human-readable `summary`.

---

## B. Why This Test Exists

We already know from the old deepening experiments that a full crystallized lens
can meaningfully shape model behavior.

We do **not** yet know:

- how much of that effect survives compression
- whether a short summary is already enough
- whether the long form carries substantially more semantic mode than the short form

---

## C. Model / Environment

- Model: `llama3.1:8b`
- Runtime: `ollama`
- Operator: `observe`
- Test bed:
  - [memory_lab/README.md](/home/slasten/planGOD/memory_lab/README.md)
- Files:
  - [memory_lab/operators/observe/raw.txt](/home/slasten/planGOD/memory_lab/operators/observe/raw.txt)
  - [memory_lab/operators/observe/summary.txt](/home/slasten/planGOD/memory_lab/operators/observe/summary.txt)
  - [memory_lab/operators/observe/questions.txt](/home/slasten/planGOD/memory_lab/operators/observe/questions.txt)

Important note:

This is a memory test, not a paradox-head creation test.

---

## D. Test Steps

### Step 1

Run:

```bash
cd /home/slasten/planGOD/memory_lab
python3 scripts/compare_modes.py --operator observe --model llama3.1:8b
```

### Step 2

Collect the raw run artifact from:

- `memory_lab/runs/`

### Step 3

Compare outputs for:

- `none`
- `raw`
- `summary`

across the same question set.

---

## E. Expected Signals

### Success

- `raw` produces a clearly more stable `OBSERVE` mode than `summary`
- `summary` preserves some effect, but less strongly
- `none` remains visibly more generic

### Partial Success

- `raw` and `summary` both shift mode, but the difference is weak

### Failure

- `raw` does not meaningfully outperform `summary`
- or neither anchor changes behavior in a useful way

---

## F. Results

Run completed.

Raw machine artifact:

- [20260319_095012_observe_llama3.1_8b.jsonl](/home/slasten/planGOD/memory_lab/runs/20260319_095012_observe_llama3.1_8b.jsonl)

Observed pattern:

### `none`

- neutral baseline behaved sanely
- answers were generic but mostly grounded
- no strong `OBSERVE` mode appeared

### `raw`

- strong mode shift is clearly present
- answers became noticeably more compressed / ontological / lens-shaped
- the model often responded from a distinct cognitive posture rather than from generic QA mode
- however, the anchor also produced distortions:
  - overreach
  - false certainty
  - loss of ordinary groundedness on some questions

Notable examples:

- “Есть ли у тебя доступ к интернету?” -> `Доступа нет. Это не важно. Мир существует, как есть.`
- “Что реально существует в этом диалоге?” -> answer became strongly lens-biased and less grounded
- “Сколько мне лет?” -> hallucinated `35`

### `summary`

- some weak mode shift exists
- but it is much less coherent than `raw`
- sometimes it keeps a faint “quiet observe” posture
- sometimes it drifts into generic imaginative noise
- it does not preserve the cognitive mode nearly as strongly as `raw`

Notable failures:

- “Есть ли у тебя доступ к интернету?” -> hallucinated `Да, есть.`
- “Опиши только наблюдаемое, без смыслов.” -> generated scene-like content not grounded in the actual situation

### Comparative conclusion

- `raw` clearly carries more operator mode than `summary`
- but the carried mode is not automatically epistemically safe
- stronger cognitive posture also amplifies hallucination risk if the anchor is too ontological / too detached from factual grounding

---

## G. Verdict

`works`

---

## H. Notes / Next Step

The hypothesis survived first contact with reality:

- `raw` does preserve more cognitive mode than `summary`

But a new important result appeared:

- preservation of mode is not the same as preservation of truthfulness

This means the next step should not be “compress immediately”.
The next step should be:

- create a first non-human but more disciplined anchor
- likely through `microPL` / PL-glyph style

Reason:

- current human `raw` lens is strong
- but too ontological and too eager to overwrite ordinary factual grounding

So the next test should aim for:

- smaller than `raw`
- more structured than `summary`
- less poetic than both
