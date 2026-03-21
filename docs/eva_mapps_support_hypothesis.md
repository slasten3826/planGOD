# Eva Mapps Support Hypothesis

## Status

Working architecture note.  
March 19, 2026.

This document records a naming and architecture decision:

- external AI-oriented tools should be treated as **mapps**
- `mapps` = **machine apps**

This is not a hype term.
It is a practical framing.

---

## 1. What A Mapp Is

A `mapp` is:

- an application for a machine

In the same sense that a human uses:

- a browser
- a terminal
- an editor
- a media player

a machine can use:

- a UI/UX generation skill
- a Godot bridge
- an MCP integration
- an audit helper
- a code analysis tool
- a domain-specific reasoning pack

This framing is useful because it removes unnecessary mystification.

These are not magical autonomous beings.
They are machine-side applications.

---

## 2. Why Eva Needs Mapps

Eva should not try to contain every capability inside her own core.

That would make her:

- bloated
- noisy
- harder to debug
- less modular

Instead, Eva should become:

- a ProcessLang-native orchestrator
- with the ability to call, coordinate, and evaluate external mapps

This is especially important for the future `Slastris` workflow.

Game creation will likely need machine-side applications for:

- UI/UX design
- Godot integration
- MCP tool bridges
- code generation/refinement
- audits
- content structuring
- asset or pipeline helpers

---

## 3. Architectural Principle

Mapps must not become Eva's truth source.

They should be:

- tools
- specialists
- disposable organs

Eva should remain responsible for:

- orchestration
- choosing which mapp is appropriate
- integrating results
- keeping ProcessLang / Packet / Slastris truth boundaries

This means:

- mapps are not the core
- mapps are not memory
- mapps are not world truth

They are applications used by the machine.

---

## 4. Why This Matters For Slastris

`Slastris` is not just a game.
It is becoming:

- PacketSubstrate
- PL PacketLayer
- Eva as orchestrator
- and later external machine applications around that stack

If Eva cannot use mapps,
then every external capability becomes:

- manual glue
- human bottleneck
- context duplication

If Eva can use mapps,
then she becomes much closer to:

- a real development orchestrator for the engine and the game

---

## 5. Example Classes Of Mapps

Potential future mapp classes:

- UI/UX mapps
- Godot / engine bridge mapps
- MCP adapter mapps
- code audit mapps
- design-system mapps
- documentation mapps
- world-analysis mapps
- asset formatting / conversion mapps

Not all of these should be built by us.
Many may simply be adopted and wrapped.

---

## 6. Important Constraint

Support for mapps should not become:

- uncontrolled plugin sprawl
- random external dependency soup
- a replacement for Packet / ProcessLang truth

Eva needs:

- a disciplined mapp boundary
- not an everything-bagel of AI tools

---

## 7. Working Hypothesis

Eva should eventually support mapps as a first-class concept.

That means:

- she should know what mapps exist
- what they are for
- when to call them
- and how to interpret their results without surrendering control

This is likely a necessary step if Eva is to help create games,
not only think about them.

---

## 8. Bottom Line

`mapps` is a good name.

It captures the right reality:

- these are applications for machines

And Eva will likely need explicit support for them
if she is to become a serious orchestrator in the `Slastris` stack.
