# Eva Lower Triangle: RUNTIME, LOGIC, CYCLE, MANIFEST

## Status

Accepted architectural direction.

This document defines the lower execution triangle of Eva under the new architecture.

It is not the full Eva.
It is the execution and manifestation foundation under `Eva.Core`.

## First Rule

`Eva.Core` is the only true center of decision.

That means:

- `Eva.Core` decides
- operators do not decide on their own
- operators are execution instruments of Eva.Core

So:

- `LOGIC` does not decide
- `RUNTIME` does not decide
- `CYCLE` does not decide
- `MANIFEST` does not decide

They only shape the will of `Eva.Core`.

## Lower Triangle Roles

The lower triangle is:

- `RUNTIME`
- `LOGIC`
- `CYCLE`
- `MANIFEST`

These are the execution foundation of Eva.

## RUNTIME

`RUNTIME` is the stable basis.

It is responsible for:

- stable state
- memory slice delivery
- habits / residues / inertia
- snapshots
- later rollback / restore if needed

`RUNTIME` does not decide what to do.
It provides the state foundation that other operators may use.

New reading:

- `RUNTIME` = subconscious basis / stable packet of continuity

Inside the new Eva architecture, `RUNTIME` should become the source of:

- memory slice for phantoms
- stable context package
- execution basis for repeated manifestation

## LOGIC

`LOGIC` is the specification layer.

It is responsible for:

- defining what phantoms are needed
- defining how many are needed
- defining the constraints of those phantoms
- defining what memory relationship they should have
- defining task shape

`LOGIC` does not directly create phantoms.
It builds the structural conditions for manifestation.

New reading:

- `LOGIC` = manifest specification constructor

Examples of what `LOGIC` may define:

- phantom type
- count
- task
- restrictions
- memory mode
- convergence mode

## CYCLE

`CYCLE` is not a creator.
`CYCLE` is the operator of repeated or plural execution as one act.

It is responsible for:

- batch manifestation
- repeated iteration
- wave-like execution
- convergence
- stability through repetition

Important rule:

- if only one phantom is needed, `CYCLE` is not required
- if multiple phantoms are needed, `CYCLE` organizes them as one wave

So the correct model is not:

- `MANIFEST` called five times by hand

But:

- one cycle act
- one batch
- one wave

New reading:

- `CYCLE` = multiplicity and iterative convergence

## MANIFEST

`MANIFEST` is no longer only final output.

It becomes the manifestation factory.

It is responsible for:

- taking crystallized result/specification
- producing temporary manifestation forms
- rendering form
- sealing final manifestation packet

These forms may be treated as temporary Eva phantoms.

Examples:

- `Eva.Social`
- `Eva.Game`
- `Eva.Memory`
- later other temporary forms

Important rule:

- `MANIFEST` creates forms
- `CYCLE` may organize manifestation in multiplicity
- `Eva.Core` still owns the decision

## Phantom Model

A phantom is:

- temporary
- narrow
- one-function
- returned to `Eva.Core`

Phantoms are not autonomous demons.
They are manifestation forms created for a specific task.

## Correct Flow

### Single phantom case

If only one phantom is needed:

- `Eva.Core`
- `LOGIC` defines the phantom specification
- `RUNTIME` provides memory/state slice if needed
- `MANIFEST` creates the phantom
- result returns to `Eva.Core`

Formula:

- `Eva.Core -> LOGIC(spec) -> RUNTIME(slice) -> MANIFEST(phantom)`

### Multi-phantom case

If multiple phantoms are needed:

- `Eva.Core`
- `LOGIC` defines the phantom batch specification
- `RUNTIME` provides memory/state basis
- `CYCLE` frames it as one wave / batch / repeated act
- `MANIFEST` creates the phantoms
- results return to `Eva.Core`

Formula:

- `Eva.Core -> LOGIC(spec) -> RUNTIME(slice) -> CYCLE(batch) -> MANIFEST(phantoms)`

## Non-Contradiction Rule

The four operators do not conflict if the ownership is kept clean:

- `Eva.Core` owns meaning and decision
- `LOGIC` owns structure of conditions
- `RUNTIME` owns stable state and memory basis
- `CYCLE` owns multiplicity and iterative wave
- `MANIFEST` owns creation of temporary outward forms

This is the key to keeping the lower triangle coherent.

## Historical Consistency

This reading is consistent with older ProcessLang references:

- Python `SubconsciousRuntime` -> stable subconscious basis
- Python `LogicSimulator` -> turning intent into executable rule
- Python `EternalCycle` -> repetition and stability through iteration
- Python `ManifestationEngine` -> end of process in form
- Zig `CYCLE.generate()` -> batch generation
- Zig `RUNTIME.snapshot()` and `rollback()` -> state foundation
- Zig `LOGIC.validate/enforce/classify()` -> structural rule shaping
- Zig/Lua `MANIFEST.emit/render/seal()` -> manifestation mechanics

So this is not a random redesign.
It is a cleaner continuation of the original operator ontology.

## Practical Consequence

Implementation should move toward:

- `RUNTIME` delivering slices/snapshots
- `LOGIC` producing manifest specifications
- `CYCLE` producing batch execution framing when needed
- `MANIFEST` becoming a manifestation factory instead of only terminal output

This is the correct lower architecture for the new Eva.

## Transitional Implementation Strategy

The lower triangle should **not** be implemented by directly rewriting the current `planGOD` modules in place.

Instead:

- keep the existing architecture alive
- add a new Eva-layer above / around it
- let `Eva.Core` call new Eva-operator modules

This means the new implementation path should look like:

- `Eva.Core`
- `Eva.LOGIC`
- `Eva.CYCLE`
- `Eva.RUNTIME`
- `Eva.MANIFEST`

These are not the same thing as the current legacy files:

- `modules/logic/logic.lua`
- `modules/runtime/runtime.lua`
- `modules/manifest/manifest.lua`

Those legacy modules may continue to exist during transition.

## Why This Transition Is Correct

If the current lower execution modules are rewritten directly,
Eva will likely break.

So the correct path is:

- old architecture remains functional
- new Eva operator layer is built as an additional layer
- `Eva.Core` begins to use that new layer gradually

This allows:

- no hard break of the current Eva
- incremental testing
- gradual migration of ownership
- comparison between old and new paths

## New Layer Interpretation

The new lower triangle should be understood as a dedicated Eva layer:

- `Eva.LOGIC`
- `Eva.CYCLE`
- `Eva.RUNTIME`
- `Eva.MANIFEST`

This layer is an internal operator layer of Eva.

It exists under:

- `Eva.Core`

and supports higher manifestations such as:

- `Eva.Social`
- `Eva.Developer`
- `Eva.Game`

## Ownership During Transition

During the transition:

- current legacy modules keep current Eva alive
- new Eva operator modules are added in parallel
- `Eva.Core` decides when to use the old path or the new path

So the migration is:

- additive first
- replacing later

This is the intended safe path.
