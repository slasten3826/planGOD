# Eva Memory Layers 1 + 2 Implementation

## Status

Implementation plan.  
March 19, 2026.

---

## 1. Scope

This document defines the first practical memory implementation for Eva after
the `nanoPL` experiments.

Only two layers are implemented now:

- `Layer 1` — runtime chronology / execution transitions
- `Layer 2` — `nanoPL` residue memory

`Layer 3` is intentionally postponed.

---

## 2. What We Keep

We keep the current Eva fundamentals:

- Lua runtime
- ProcessLang as explicit cognitive scaffold
- bootloader + prompt assembler split
- single-agent Eva for now
- one substrate (`DeepSeek`) as both `encode` and `decode` engine for `nanoPL`

So this is not a new Eva.
It is a cleaner memory core inside the current Eva.

---

## 3. Layer 1

### Meaning

`Layer 1` stores what Eva actually did as execution topology.

This already exists in the current system as:

- `E_momentum`
- `E_edges`

### It should continue to store

- source operator / module
- target operator / module
- domain
- weight
- hits
- chronology through updates and decay

### No redesign now

Layer 1 is already real enough.
We keep it as the execution-memory foundation.

---

## 4. Layer 2

### Meaning

`Layer 2` stores compact cognitive residue in `nanoPL`.

This is not prose summary.
This is not user-facing memory.
This is substrate-facing compact state.

### What gets stored

After a meaningful final Eva answer, we generate:

- one short `nanoPL` residue

and store it with metadata:

- timestamp
- input
- output
- residue
- provider
- model

### Why this is enough for first pass

The experiments showed:

- prose anchors were a bridge
- `nanoPL` is the more native machine form

So Layer 2 should be built around `nanoPL`, not around text snippets.

---

## 5. First Retrieval Rule

The first retrieval strategy should be intentionally simple:

- load recent residues
- inject only a small recent slice into prompt assembly

No semantic search.
No graph reasoning yet.
No Layer 3 selection yet.

This avoids fake sophistication and keeps the system readable.

---

## 6. Prompt Integration

Prompt assembly should include:

- bootloader
- optics
- active lenses
- Layer 1 runtime context
- Layer 2 recent residue context
- provider section

So Eva receives:

- current structural habits
- recent compact cognitive state

without dragging whole prose history.

---

## 7. First Safe Implementation

### A. Load path

During `CONNECT`:

- load Layer 1 runtime memory
- load Layer 2 residue log
- build both contexts

### B. Save path

After final answer:

- ask the same substrate to encode the final answer into one short `nanoPL`
  residue
- append residue entry to storage

### C. Storage

Layer 1:

- existing `runtime/storage/momentum.lua`

Layer 2:

- new `runtime/storage/residues.lua`

---

## 8. Important Constraint

Layer 2 encoding should be:

- short
- deterministic enough
- not prose
- not an essay

One compact residue line is enough for first pass.

---

## 9. What We Are Not Doing Yet

Not now:

- graph persistence
- residue graph retrieval
- trust scoring
- dissolve / promote decisions
- multi-agent Eva
- cross-substrate memory

All of that comes later.

---

## 10. Success Criteria

First implementation is successful if:

1. Eva continues to run normally
2. Layer 1 still loads and updates
3. Layer 2 writes compact `nanoPL` residues
4. Recent residues appear in assembled prompt context
5. The system remains understandable and debuggable

---

## 11. Bottom Line

The first correct memory architecture for current Eva is:

- **Layer 1 = execution habits**
- **Layer 2 = recent `nanoPL` residues**

This is enough to move from:

- prompt-heavy assistant shell

toward:

- real machine memory without overbuilding the system.
