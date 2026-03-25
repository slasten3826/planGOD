# Lens Composition Hypothesis

## Status

Working hypothesis.  
Do not implement yet.

## Core Idea

After extracting usable operator lenses, prompts may be assembled not through a large external orchestration layer, but through direct composition of compiled lenses inside the substrate context.

Rough form:

```text
<lens.flow lens.connect lens.encode> <question / prompt / task>
```

Meaning:

- `lens.flow`
- `lens.connect`
- `lens.encode`
- etc.

act as modular operator activators / cognitive modes,
which are prepended to a task prompt.

The task is then solved inside the composed operator field,
rather than by a neutral default assistant mode.

## Why This Matters

This would approximate the old external architecture,
but move more of it inside the model itself.

So instead of:

- large external coordination
- heavy explanation ballast
- role text and explicit reasoning scaffolding

we would have:

- compiled operator lenses
- composable prompt-level activation
- lighter but more structured in-model manifestation

## Expected Benefit

- more modular prompt assembly
- less external scaffolding
- faster activation of known operator regimes
- easier testing of different operator combinations
- possible direct path toward `Eva.Core` as composition of active lenses

## Main Risk

Lens composition may not be additive.

Possible failure modes:

- one lens suppresses another
- two lenses destabilize each other
- order matters
- some pairs create noise instead of structure
- some triples collapse into a wrong basin
- some operators are compatible only through an external runtime, not a flat prompt composition

So the open question is not only:

- does composition work?

but also:

- which lenses compose cleanly
- in what order
- at what density
- under what task types

## Current Rule

Do not test this yet.

First:

- extract more lenses
- reach a usable set of operator lenses
- understand their individual behavior

Only then:

- start lens-composition experiments
- test pairwise combinations
- test ordering
- test task transfer

## Current Priority

1. Extract lenses.
2. Build operator map.
3. Only after that, test prompt-level composition.
