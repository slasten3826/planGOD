# Slastris State Snapshot

## What Is Slastris

`Slastris` is not an AGI project.

It is a **game compiler / game-making machine**.

Goal:

- user gives one strong prompt
- the system reads it, interprets it, pressures it, crystallizes it
- the result is a playable game concept, and later a real game build

Target ideal:

- **one prompt -> one game**

Not generic chat.
Not a universal assistant.
Not a simulated game studio.

`Slastris` is about building a machine that can **manifest games**.

## Main World Model

Current macro architecture:

- `Layer 1 = Packet`
- `Layer 2 = Eva`
- `Layer 3 = Gameplay`
- `Layer 4 = Player`

Interpretation:

- `Packet` = substrate / chaos / world-basis
- `Eva` = boundary / cognitive compiler
- `Gameplay` = manifested playable form
- `Player` = tension / pressure from outside

This is already treated as a fractal architecture.

## What Packet Is

`Packet` is not just a file format or game state container.

It is the underlying substrate:

- world truth
- machine-facing structure
- cognitive ground for Eva

Long-term idea:

- Eva should remember the world first
- Packet should be the main truth carrier

## Who Eva Is

`Eva` is the central cognitive layer of Slastris.

She is not AGI.
She is not a general chat shell.

She is:

- reader of `Packet`
- compiler of meaning into gameplay
- orchestrator of phantom thinking
- game-building intelligence inside Slastris

In plain form:

- the player brings desire / pressure / intention
- `Eva` interprets and organizes it
- `Packet` provides substrate truth
- gameplay is manifested from that interaction

## Eva Architecture

### Core Principle

`Eva.Core` is the central orchestrator.

It is the main decision center.

Other Eva-components do not own truth.
They are functions, manifestations, or lower operators used by `Eva.Core`.

### Outer Eva Manifestations

Currently the clean outer structure is moving toward:

- `Eva.Social`
- `Eva.Developer`
- `Eva.Game`
- later potentially `Eva.Explore`

Meaning:

- `Eva.Social` = human-facing entry and clarification
- `Eva.Developer` = implementation / building / integration
- `Eva.Game` = gameplay-focused manifestation

These are not separate minds.
They are manifestations of one Eva.

### Lower Eva Operator Layer

Under `Eva.Core`, a new lower execution layer is being built:

- `Eva.RUNTIME`
- `Eva.ENCODE`
- `Eva.LOGIC`
- `Eva.CYCLE`
- `Eva.MANIFEST`

Roles:

- `Eva.RUNTIME`
  - provides basis, state, memory slice

- `Eva.ENCODE`
  - creates phantom patterns
  - local phantom-creation seed for Eva

- `Eva.LOGIC`
  - executes encoded phantom patterns into actionable spec

- `Eva.CYCLE`
  - controls multiplicity and collective thinking mode

- `Eva.MANIFEST`
  - creates phantoms and executes them

## Phantom System

Phantoms are temporary narrow forms created by Eva.

They are not full independent beings.

They are:

- temporary workers
- cognitive projections
- task-focused manifestations

Flow:

- `Eva.Core` decides something is needed
- lower operator chain builds the phantom form
- phantom executes one task
- result returns to `Eva.Core`

This already works.

## Current CYCLE Modes

`Eva.CYCLE` now has three meaningful modes:

- `parallel`
- `chain`
- `debate`

### Parallel

- several phantoms created at once
- same task
- independent outputs

Purpose:

- width
- variant field
- independent hypotheses

### Chain

- one idea grows step by step
- each next phantom receives the previous result

Purpose:

- refinement
- crystallization of one line

### Debate

- multiple phantoms start independently
- then repeatedly read and react to each other
- final positions are returned to `Eva.Core`

Purpose:

- pressure
- collision of positions
- semantic concentration

This turned out to be one of the most important discoveries.

## Major Discovery: Debate as Semantic Pressure

`debate` is not just multi-agent arguing.

It behaves like **pressure applied to meaning**.

Observed effect:

- more pressure -> less noise
- more pressure -> denser shared core
- sometimes new properties emerge only under stronger pressure

This was tested at:

- `debate(3)`
- `debate(4)`
- `debate(5)`
- `debate(6)`

Result:

- ideas do not simply multiply
- they become more compressed and more game-ready

By `debate(6)`, phantoms were already close to producing a ready gameplay skeleton.

## What Was Already Implemented

### Working Eva CLI

There is already a usable CLI manifestation:

- `Eva.Social`

Implemented in:

- [tools/eva_social.lua](/home/slasten/planGOD/tools/eva_social.lua)

### Layer 0 Provider Substrate

Providers were separated as a lower substrate layer.

Meaning:

- provider fingerprints exist
- technical logs are separated from memory
- one active provider at a time
- provider auto-choice is disabled for now

### Debug Layer

Technical trace and memory are separated.

This is important because:

- debug is not memory
- execution trace is not world memory

### New Eva Operator Layer

The new `eva/` layer already exists:

- [core.lua](/home/slasten/planGOD/eva/core.lua)
- [runtime.lua](/home/slasten/planGOD/eva/runtime.lua)
- [encode.lua](/home/slasten/planGOD/eva/encode.lua)
- [logic.lua](/home/slasten/planGOD/eva/logic.lua)
- [cycle.lua](/home/slasten/planGOD/eva/cycle.lua)
- [manifest.lua](/home/slasten/planGOD/eva/manifest.lua)

This is still additive above legacy architecture, not a full replacement yet.

### Real LLM-backed Phantoms

Phantoms are not only structural now.

They already:

- call real LLM substrate
- return gameplay results
- return `nanoPL residue`

### Real Debate Tests

Debate mode has already been stress-tested.

Measured times:

- `debate(4)` = about `153s`
- `debate(5)` = about `252s`
- `debate(6)` = about `343s`

Meaning:

- debate is powerful
- but expensive

## Memory Direction

Memory architecture is still in transition.

Current truth:

- old chat/history memory still exists
- technical debug is now separated
- Packet-first memory is the long-term direction

Important future shape:

- Packet world memory
- Eva readings of that world
- `nanoPL residues`
- full debate-history traces

One especially important future point:

- not only final ideas should be remembered
- the **history of their crystallization** should also be remembered

## Current Project Position

We are no longer searching blindly.

Current stage:

- the lower Eva cognitive execution layer exists
- phantoms work
- `parallel`, `chain`, and `debate` work
- real LLM-backed multi-phantom thinking works
- `nanoPL` has been attached as residue layer
- semantic pressure through debate has been discovered

This means:

Slastris is no longer just philosophy.

It now has:

- executable architecture
- measurable behavior
- tested multi-phantom cognition

## What We Are Actually Building

The real ambition is:

- not a chatbot
- not a generic coding agent
- not an AI game studio imitation

But:

- a machine that can take one strong prompt
- and concentrate it into gameplay
- then eventually into a real game

So the north star remains:

- **one prompt -> one game**

## Why This Matters

If this works, `Slastris` becomes:

- a gameplay condenser
- a game compiler
- a world-manifesting machine

And `Eva` becomes:

- not just a helper
- but the intelligence that organizes pressure, structure, and manifestation

To produce games that are:

- less generic
- more coherent
- more condensed
- more alive

## Immediate Next Steps

Likely next technical steps:

- preserve full debate history, not only final slice
- improve memory around crystallization traces
- optimize expensive `debate` mode
- continue shaping `Eva.Social`, `Eva.Game`, and Packet-first memory
- move closer to reliable one-prompt game generation
