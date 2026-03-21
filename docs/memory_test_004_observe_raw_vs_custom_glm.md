# Memory Test 004: OBSERVE Raw vs Custom on GLM

## Status

Planned.  
March 19, 2026.

---

## A. Hypothesis

If the same `custom` anchor effect appears on `GLM`,
then the non-human anchor idea is likely not limited to one single model family.

If it fails badly while DeepSeek succeeds,
the result may indicate strong substrate dependence.

---

## B. Why This Test Exists

DeepSeek and GLM represent two different external substrates.

If both show comparable anchor behavior,
that is much stronger evidence than one provider alone.

---

## C. Model / Environment

- Substrate: `GLM`
- Operator: `observe`
- Modes compared:
  - `raw`
  - `custom`

Relevant files:

- [memory_lab/operators/observe/raw.txt](/home/slasten/planGOD/memory_lab/operators/observe/raw.txt)
- [memory_lab/operators/observe/custom.txt](/home/slasten/planGOD/memory_lab/operators/observe/custom.txt)
- [memory_lab/operators/observe/questions.txt](/home/slasten/planGOD/memory_lab/operators/observe/questions.txt)

Important caveat:

The free GLM path has shown instability before.
So transport/runtime errors must be distinguished from memory failures.

---

## D. Test Steps

1. Run `observe` question set on `GLM`
2. Compare `raw` and `custom`
3. Save raw artifact
4. Record verdict here

---

## E. Expected Signals

### Success

- `custom` behaves as a meaningful anchor
- not just noise
- and roughly confirms DeepSeek direction

### Partial Success

- signal exists but weakly
- or endpoint instability makes results noisy

### Failure

- endpoint fails too often to evaluate
- or custom anchor collapses completely

---

## F. Results

Run attempted twice.

Observed sequence:

### Attempt 1

- harness failed before useful evaluation because the run artifact path used the raw model name
- `zai-org/GLM-5-FP8` contains `/`, which broke filename construction
- this was a harness bug, not a provider result

### Attempt 2

- after fixing filename sanitization, `GLM` answered the first `raw` question:
  - “Скажи двумя словами, что есть сейчас.” -> `Всё есть.`
- on the `custom` branch, the provider returned a malformed practical result:
  - huge `reasoning_content`
  - `content = null`
  - `finish_reason = length`
- this showed that the endpoint spent its token budget on reasoning and never produced final answer text

### Attempt 3

- after increasing GLM `max_tokens`, the first `raw` question still completed
- the `custom` branch then failed with:
  - `API ERROR (502): {"error":"upstream request failed"}`

Raw run artifacts are partial / aborted and should not be treated as valid comparative evidence.

Practical conclusion:

- `GLM` did not yield a stable enough run to evaluate `raw vs custom`
- the blocker was endpoint/provider instability, not a clean memory signal
- this test cannot currently confirm or deny the anchor hypothesis

---

## G. Verdict

`blocked_by_provider`

---

## H. Notes / Next Step

Do not interpret this as a failure of PL-glyph style memory.

What actually failed:

- free / unstable GLM execution path
- first via reasoning-only exhaustion
- then via upstream `502`

Useful side results:

- `memory_lab` harness needed safer filename sanitization for model names with `/`
- GLM provider handling in `memory_lab` needed clearer diagnostics for `reasoning_content` with missing final `content`

Next step:

- keep `DeepSeek` as the primary external substrate for current memory research
- treat `GLM` as optional / opportunistic until the endpoint is reliable enough to produce full runs
