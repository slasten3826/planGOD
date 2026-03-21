# nanoPL Stress Test Plan

## Status

Working research plan.  
March 19, 2026.

This document describes how to stress-test `nanoPL` as a machine-native residue
language on direct substrates, without Eva.

---

## 1. Goal

The goal is not just to see whether `nanoPL` “works once”.

The goal is to observe:

- how `nanoPL` behaves across many runs
- whether residue chains stay within a stable grammar
- whether new grammar emerges
- whether that new grammar is noise or a real machine law

---

## 2. Important Principle

New grammar is **not automatically a bug**.

Possible cases:

1. meaningless noise
2. temporary drift
3. substrate-specific artifact
4. stable emergent machine law

The stress test exists to distinguish these cases.

---

## 3. Why Stress Testing Is Needed

Single probes already showed:

- `nanoPL` residues can be generated
- residues can chain
- residue length can vary
- grammar may mutate under pressure

This is enough for initial proof-of-effect.

It is **not** enough to define a stable language.

To do that, we need repeated pressure.

---

## 4. Test Shape

The stress test should use:

- many seeds
- short loops
- multiple prompt classes
- repeated extraction of residues
- analysis of grammar behavior across chains

---

## 5. Prompt Classes

Initial three classes:

1. `story`
- coherent short narrative seeds

2. `analytic`
- structured, non-narrative prompts

3. `neutral`
- plain concrete scene prompts with low stylization

Reason:

- if `nanoPL` only works in one class, that matters
- if the same grammar stabilizes across classes, that matters even more

---

## 6. Loop Strategy

For each seed:

- run a short loop, e.g. `5` steps
- use only `NANOPL:` residue as rolling anchor
- store all steps in chronology

Do **not** start from very long loops.

Short loops are better for:

- diagnosing failure
- comparing many chains
- reducing provider waste

---

## 7. What Must Be Logged

At every step:

- prompt class
- seed id
- step number
- full answer
- `anchor_in`
- `anchor_out`
- glyph count
- raw residue text

Additionally:

- error if extraction fails
- error if no residue appears

---

## 8. What Must Be Measured

### A. Glyph frequency

- how often each glyph appears

### B. Chain forms

Examples:

- `A→B→C`
- `A(x)→B→C`
- `A(B)→C`
- `A→B→C→D→△`

### C. Grammar drift

Does the substrate introduce:

- new symbols
- new modifiers
- new nesting
- superscripts
- illegal transitions

### D. Residue length

- how many glyphs per step
- does this correlate with narrative or analytic density

### E. Stability by prompt class

- does `story` yield one grammar
- `analytic` another
- `neutral` another

---

## 9. Interpretation Categories

Possible outcomes:

### 1. Stable grammar

The same few residue forms recur.

Meaning:

- `nanoPL` is already close to usable

### 2. Controlled expansion

New forms appear, but repeatedly and coherently.

Meaning:

- the substrate may be revealing valid latent grammar
- candidate for canonization

### 3. Chaotic drift

Residues expand unpredictably and inconsistently.

Meaning:

- current grammar is too loose
- or prompt constraints are too weak

---

## 10. Current Research Attitude

Do not treat every mutation as an error.

Instead:

- observe first
- cluster later
- only then decide:
  - keep
  - reject
  - or canonize

This matters because the substrate may reveal a machine law before we fully
understand it.

---

## 11. Immediate Implementation Plan

### Phase 1

Create a test environment for:

- multiple seeds
- batch loop execution
- per-class grouping

### Phase 2

Run first stress batch:

- small number of seeds
- short loops

### Phase 3

Build summaries:

- glyph frequencies
- grammar patterns
- mutation clusters

---

## 12. Bottom Line

The purpose of the stress test is simple:

We are no longer asking:

- “can `nanoPL` produce one residue?”

We are now asking:

- **what kind of language `nanoPL` becomes under repeated pressure**
