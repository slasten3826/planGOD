# Eva Cut Semantic Anchor Test

## Status

Working test plan.  
March 19, 2026.

---

## A. Purpose

Before testing PL-glyph memory, we first test a simpler and more direct
hypothesis:

- can a **cut fragment of the substrate's own answer** act as a semantic anchor
  for Eva

This is the baseline memory test.

---

## B. What Exactly Is Being Tested

We are **not yet** testing:

- PL-glyph memory
- memory graph integration
- Layer 3 / Bayesian memory

We are testing only this:

- take a fragment of the model's own answer
- feed it back on the next step as a compact semantic anchor
- observe whether it carries line / state / style

---

## C. Core Hypothesis

If a fragment is cut directly from the substrate's own answer and preserved
without rewriting, then it may function as a semantic anchor.

Important:

- this is not yet a proof of robust memory
- this is only a proof-of-effect test

---

## D. Why This Comes Before PL-Glyphs

If the direct cut-anchor does **not** work, then moving to PL-glyph memory is
premature.

If the direct cut-anchor **does** work, then PL-glyph encoding becomes a valid
next step.

So the order is:

1. cut-anchor baseline
2. only then PL-glyph anchor

---

## E. Test Mode

This test should be performed manually and collaboratively.

Reason:

- this is already a behavior / continuity test
- automatic scoring is too weak here
- human observation is needed to detect whether Eva keeps the line or begins to
  drift, mislisten, or talk past the ongoing thread

---

## F. What Counts As Success

The cut semantic anchor is considered promising if, after reinjection:

- Eva keeps the same line of thought
- Eva preserves operator-native style
- Eva does not collapse into generic assistant mode
- Eva does not start speaking about an unrelated subject
- Eva remains epistemically disciplined

---

## G. What Counts As Failure

Failure signs:

- the reinjected fragment behaves like meaningless noise
- Eva ignores the fragment completely
- Eva starts hallucinating from the fragment
- Eva begins to continue the wrong topic
- Eva loses continuity instead of retaining it

---

## H. Immediate Next Step

Run the test interactively, step by step:

1. generate a first answer from Eva
2. choose the cut fragment together
3. inject it as the next-step anchor
4. inspect whether continuity is retained
