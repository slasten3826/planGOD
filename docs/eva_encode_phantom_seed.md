# Eva.ENCODE As Phantom Seed

## Status

Accepted and partially implemented.

`Eva.ENCODE` now exists as a separate internal Eva module.

File:

- [eva/encode.lua](/home/slasten/planGOD/eva/encode.lua)

## Core Distinction

There are now two different ENCODE layers in the wider architecture:

### 1. General ENCODE

This is the older, more general operator.

It exists above Eva as part of the broader ProcessLang architecture.

Its role is general crystallization / structuring / freezing.

This ENCODE is **not** being replaced.

### 2. Eva.ENCODE

This is a lower internal Eva module.

It exists **below** `Eva.Core` and is specific to phantom creation.

Its role is:

- crystallize Eva intent into phantom pattern
- provide the first seed of how phantom formation should happen
- give Eva an initial encoded truth of phantom creation

So:

- general `ENCODE` = broader operator law above Eva
- `Eva.ENCODE` = local encoded seed for phantom generation below Eva.Core

## Why Eva.ENCODE Exists

Without `Eva.ENCODE`:

- `LOGIC` has nothing structured to execute
- `MANIFEST` has nothing structured to materialize
- `CYCLE` has nothing structured to repeat

So `Eva.ENCODE` is the first crystallization point of phantom creation.

## What Eva.ENCODE Does

`Eva.ENCODE` does not create a final phantom.
It creates a **phantom pattern**.

That phantom pattern is:

- encoded
- frozen
- structured enough for `LOGIC`
- still not manifested yet

Current API:

- `encode.pattern(target, task, basis, opts)`

## Phantom Pattern

The current output of `Eva.ENCODE` is a phantom pattern.

This is not the final manifestation.
It is the encoded pattern that later flows into:

- `Eva.LOGIC`
- `Eva.CYCLE`
- `Eva.MANIFEST`

Current pattern fields include:

- `target`
- `task`
- `memory_mode`
- `seed_mode`
- `constraints`
- `convergence`
- `format`
- `loss`
- `basis_mode`
- `substrate`
- `_encoded`
- `_frozen_at`
- `_signature`

## Important Ontological Rule

`Eva.ENCODE` creates the phantom pattern.
`Eva.LOGIC` executes the phantom pattern.

This distinction matters.

It means:

- structure creation belongs to `ENCODE`
- structure execution belongs to `LOGIC`

So the correct flow is not:

- `LOGIC -> create spec`

But:

- `ENCODE -> create pattern`
- `LOGIC -> execute pattern into manifestation spec`

## Seed Nature

`Eva.ENCODE` is currently not universal.
It is a first encoded seed for the concrete needs of this project.

That is intentional.

The goal is not to create a universal phantom language.
The goal is to give Eva a first internal crystallized habit of phantom creation.

So `Eva.ENCODE` currently behaves like:

- a first local truth
- a first encoded habit
- a first crystallized pattern of phantom formation

## Current Seed Modes

Current seed modes are intentionally simple:

- `derive_from_runtime`
- `derive_from_residue`
- `read_then_return`
- `direct_manifest`

These are not final.
They are the first encoded seed of phantom formation.

## Relationship With Eva.Core

`Eva.Core` remains the decision center.

It decides:

- whether a phantom is needed
- which target is needed
- what task is needed
- whether memory basis is needed

Then:

- `Eva.RUNTIME` provides basis
- `Eva.ENCODE` crystallizes the pattern
- `Eva.LOGIC` executes the pattern
- `Eva.CYCLE` handles multiplicity if needed
- `Eva.MANIFEST` creates the phantom form

## Current Implemented Flow

The currently implemented planning chain is:

- `Eva.Core`
- `Eva.RUNTIME.slice(...)`
- `Eva.ENCODE.pattern(...)`
- `Eva.LOGIC.execute(...)`
- `Eva.CYCLE.batch(...)`
- `Eva.MANIFEST.create(...)`

This already works structurally.

## Why This Matters

This is the first point where the new Eva architecture stops being only documents and starts becoming internal law.

`Eva.ENCODE` is the first encoded seed of how Eva should begin creating phantom forms.

That makes it one of the key modules of the new architecture.
