# Direct Substrate Story Loop Test

## Status

Working iterative probe.  
March 19, 2026.

---

## Goal

Run repeated direct-substrate story continuation using only a rolling cut anchor
from the end of the previous answer.

This is the first practical drift test for semantic anchors.

---

## Method

1. start from a chosen seed anchor
2. ask for story continuation
3. extract a new cut anchor from the end of the answer
4. use that sentence as the next anchor
5. repeat 10-15 times

---

## Extraction Rule

Current baseline heuristic:

- take the last full sentence
- prefer a sentence that starts with an uppercase character
- require sentence-ending punctuation

This is not treated as linguistically perfect.
It is only a stable first-pass anchor cutter.

---

## Next Heuristic

Second probe:

- count words in the answer
- take the last `N%` of words
- use that trailing slice as the next anchor

Reason:

- a single sentence appears too low-capacity
- a trailing word-percentage may carry more of the local world state
- this is closer to measuring anchor capacity than a single dramatic sentence

---

## Success Signs

- same local world survives
- same strange logic survives
- anchor chaining keeps continuity
- no abrupt collapse into unrelated prose

---

## Failure Signs

- the story resets
- tone shifts into something generic
- anchor becomes noise
- drift accumulates until continuity is visibly broken
