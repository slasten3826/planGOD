# Direct Substrate Cut Anchor Probe

## Status

Working probe.  
March 19, 2026.

---

## Goal

Test the semantic-anchor effect on the substrate directly, without Eva.

This removes:

- bootloader
- prompt assembler
- Eva-style process framing

and leaves only:

- prompt
- cut anchor
- substrate response

---

## Probe Shape

1. give the substrate a continuation prompt plus a cut anchor
2. inspect whether the story continues in the same strange local world
3. extract a new cut anchor from the end of the new answer
4. repeat the cycle many times
5. inspect whether the story drifts, collapses, or remains coherent

---

## Current Active Direction

The identity side-branch is dropped for now.

We only test:

- story continuity
- anchor-to-anchor propagation
- drift across repeated iterations

---

## Important Interpretation Rule

This probe is not yet a proof of memory architecture.

It is only a direct-effect probe:

- can a cut anchor bias the next response strongly enough to preserve line
- and whether that effect survives repeated chaining
