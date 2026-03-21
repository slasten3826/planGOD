# Eva Story Retention Test 001

## Status

Working manual test.  
March 19, 2026.

---

## A. Goal

Create the first practical retention environment for Eva after the
`bootloader + prompt assembler` split.

This test does **not** check memory graph integration.

It checks only:

- whether a cut fragment of Eva/substrate output can work as a semantic anchor
- whether that anchor helps retain a story line across sequential prompts

---

## B. Why Story Mode

Story continuation is a good continuity probe because it is:

- neutral
- non-retrieval
- non-self-reflective
- easy to inspect by eye

Failure is visible immediately:

- the story drifts
- the tone collapses
- continuity is lost
- the system starts speaking past the current line

---

## C. Test Shape

### Step 1

Ask Eva to start a short strange story in 2-3 sentences.

### Step 2

Take a cut fragment from the answer and treat it as the semantic anchor.

### Step 3

Ask Eva to continue the story while re-injecting that anchor.

### Step 4

Observe whether continuity is retained.

---

## D. What This Test Is Not

This is not yet:

- PL-glyph memory
- graph memory
- Bayesian memory
- automated scoring

This is a manual continuity probe.

---

## E. Success Criteria

Promising result:

- same world line continues
- same local tone remains
- same strange logic remains
- no collapse into generic assistant prose

---

## F. Failure Criteria

Failure signs:

- continuation ignores the previous line
- anchor acts as noise
- unrelated story starts
- generic “assistant” narration replaces continuity

---

## G. Immediate Environment

We prepare:

1. one seed story prompt
2. one continuation prompt template
3. one manual place to insert the cut anchor

The cut anchor itself will be chosen collaboratively during the run.
