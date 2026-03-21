# Memory Hypothesis Test Workflow

## Status

Working research workflow.  
March 19, 2026.

This document fixes the intended way to test memory hypotheses.

The rule is simple:

- one hypothesis
- one document
- one run plan
- one result section

No loose impressions.
No undocumented “seems like”.

---

## 1. Important Constraint: Model-Specificity

The original deepening experiments already suggest an important limitation:

- not every model deepens well
- not every model crystallizes the same way
- not every model is suitable for this kind of memory experiment

Observed direction:

- `llama3.x` worked well enough for the paradox/deepening path
- `qwen` was noticeably worse for that specific goal

This matters because:

- if a memory effect appears on one model and not another,
  that may be a property of the head, not of the idea in general

Therefore every test document must explicitly state:

- which model is used
- whether the test is about memory
- or about a model-specific deepened mode

---

## 2. Another Important Constraint

The earlier work did **not** originally test memory.

It tested creation of a specialized cognitive head:

- `paradox`

That means:

- the existing experiments are not direct proof of memory
- they are proof that recursive deepening can create a strong specialized mode

Memory testing begins only now.

This distinction must stay explicit.

---

## 3. Standard Test Structure

Each experiment should have its own file in `docs/`.

Suggested naming:

- `memory_test_001_...`
- `memory_test_002_...`
- etc.

Each test file should contain these sections:

### A. Hypothesis

- what exactly is being claimed

### B. Why This Test Exists

- what uncertainty this test is meant to resolve

### C. Model / Environment

- exact model
- runtime (`ollama`)
- anchor type
- relevant files

### D. Test Steps

- exact commands
- exact order
- exact inputs/questions

### E. Expected Signals

- what would count as success
- what would count as partial success
- what would count as failure

### F. Results

- what actually happened

### G. Verdict

- `works`
- `partially works`
- `fails`
- `unclear`

### H. Notes / Next Step

- what changed in our understanding
- what should be tested next

---

## 4. Minimal Standard For Results

A completed test document must record:

- whether the hypothesis survived contact with reality
- where the effect was strong
- where it degraded
- whether failure was due to:
  - the anchor
  - the compression
  - the model
  - the prompt structure

This matters because otherwise we will confuse:

- “bad idea”
- with
- “wrong head”

---

## 5. First Research Priorities

The first test series should focus on:

1. `raw` anchor vs `none`
2. `raw` anchor vs `summary`
3. first `custom` compressed anchor
4. only later:
   - `microPL` / glyph variants
   - cross-model degradation

Not yet:

- swarm synchronization
- distributed resonance language
- multiplayer / multi-agent behavior

Those remain secondary until memory itself is proven useful.

---

## 6. Working Principle

We are not trying to prove a theory beautifully.

We are trying to discover:

- what survives
- what breaks
- and what kind of memory is real enough to deserve further work

That means the workflow must be boringly explicit.

---

## 7. Bottom Line

From now on:

- every memory test starts as a hypothesis document
- then gets executed
- then the same document is updated with results and verdict

That is the research loop.
