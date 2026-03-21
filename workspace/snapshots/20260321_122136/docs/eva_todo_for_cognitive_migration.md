# Eva TODO For Cognitive Migration

## Status

Working engineering TODO.  
March 18, 2026.

This document is not a philosophy note.
It is a practical list of what should be strengthened in Eva
before or during her use as a ProcessLang truth source
for the cognitive-engine migration.

---

## Main goal

Eva should evolve from:

- a DeepSeek-bound ProcessLang agent

into:

- a modular ProcessLang orchestrator
- a reliable semantic truth source for the cognitive layer
- a usable development agent for the current PSP game path

This does **not** mean:

- rewriting Eva from scratch
- replacing Packet runtime with Lua
- turning Eva into the whole game

It means:

- strengthen Eva where she is already architecturally close
- remove avoidable rigidity
- prepare her to assist Packet / cognitive-engine development

---

## Priority 1: LLM Provider Abstraction

### Why

Current Eva is tightly bound to DeepSeek:

- [core/llm.lua](/home/slasten/planGOD/core/llm.lua)

That makes the whole system unnecessarily narrow.

Eva should sit above providers, not inside one provider.

### What to do

- turn `core/llm.lua` into a facade
- add provider modules, for example:
  - `llm/deepseek.lua`
  - `llm/glm.lua`
- define one narrow provider contract:

```lua
ask(messages, options) -> content | nil, error
```

- select provider via env/config
- allow a default provider plus fallback provider

### Phase-A target

- DeepSeek works exactly as before
- GLM-5 can be selected without touching higher modules

---

## Priority 2: Memory Architecture Cleanup

### Why

Eva already has a strong memory idea:

- `E_momentum`
- `E_edges`
- memory as habits / transition inertia

This is good.

The weaker part is the persistence/plumbing layer:

- [modules/runtime/storage.lua](/home/slasten/planGOD/modules/runtime/storage.lua)

Memory concept is ahead of memory implementation.

### What to do

- separate clearly:
  - runtime memory model
  - persistence format
  - session history
- decide what each layer is for:
  - `history.json` = dialogue archive
  - `E_momentum/E_edges` = process memory
- reduce custom storage complexity where possible
- document current invariants before refactoring

### Phase-A target

- no semantic redesign yet
- only cleanup of boundaries and responsibilities

---

## Priority 3: Driver Layer Expansion

### Why

Eva already has the shape of an agent,
but her practical agency is still narrow because the driver layer is small.

Current drivers are useful, but limited:

- text
- markdown
- fs
- web
- port
- optional midi

### What to do

- document current driver contract clearly
- define which new drivers actually matter for development work
- likely candidates:
  - structured HTTP/JSON tool driver
  - process runner wrapper with very narrow permissions
  - git/status read-only helper
  - file diff / patch helper

### Constraint

Do not destroy the current safety posture just to feel more “agentic”.

Safety is part of Eva's value.

---

## Priority 4: Packet-Aware External Role

### Why

Eva is useful to the project only if her ProcessLang truth
can be aimed at the real Packet / PSP game path.

### What to do

- define how Eva should read Packet truth:
  - docs
  - reports
  - selected runtime outputs
  - later maybe structured bridge
- define what Eva is allowed to answer about Packet:
  - operator semantics
  - pressure laws
  - stakes
  - first gameplay calculus
- define what Eva is **not** the authority on:
  - substrate truth
  - PSP performance truth
  - low-level runtime correctness

### Phase-A target

Eva becomes a useful ProcessLang interpreter for Packet,
without pretending to own Packet runtime truth.

---

## Priority 5: Cognitive-Engine Task Mode

### Why

Right now Eva is mostly a ProcessLang-native chat agent.

To help the project materially,
she needs a more explicit mode for development tasks.

### What to do

- define a task-oriented protocol for Eva
- make outputs narrower and more implementation-friendly
- examples:
  - architecture proposal
  - operator law extraction
  - calibration note
  - runtime/shell separation note
  - hostile-pressure proposal

### Phase-A target

Eva should be able to act less like:

- a reflective explainer

and more like:

- a ProcessLang development worker

for narrowly framed tasks.

---

## Priority 6: Optics Strategy

### Why

Eva currently loads all optics and can reason through many domains.

That is powerful, but noisy.

For the game / cognitive-engine path,
a narrower active-lens strategy is likely better.

### What to do

- define a first active subset of optics for the game path
- likely starting candidates:
  - `agency`
  - `psychology`
  - `psychopathology`
  - `pedagogy`
  - `biology`
  - `code`
- decide whether all optics should always load,
  or whether lens activation should become explicit

### Phase-A target

Reduce semantic noise.
Keep only the lenses that sharpen gameplay/cognitive questions.

---

## Priority 7: Safety Preservation

### Why

Eva’s security posture is one of her strongest foundations.

This should not be casually destroyed while adding providers or drivers.

Important files:

- [modules/logic/guard.lua](/home/slasten/planGOD/modules/logic/guard.lua)
- [modules/logic/env.lua](/home/slasten/planGOD/modules/logic/env.lua)

### What to do

- keep safety as explicit design value
- document trust boundaries
- document what drivers can mutate and what they cannot
- do not add broad shell access casually
- do not make provider abstraction implicitly widen execution privileges

### Phase-A target

More modular Eva, same or better safety posture.

---

## First Suggested Order

1. LLM provider abstraction
2. Memory boundary assessment
3. Driver strategy note
4. Packet-aware role note
5. Cognitive-engine task mode
6. Optics narrowing strategy

---

## Working conclusion

Eva does not need a rewrite.

Eva needs:

- modularization
- boundary cleanup
- stronger task focus
- explicit positioning relative to Packet

If this is done well,
Eva can become:

- a real ProcessLang truth source
- a real development agent
- and a meaningful participant in the cognitive-engine migration.

