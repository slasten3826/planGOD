# Eva Refactor Inventory

## Status

Working inventory for refactoring Eva toward Packet Adventure support.  
March 19, 2026.

---

## 1. Current Eva Core

Current Eva is still a compact shell built from:

- `FLOW`
- `CONNECT`
- `ENCODE`
- `OBSERVE`
- `LOGIC`
- `RUNTIME`
- `MANIFEST`

The execution path is centered in:

- [eva_runner.lua](/home/slasten/planGOD/core/eva_runner.lua)

---

## 2. What Still Matters

These pieces still match the new goal and should remain:

- Lua as execution substrate
- Packet-style data flow through one packet object
- router/topology discipline
- prompt assembler
- runtime execution memory (`Layer 1`)
- `nanoPL` residue memory (`Layer 2`)
- provider abstraction
- dev runners and suites

---

## 3. What Is Legacy planGOS Weight

These pieces are now mostly legacy presentation or historical scaffolding:

- external `<process>` theater
- explicit “thinking in PL” shown to the user
- noisy service messages like runtime updates
- overly assistant-like self-description
- user-facing `planGOS` ritual instead of engine behavior

These do not need to define product behavior anymore.

---

## 4. New Role of Eva

Eva is no longer best understood as:

- a philosophical ProcessLang assistant shell

Eva is better understood as:

- the user-facing interface layer for Packet Adventure / later Slastris

Its job is:

- accept user intent
- clarify when needed
- coordinate internal cognition
- return useful human output

Not:

- expose its ritualized internal thought format

---

## 5. What Must Stay Internal

These should remain inside the machine:

- ProcessLang scaffolding
- `nanoPL` residues
- runtime edges
- internal state transitions
- debug traces

They are engine internals, not primary user UX.

---

## 6. What Must Stay External

User-visible Eva should expose mainly:

- clarification questions
- work status
- final answers
- development collaboration

So the external layer should become much cleaner.

---

## 7. Immediate Refactor Direction

The first refactor should not rewrite Eva from scratch.

It should:

1. keep Lua
2. keep the routing/memory core
3. reduce user-facing `planGOS` noise
4. move ProcessLang from public ritual to internal scaffold

---

## 8. Bottom Line

The refactor should preserve the machine core and strip the old shell.

The goal is not:

- “destroy ProcessLang Eva”

The goal is:

- **turn ProcessLang Eva into a usable cognitive engine interface**
