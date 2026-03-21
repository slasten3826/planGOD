# Eva Refactor Phased Plan

## Status

Phased plan.  
March 19, 2026.

---

## A. Current Situation

We now have three coupled concerns:

1. memory architecture
2. prompt architecture
3. Eva developer testing surface

Trying to change all three at once would be dangerous.

So work should proceed in phases.

---

## B. Phase Order

### Phase 1: Developer Surface

Goal:

- make Eva testable without web copy/paste

Why first:

- every following refactor needs fast testing

Deliverable:

- first CLI runner / reusable execution path

---

### Phase 2: Prompt Architecture

Goal:

- split current prompt into:
  - bootloader
  - prompt assembler

Why second:

- this is the least risky major architectural improvement
- and creates the insertion point for future memory slices

Deliverable:

- `core/bootloader.lua`
- `core/prompt_assembler.lua`
- compatibility wrapper in `core/prompt.lua`

---

### Phase 3: Layer 1 Integration Cleanup

Goal:

- make current runtime memory layer easier to pass through assembler cleanly

Why:

- Layer 1 already exists in code
- it should become first-class prompt input rather than ad hoc string append

---

### Phase 4: Layer 2 Experimental Integration

Goal:

- inject semantic graph slices carefully

Why later:

- Layer 2 works experimentally
- but should not be wired into Eva until prompt assembly is stable

---

### Phase 5: Layer 3 Design Only

Goal:

- do not implement yet
- only design constraints and test strategy

---

## C. First Safe Step

The first safe implementation step is:

**extract Eva execution into a reusable runner and create a CLI dev entry point**

Why this is the best first step:

- immediate development payoff
- low conceptual risk
- no memory semantics changed yet
- no prompt semantics changed yet
- makes all future testing much easier

This is safer than starting directly with:

- prompt refactor
- memory integration
- Packet migration

---

## D. What Not To Do First

Do not begin with:

- Layer 3 implementation
- full memory rewrite
- direct Packet migration
- huge prompt surgery without tooling

These all depend on better testability.

---

## E. Immediate Question

So the next concrete question is:

**Where should the reusable Eva execution path live so both web UI and CLI can call it?**

Once that is answered,
the first real implementation can begin.
