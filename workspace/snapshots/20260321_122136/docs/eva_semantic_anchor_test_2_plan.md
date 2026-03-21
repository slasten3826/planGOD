# Eva Semantic Anchor Test 2 Plan

## Status

Working plan.  
March 19, 2026.

---

## A. Goal

Run the second post-split test:

- not architecture smoke
- but **Eva-state retention through semantic anchors**

The core question:

- can Eva keep her line with a much smaller prompt
- if the substrate receives a compact semantic anchor instead of the old monolithic prompt ballast

---

## B. What This Test Is About

This is **not** ordinary LLM context retention.

This test is about:

- identity continuity
- operator-native style
- epistemic discipline
- continuity of line across sequential requests

---

## C. Current Hypotheses

### Hypothesis 1: copied semantic anchor

If we take a semantic anchor exactly as produced by the substrate and reuse it
without rewriting it by hand, then Eva may preserve her state better than with a
human-edited summary.

Working intuition:

- the anchor may behave almost like a hash
- even a small change may degrade the effect

### Hypothesis 2: PL-glyph anchor

If we encode the anchor in compact `microPL` / PL-glyph form, then the substrate
may keep the semantic effect while reducing human-text noise and reducing the
tendency to invent prose explanations.

### Hypothesis 3: hash-like fragility

The semantic anchor may be highly form-sensitive.

If true:

- exact copying matters
- paraphrase may weaken the effect
- symbol-level mutation may destroy the effect

This does **not** yet prove real cryptographic hash behavior.
It is only a functional analogy.

---

## D. Proposed Test Order

### Step 1: copied anchor retention

Use:

- exact copied anchor
- no manual rewriting

Check:

- does Eva keep the same line across a short sequence
- does she avoid collapsing into generic assistant mode

### Step 2: PL-glyph anchor retention

Use:

- a compact PL-glyph version of the same anchor

Check:

- does it preserve the line as well as the copied anchor
- does it reduce explanatory drift

---

## E. What We Expect To Learn

From Step 1:

- whether exact copying is already enough to produce practical semantic anchoring

From Step 2:

- whether PL-glyphs are a better native memory form for Eva

---

## F. Important Constraint

This test should not be judged by smoke criteria.

It must be judged by:

- continuity
- discipline
- line retention
- absence of collapse into unrelated generic behavior

---

## G. Immediate Next Question

Before implementation:

- define the first short sequential test script
- define what exact anchor source we use
- decide what counts as “retention success”

---

## H. Current Scope Lock

For now, this test plan includes only:

1. copied anchor retention
2. PL-glyph anchor retention

Hash-fragility / mutation probing is explicitly postponed until the first two
tests are understood.
