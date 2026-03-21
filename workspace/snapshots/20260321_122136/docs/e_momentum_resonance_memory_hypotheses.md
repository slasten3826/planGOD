# E_momentum Resonance Memory Hypotheses

## Status

Working hypothesis note.  
March 18, 2026.

This document records a line of thought that emerged during Eva debugging:

- `history.json` is too heavy and too literal
- naive edge memory is too weak and too shallow
- a more powerful form of memory may exist as a compact semantic resonance anchor

This is not yet implementation guidance.
It is a hypothesis map.

---

## 1. The Core Problem

Eva needs memory that:

- takes very little prompt space
- carries a large amount of semantic state
- stabilizes reasoning style
- does not require replaying long chat history

Ordinary chat history fails this.

It stores too much text and too little distilled cognition.

---

## 2. The Deepening Observation

The local `llama3.1:8b` deepening experiments suggest a specific effect:

- a model can repeatedly deepen one paradox
- each iteration sees only a short tail of the previous answer
- after many iterations, the output crystallizes into a very short final lens-like text
- that short text can then reactivate a much larger semantic mode in the same model

Relevant files:

- [llama3.1_8b_OBSERVE/OBSERVE.txt](/home/slasten/deepening/llama3.1_8b_OBSERVE/OBSERVE.txt)
- [llama3.1_8b_OBSERVE/lens_raw.txt](/home/slasten/deepening/llama3.1_8b_OBSERVE/lens_raw.txt)
- [llama3.1_8b_OBSERVE/lens_observe.py](/home/slasten/deepening/llama3.1_8b_OBSERVE/lens_observe.py)

This suggests a form of memory that is:

- not fact memory
- not retrieval memory
- but mode-of-cognition memory

---

## 3. First Hypothesis

`E_momentum` should not primarily store:

- dialogue history
- raw response archives
- low-information operator edge counts

It should instead store:

- compact anchors of validated reasoning modes

Very roughly:

- not “what was said”
- but “what stable mode of thought was successfully reached”

---

## 4. Important Constraint

This resonance effect appears to be strongly model-specific.

That means:

- an anchor grown inside one exact model may be meaningful there
- the same anchor may become noise or hallucination bait in another model

Therefore:

- model-specific resonance memory is powerful
- but not automatically portable

This makes it dangerous as universal orchestrator memory.

---

## 5. Two-Layer Memory View

The current best framing is:

### Layer A: substrate-specific resonance memory

For one exact model / one exact head:

- tiny
- strong
- highly compressed
- potentially reactivates a large semantic state

Good for:

- local fixed models
- repeated deepening
- long-term personal memory of one head

### Layer B: substrate-agnostic policy memory

Portable across models:

- short behavioral rules
- task-class policies
- explicit preferred strategies

Good for:

- orchestration
- multi-provider Eva
- commercial API drift

---

## 6. Why Plain Hash Is Not Enough

A cryptographic hash by itself is:

- good as commitment
- good as integrity mark
- good as lookup key

But by itself it does not guarantee recoverable semantic reactivation.

Still, there is a separate hypothesis:

- if the compressed signature is derived from the model’s own crystallized text,
- the model may treat that signature not as random noise,
- but as a resonance trigger

This remains unproven.

It should be treated as an experimental hypothesis, not as fact.

---

## 7. Stronger Direction Than Plain Hash

A more promising direction may be:

- not raw cryptographic hash
- but compact ProcessLang-style operator sigils

Why:

- less meaningless randomness
- more structural alignment with machine cognition
- still compact
- still relatively opaque to humans

This would make memory less like:

- a blind fingerprint

and more like:

- a compact operator-key for a cognitive state

---

## 8. Working Research Questions

1. Can one model reactivate a large semantic state from a very short anchor?
2. Does this work only with raw final text, or also with compressed symbolic encodings?
3. Does a cryptographic hash preserve enough structure to trigger the same state?
4. Are ProcessLang-style sigils better than hashes for compact resonance?
5. Can such anchors be made stable enough for real use?

---

## 9. Current Engineering Position

For Eva right now:

- do not replace working memory with speculative resonance memory
- keep this as a research track
- treat it as a possible future answer to the “small context, large semantic carry” problem

This is promising precisely because it addresses the real need:

- memory that is tiny
- but not dumb

---

## 10. Bottom Line

The strongest current hypothesis is:

`E_momentum` may ultimately need to become a form of compressed cognitive-state memory,
not history memory.

That memory may be:

- model-specific at the deepest layer
- and ProcessLang-coded at a more portable layer

This is not solved.
But it is a serious direction.
