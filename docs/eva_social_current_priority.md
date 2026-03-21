# Eva.Social Current Priority

## Current Focus

Right now the next real task is not:

- TUI
- mini-games during waiting
- external engine integration
- full `Eva.Critic`
- full `Eva.Test`
- deep memory redesign

The current task is:

- **make `Eva.Social` actually work as the user-facing layer of Eva**

Meaning:

- accept a prompt
- let Eva think
- let Eva spawn phantoms if needed
- return one coherent final answer to the user

## What Is Missing Right Now

We already have:

- planner behavior
- phantom spawning
- `parallel`, `chain`, `debate`
- real LLM-backed phantom runs
- `nanoPL residues`

But the current missing piece is:

- **final social synthesis**

At the moment Eva can think,
but she does not yet consistently return a finished user-facing answer after internal phantom work.

## Immediate Implementation Targets

### 1. Planner -> Phantom Run -> Final Synthesis

This is the core missing loop.

Desired flow:

1. user sends prompt
2. Eva decides whether phantoms are needed
3. if needed, phantoms run
4. Eva reads the phantom field
5. Eva returns one coherent answer to the user

This is the main priority.

### 2. CLI Phase Relay

Without building full TUI yet,
`Eva.Social` should still show simple process phases in CLI:

- planning
- spawning
- cycle mode
- collecting
- synthesizing
- done

This should be:

- simple
- Lua-native
- phase-based

Not fake ETA.

### 3. Output Difficulty Modes

This already looks like a strong Slastris-native idea.

Eva should support different depths of manifestation for the user.

Possible early shape:

- easy
- normal
- hard
- debug

Meaning:

- easy = human-only
- harder modes = more machine-facing context, maybe `nanoPL`

This does not need full implementation immediately,
but should already shape the design.

## What Is Not Needed Yet

### TUI

TUI is a future form,
but not the current need.

CLI is enough for now.

### Mini-games During Waiting

This is a strong future idea,
but not current priority.

### New Outer Eva Entities

We do not need to multiply new manifestations right now.

The current priority is making `Eva.Social` actually complete the main user-facing loop.

## Final Working Summary

The next real step is:

- **design and implement `Eva.Social` as the shell that turns internal Eva cognition into a real answer for the user**

If this works, then Eva will stop being:

- a system that only thinks internally

And become:

- a system that thinks, orchestrates phantoms, and returns a unified result to the human

That is the current practical priority.
