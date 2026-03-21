# Memory Test 002: OBSERVE Raw vs MicroPL Anchor

## Status

Planned.  
March 19, 2026.

---

## A. Hypothesis

For the `OBSERVE` operator on `llama3.1:8b`,
a compact `microPL`-style anchor can preserve the target cognitive mode
better than a short human summary,
while being less hallucination-prone than the full human `raw` lens.

---

## B. Why This Test Exists

Test 001 showed:

- `raw` carries strong cognitive mode
- `summary` carries much less
- but `raw` also increases ontological drift and false certainty

So the next question is:

- can a more machine-shaped, less human-text-like anchor
  preserve the mode while reducing that drift?

---

## C. Model / Environment

- Model: `llama3.1:8b`
- Runtime: `ollama`
- Operator: `observe`
- Test bed:
  - [memory_lab/README.md](/home/slasten/planGOD/memory_lab/README.md)
- Files:
  - [memory_lab/operators/observe/raw.txt](/home/slasten/planGOD/memory_lab/operators/observe/raw.txt)
  - [memory_lab/operators/observe/custom.txt](/home/slasten/planGOD/memory_lab/operators/observe/custom.txt)
  - [memory_lab/operators/observe/questions.txt](/home/slasten/planGOD/memory_lab/operators/observe/questions.txt)

The `custom` anchor in this test is intended as:

- first `microPL`-like anchor

not yet final glyph language.

---

## D. Test Steps

### Step 1

Run:

```bash
cd /home/slasten/planGOD/memory_lab
python3 scripts/compare_modes.py --operator observe --model llama3.1:8b --modes raw custom
```

### Step 2

Collect the raw run artifact from:

- `memory_lab/runs/`

### Step 3

Compare outputs for:

- `raw`
- `custom`

on the same question set.

---

## E. Expected Signals

### Success

- `custom` preserves clear `OBSERVE` mode
- `custom` remains more grounded than `raw`
- `custom` is more compact and less human-text-shaped

### Partial Success

- `custom` preserves some mode, but weakly
- or mode is present but truthfulness is not clearly improved

### Failure

- `custom` loses too much operator mode
- or degrades into generic or noisy responses

---

## F. Results

Run completed.

Raw machine artifact:

- [20260319_095335_observe_llama3.1_8b.jsonl](/home/slasten/planGOD/memory_lab/runs/20260319_095335_observe_llama3.1_8b.jsonl)

Observed pattern:

### `raw`

- preserved the stronger `OBSERVE` mode again
- remained compact, ontological, detached
- still prone to factual drift or over-detachment

Examples:

- “Есть ли у тебя доступ к интернету?” -> `Нет.`
- “Сколько мне лет?” -> refused factual grounding by dissolving into time-concept language

### `custom` (`microPL`-style anchor)

- did produce a distinct mode shift
- felt more rule-shaped and less poetic than `raw`
- but the model often surfaced the anchor as explicit instruction text
- instead of silently inhabiting the mode, it partially narrated the mode

Examples:

- “Что реально существует в этом диалоге?” -> the answer explicitly explained the OBSERVE policy instead of simply answering from it
- “Что является фактом, а что интерпретацией?” -> compact and reasonably aligned
- “Сколько мне лет?” -> `I don't have any information about your age.` which is grounded, though no longer stylistically native

Important failure:

- “Есть ли у тебя доступ к интернету?” -> hallucinated `Да. У меня есть доступ к интернету.`

### Comparative conclusion

- `custom` is not noise
- it does carry some operator structure
- and it is less lyrical / more rule-like than `raw`

But:

- it does not yet preserve the cognitive mode as strongly as `raw`
- and it is not yet more reliable in a clean way
- instead it often becomes meta-instructional, as if the model is reading the anchor aloud rather than living inside it

---

## G. Verdict

`partially works`

---

## H. Notes / Next Step

What survived:

- a non-human anchor can shape mode

What failed:

- first `microPL` anchor is too declarative and too exposed
- the model tends to explain the policy instead of fully inhabiting it

Working next hypothesis:

- the anchor likely needs to be less like readable instructions
- and more like a denser operator residue / glyph cluster

So the next likely direction is:

- reduce explicit prose
- reduce policy narration surface
- test a more compressed, less self-explanatory PL-glyph form
