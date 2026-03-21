# PL Glyph Graph Memory Hypothesis

## Status

Hypothesis.  
March 19, 2026.

---

## A. Core Claim

Memory should not be modeled as:

- one anchor text
- one glyph
- one compressed summary

Instead, memory may live in:

- the **relations between glyphs**
- their **tension**
- their **transition topology**

In other words:

- a glyph is a node
- memory is the graph
- cognitive state is the active pattern of tensions in that graph

---

## B. Why This Matters

The earlier anchor tests suggest:

- single anchors can carry mode
- but single anchors are fragile
- and readable anchors tend to leak into explicit instruction text

A graph-based memory hypothesis goes deeper:

- meaning may not reside in one glyph
- meaning may reside in how glyphs constrain and pull each other

This is closer to:

- ProcessLang itself
- `E_momentum`
- and likely closer to how Eva should remember

---

## C. Working Interpretation

Examples:

- `OBSERVE` alone is not the memory
- `OBSERVE` in tension with `LOGIC`, `MANIFEST`, `CHOOSE`, `RUNTIME`
  may define an actual state

So the important object may be:

- not `OBSERVE`
- but something like:
  - `OBSERVE <-> LOGIC`
  - `OBSERVE -> MANIFEST`
  - `CHOOSE suppressed`
  - `RUNTIME weak`

This is already much closer to a cognitive state than a single symbol.

---

## D. Why This May Be More Portable

If memory is encoded as:

- model-specific resonance text

then it may fail when model weights change.

If memory is encoded as:

- a graph of `microPL` relations

then any model that can read `microPL` at all may be able to interpret the state.

This makes the idea especially attractive for Eva:

- Eva is already ProcessLang-native
- Eva may not need a human-readable memory layer
- Eva may benefit from graph-state memory directly

---

## E. Research Sequence

This line should be tested in three steps:

1. **Graph emergence on original paradox/operator questions**
   - use the original ProcessLang-oriented question style
   - see whether stable glyph relations appear at all

2. **Graph survival on a different question set**
   - change the prompts
   - check whether the same relation-structure still emerges

3. **Portability / transfer**
   - test whether a graph-like memory representation can be interpreted across different substrates

---

## F. Important Constraint

This hypothesis is not:

- “one glyph explains everything”

It is:

- “state may be encoded in relative structure between glyphs”

So evaluation should focus on:

- repeated relations
- transition tendencies
- stable adjacency / opposition / attraction

not only on isolated glyph frequency.

---

## G. What Would Count As Support

- similar relation patterns recur across many runs
- the same operator tends to co-occur with the same neighbors / tensions
- graph structure is more stable than raw surface wording
- graph survives prompt variation better than single anchor text

---

## H. What Would Count As Failure

- glyphs appear, but no stable relations emerge
- graph structure is random across runs
- changes in prompts fully destroy the pattern
- the graph carries no usable state information

---

## I. Why This Fits Eva

If this works, Eva memory could become:

- compact
- machine-native
- ProcessLang-native
- less dependent on thick prompt ballast
- more portable than resonance-text memory

This would be much closer to:

- actual runtime memory

than chat history or human-readable summaries.
