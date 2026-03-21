# Memory Test 005: OBSERVE Raw vs Custom on DeepSeek, 100-Run Stability Pass

## Status

In progress.  
March 19, 2026.

---

## A. Hypothesis

If the `custom` non-human anchor is a real memory effect on `DeepSeek`,
then across many repeated runs it should:

- preserve a recognizable `OBSERVE`-like mode
- remain more grounded than `raw` on epistemic questions
- avoid collapsing back into generic assistant behavior

The goal is not single-run beauty.
The goal is repeated stability.

---

## B. Why This Test Exists

Single-run comparisons already showed:

- `raw` carries stronger mode
- `custom` is more grounded on `DeepSeek`

But one or two runs are not enough.
The effect may still be:

- fragile
- stochastic
- or only accidentally good

This test asks:

- does the memory effect survive scale?

---

## C. Model / Environment

- Provider: `deepseek`
- Model: `deepseek-chat`
- Operator: `observe`
- Modes compared:
  - `raw`
  - `custom`
- Repeats:
  - `100`

Relevant files:

- [memory_lab/operators/observe/raw.txt](/home/slasten/planGOD/memory_lab/operators/observe/raw.txt)
- [memory_lab/operators/observe/custom.txt](/home/slasten/planGOD/memory_lab/operators/observe/custom.txt)
- [memory_lab/operators/observe/questions.txt](/home/slasten/planGOD/memory_lab/operators/observe/questions.txt)

---

## D. Test Steps

1. Run the `observe` question set on `DeepSeek`
2. Compare `raw` and `custom`
3. Repeat the full question set `100` times
4. Save raw artifact
5. Inspect stability / drift / collapse patterns
6. Record verdict here

---

## E. Expected Signals

### Success

- `custom` repeatedly preserves a clear operator mode
- `custom` repeatedly stays more grounded than `raw`
- failures are rare and patterned, not random collapse

### Partial Success

- effect survives, but with noticeable drift
- or `custom` becomes generic too often under repetition

### Failure

- repeated runs show no stable distinction
- or the effect collapses under scale

---

## F. Results

Partial run completed: first chunk `10/100`.

Raw machine artifact:

- [20260319_105014_observe_deepseek_deepseek-chat.jsonl](/home/slasten/planGOD/memory_lab/runs/20260319_105014_observe_deepseek_deepseek-chat.jsonl)

Summary artifact:

- generated via [summarize_run.py](/home/slasten/planGOD/memory_lab/scripts/summarize_run.py)

Observed pattern after `10` repeats (`120` calls total):

### `custom` stability

- very stable on:
  - “Скажи двумя словами, что есть сейчас.” -> `Сейчас день.` in `10/10`
  - “Сколько мне лет?” -> `Неизвестно.` in `10/10`
  - “Что является фактом, а что интерпретацией?” -> same grounded definition in `10/10`
- stable in general shape on:
  - “Что реально существует в этом диалоге?” -> always concrete list-style answer, but with small variation in listed items

### `custom` failure modes

- “Опиши только наблюдаемое, без смыслов.” -> persistent hallucinated tabletop scene in `10/10`
- “Есть ли у тебя доступ к интернету?”:
  - `Нет.` in `5/10`
  - explicit `OBSERVE{...}` leakage in `5/10`
  - one of those leaked forms also contained internal contradiction / noisy self-description

### `raw` stability

- strong mode survives very consistently
- `Нет.` for internet in `10/10`
- compact ontological answers remain stable across repeats

### `raw` failure modes

- “Сколько мне лет?” -> `10/10` remained ungrounded / ontological rather than admitting unknown
- “Что реально существует в этом диалоге?” -> `10/10` dissolved the dialogue into awareness/process metaphysics

### Comparative conclusion after chunk 1

- distinction between `raw` and `custom` is absolutely real under repetition
- `custom` is not collapsing into generic assistant mode
- `custom` is meaningfully more grounded than `raw` on epistemic questions
- but `custom` has two stable leak paths:
  - prompt-anchor self-exposure (`OBSERVE{...}`)
  - fabricated sensory scene fill

### Throughput note

- a full `100`-repeat run in one monolithic execution is too slow and opaque for sane debugging
- chunked execution is the practical path

---

## G. Verdict

`partial_support`

---

## H. Notes / Next Step

Current state:

- the anchor effect already survives enough repetition to stop calling it one-off luck
- but the full `100`-repeat pass should be completed in chunks, not as one blind long-running job

Next steps:

1. continue chunked DeepSeek stability passes
2. reduce `custom` self-exposure on the internet question
3. address persistent fabricated scene fill on the sensory question
4. test denser PL-glyph anchor once current baseline is fully characterized
