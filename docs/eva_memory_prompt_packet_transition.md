# Eva Memory / Prompt / Packet Transition Note

## Status

Working architecture note.  
March 19, 2026.

---

## A. Why This Note Exists

Several lines of work have now converged:

- Eva memory research
- `prompt.lua` overload
- ProcessLang-native semantic graph experiments
- Packet as the deeper architectural destination

At this point, these should no longer be treated as isolated ideas.

They form one architectural problem.

---

## B. Current Reality

### 1. Eva memory does not work yet as real memory

What exists:

- `history.json` archive
- `E_momentum`
- `E_edges`

What is true:

- `history.json` is too literal and too heavy
- `E_momentum` currently captures execution transition habits, not full cognition
- semantic memory is only now being experimentally extracted

So current Eva memory is not yet an actual cognitive memory stack.

---

### 2. `prompt.lua` is too monolithic

Current [prompt.lua](/home/slasten/planGOD/core/prompt.lua):

- is still a large static base prompt
- useful as a policy scaffold
- but too heavy as a long-term architectural form

This becomes more serious because future Eva memory should not be injected as:

- more and more prose appended to one sacred prompt

That would recreate prompt ballast and eventually destroy the point of compact memory.

---

### 3. Eva is starting to want Packet-native architecture

Not fully yet,
but the direction is becoming clear:

- prompt should become assembled state
- memory should become layered graph/state
- ProcessLang should become native structure rather than descriptive prose

This already feels closer to Packet than to ordinary prompt engineering.

---

## C. What Has Been Confirmed So Far

### Layer 1 exists

Eva already has an execution-memory layer:

- `E_momentum`
- `E_edges`
- scheduler-driven transition capture

Relevant files:

- [modules/runtime/runtime.lua](/home/slasten/planGOD/modules/runtime/runtime.lua)
- [modules/runtime/momentum.lua](/home/slasten/planGOD/modules/runtime/momentum.lua)
- [modules/runtime/edges.lua](/home/slasten/planGOD/modules/runtime/edges.lua)
- [modules/observe/scheduler.lua](/home/slasten/planGOD/modules/observe/scheduler.lua)

This layer is:

- runtime/execution memory
- transition topology
- habit pressure

---

### Layer 2 now also exists as a serious signal

The glyph-graph test showed that semantic relation graphs can appear repeatedly.

This layer is:

- semantic/glyph memory
- operator tension topology
- not constrained by scheduler legality

Relevant document:

- [memory_test_007_glyph_graph_on_paradox_questions.md](/home/slasten/planGOD/docs/memory_test_007_glyph_graph_on_paradox_questions.md)

So Eva memory is no longer theoretical at the two-layer level.
The main open problem is how to integrate those layers sanely.

---

## D. Three-Layer Memory Direction

Current best hypothesis:

### Layer 1

- runtime / execution graph

### Layer 2

- semantic / glyph-tension graph

### Layer 3

- Bayesian trust / judgment layer

Important constraint:

- Layer 3 should **not** be implemented yet
- it is too close to self-governance
- and therefore too risky to improvise

So practical focus should remain on:

- Layer 1
- Layer 2
- and their overlay representation

---

## E. What Must Happen To `prompt.lua`

`prompt.lua` should probably stop being:

- one large static source of truth

and gradually become:

- a prompt assembler

Meaning:

- stable minimal core
- active task frame
- active lenses
- selected memory state
- provider-specific shaping

Not everything every time.

This matters because future Eva memory must be inserted into context as:

- compact state fragments
- graph summaries
- selected trusted edges

not as ever-growing prose.

---

## F. Why This Looks Like A Packet Transition

This is not yet a full migration.

But the shape is becoming obvious:

- static prompt text is losing centrality
- graph/state is gaining centrality
- ProcessLang operators are becoming structural units
- memory is becoming layered machine-readable state

This is no longer ordinary agent prompt tuning.
It is starting to become:

- Packet-like state architecture

So yes:

- thinking about memory and prompt together now does begin to look like the beginning of moving Eva onto Packet logic

---

## G. Immediate Safe Direction

Do **not**:

- implement Layer 3
- rewrite all Eva memory now
- replace `prompt.lua` blindly

Do:

1. consolidate memory hypotheses
2. define unified Layer 1 / Layer 2 edge representation
3. define overlay format
4. define how that overlay would be exposed to prompt assembly
5. only then design a minimal prompt assembler refactor

---

## H. Practical Next Question

The most immediate next architectural question is:

**How should Layer 1 and Layer 2 be overlaid in one unified edge/state representation
without breaking current Eva architecture?**

That is the bridge between:

- current Eva
- future memory
- and Packet transition

---

## I. Bottom Line

The current situation is this:

- memory research is no longer isolated
- prompt architecture is now implicated
- Eva is beginning to outgrow static prompt-centric design

So yes:

the next phase is no longer just “improve memory”.

It is:

- decide how Eva moves from
  - prompt-heavy agent form
  toward
  - Packet-like layered state form

That should now be treated as the real architecture problem.
