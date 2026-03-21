# Request: Slastris Operator Parameter Categories (First Draft)

## Context

We are building a game engine / game stack that is increasingly taking shape as:

- `Slastris` — whole engine/system
- `PacketSubstrate` — lower world/process layer
- `PL PacketLayer` — upper cognitive / ProcessLang-derived layer

The current question is not about final balance,
not about UI,
and not about a 100-stat spreadsheet.

It is about the **first meaningful category layer**
for operator-native game parameters.

---

## Hypothesis

The game should not begin from traditional genre stats like:

- HP
- mana
- attack
- defense

At least not at first.

Those may emerge later from deeper rules.

Instead, we suspect that gameplay-relevant parameters should first be defined
as **operator-native categories** tied to the 10 ProcessLang operators.

Not 100 concrete parameters yet.
Not a complete system yet.

Only the first category draft.

---

## Key idea

Each operator should correspond to a meaningful class of participation in the game world.

Example direction only:

- `FLOW` may relate to movement continuity / natural ongoing motion
- `CONNECT` may relate to pathing / linkage / ability to connect available states
- `OBSERVE` may relate to how many possibilities a сущность can actually perceive
- `CHOOSE` may relate to decisiveness / active selection of one path over others

Important:

These are **not** meant only for enemies.

The same operator-category system should ideally apply to:

- player entities
- hostile entities
- neutral entities
- objects
- world-generation tendencies
- maybe even environmental behavior

This is why the categories must be meaning-bearing, not just “AI sliders”.

---

## Strong constraints

1. Do **not** jump to 100 fully specified stats.
2. Do **not** force `HP` / `PU` / similar top-level numbers yet.
3. Assume those higher-level resources should emerge later from deeper rules.
4. Think in terms of **categories of world participation**, not genre clichés.
5. The result should be useful for:
   - behavior
   - objectness
   - generation
   - world participation

---

## What is needed from you

Please produce a **first draft list** of operator-parameter categories.

For each of the 10 operators:

1. give the proposed category name
2. explain in 1-3 sentences what kind of game participation it governs
3. say how low vs high values would roughly manifest
4. briefly note how it could apply across:
   - agent
   - object
   - world generation

Keep it first-pass and structural.
Do not over-design.

---

## Output target

We want a document that is:

- narrow
- thoughtful
- structural
- useful as the first design foothold

Not the final stat system.
Not balance.
Not formulas.

Only the first serious draft of **10 operator-native parameter categories for Slastris**.
