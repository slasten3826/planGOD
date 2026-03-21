# Eva.Core As Observe, MANIFEST As Factory

## Status

Accepted conceptual direction.

This is not yet implemented in code,
but it is the correct architectural reading of where Eva is going.

## Core Insight

`Eva.Core` behaves like the true central `OBSERVE` of the machine.

This means:

- it sees the full state
- it holds the main cognitive cycle
- it decides what happens next
- it owns meaning and routing

So:

- old `OBSERVE` was the center of the previous machine
- `Eva.Core` becomes the more mature and expanded form of that role

In practice:

- `Eva.Core ~= OBSERVE++`

## New Reading Of MANIFEST

`MANIFEST` should no longer be understood as only:

- final text output
- terminal response
- final print boundary

Instead:

- `MANIFEST` becomes a manifestation factory
- it creates the right outward form from Eva.Core state

## What MANIFEST Should Do

The new role of `MANIFEST` is:

- receive crystallized result from `Eva.Core`
- decide or route manifestation target
- create the needed temporary manifestation form
- return the result of that form back into the main architecture

So `MANIFEST` is not truth.
`MANIFEST` is not the main thinker.
`MANIFEST` is the point where inner result becomes a usable outer form.

## Phantom Model

The new manifestations can be treated as temporary Eva phantoms.

A phantom:

- is narrow
- has one function
- does one job
- returns result to `Eva.Core`

Examples:

- `Eva.Social`
- `Eva.Game`
- `Eva.Memory`
- later others

These are not independent demons.
They are temporary manifestations created for a specific task.

## Correct Ownership

Correct ownership becomes:

- `Eva.Core` owns meaning
- `Eva.Core` owns routing
- `Eva.Core` owns final decision
- `MANIFEST` owns manifestation
- phantoms only execute their one function

This keeps the architecture clean:

- one true center
- many temporary outward forms
- no unnecessary autonomous sub-demons

## Why This Matters

This solves a growing architectural conflict:

- old architecture treated `MANIFEST` as output
- new architecture needs multiple Eva forms
- if each form becomes a separate demon, the system becomes noisy and confused

The factory model avoids that.

Instead of:

- many half-independent Evas

You get:

- one core
- one manifestation point
- many temporary functional forms

## Historical Confirmation

This direction is consistent with older ProcessLang references:

- Python `ManifestationEngine` already treated manifestation as "end of process in form"
- old Lua `MANIFEST` had `render`, `emit`, and `seal`
- Zig `MANIFEST` had `emit`, `render`, `ready`, and `seal`

So this is not a random reinvention.
It is closer to the deeper original meaning of `MANIFEST`.

## Practical Next Step

The next design step is not to immediately rewrite all Eva architecture.

The next step is:

- rethink `modules/manifest/manifest.lua`
- move it from terminal-output module
- toward manifestation-factory module

That module should later be able to:

- emit social manifestation
- emit game manifestation
- trigger memory commit
- later emit other phantoms

Without taking thought ownership away from `Eva.Core`.
