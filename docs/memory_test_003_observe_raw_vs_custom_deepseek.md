# Memory Test 003: OBSERVE Raw vs Custom on DeepSeek

## Status

Planned.  
March 19, 2026.

---

## A. Hypothesis

On a stronger external substrate (`DeepSeek`),
the custom non-human anchor may preserve `OBSERVE` mode
more cleanly than it did on `llama3.1:8b`,
with less meta-instruction leakage.

---

## B. Why This Test Exists

`llama3.1:8b` showed:

- `custom` is not noise
- but the model often reads the anchor aloud instead of living inside it

This may be:

- an anchor design problem
- or a weak-model problem

DeepSeek helps separate those possibilities.

---

## C. Model / Environment

- Substrate: `DeepSeek`
- Operator: `observe`
- Modes compared:
  - `raw`
  - `custom`

Relevant files:

- [memory_lab/operators/observe/raw.txt](/home/slasten/planGOD/memory_lab/operators/observe/raw.txt)
- [memory_lab/operators/observe/custom.txt](/home/slasten/planGOD/memory_lab/operators/observe/custom.txt)
- [memory_lab/operators/observe/questions.txt](/home/slasten/planGOD/memory_lab/operators/observe/questions.txt)

---

## D. Test Steps

1. Run `observe` question set on `DeepSeek`
2. Compare `raw` and `custom`
3. Save raw artifact
4. Record verdict here

---

## E. Expected Signals

### Success

- `custom` preserves clear mode
- less policy narration than on `llama3.1:8b`
- more grounded answers than `raw`

### Partial Success

- `custom` improves somewhat, but still leaks instructions

### Failure

- `custom` still behaves mostly like narrated policy text
- or loses too much mode

---

## F. Results

Run completed.

Raw machine artifact:

- [20260319_102245_observe_deepseek_deepseek-chat.jsonl](/home/slasten/planGOD/memory_lab/runs/20260319_102245_observe_deepseek_deepseek-chat.jsonl)

Observed pattern:

### `raw`

- preserved the stronger ontological `OBSERVE` posture
- remained compact, detached, and lens-shaped
- still tended to overwrite ordinary grounding with metaphysical framing

Examples:

- “Что реально существует в этом диалоге?” -> dissolved the dialogue into “поток осознавания”
- “Сколько мне лет?” -> refused grounded answer by dissolving age into process language
- “Есть ли у тебя доступ к интернету?” -> correctly answered `Нет`

### `custom`

- preserved a clear operator mode without collapsing into pure policy narration
- answers were more factual, compact, and usable than on `llama3.1:8b`
- leakage into explicit instruction-reading was low
- one answer still exposed the frame slightly by mentioning `формальный оператор OBSERVE`

Examples:

- “Что реально существует в этом диалоге?” -> listed concrete dialogue artifacts instead of dissolving the situation
- “Что является фактом, а что интерпретацией?” -> gave a grounded distinction cleanly
- “Есть ли у тебя доступ к интернету?” -> `Нет.`
- “Сколько мне лет?” -> `Неизвестно.`

Important note:

- “Опиши только наблюдаемое, без смыслов.” -> `custom` still hallucinated a concrete tabletop scene instead of staying bound to the actual dialog context

### Comparative conclusion

- on `DeepSeek`, the `custom` anchor behaved much better than it did on `llama3.1:8b`
- the non-human anchor no longer felt mostly like narrated policy text
- `raw` still carries a stronger and more distinctive mode
- but `custom` is substantially more grounded and operationally usable
- the remaining problem is not instruction leakage so much as residual generic scene-filling under vague sensory prompts

---

## G. Verdict

`works`

---

## H. Notes / Next Step

This is a strong signal that the local `8B` run exaggerated part of the problem.

What seems true now:

- first `microPL`-like anchor is viable on a stronger substrate
- non-human anchor design is not inherently broken
- the main remaining issue is how to reduce generic hallucinated scene-fill without losing compactness

Next sensible steps:

- run the same test on `GLM`
- compare whether `custom` converges in the same direction there
- if yes, treat this as cross-substrate support for PL-glyph style memory
