# Human vs nanoPL Parallel Distribution Insight

## What Was Tested

One gameplay idea was evaluated in `parallel` mode with large phantom batches:

- `human ENCODE x100`
- `nanoPL ENCODE x100`

Both runs used the same basic idea:

- `Protocol Forge`
- capture protocol elements
- craft packet-spells/tools
- test them in challenges
- use them for puzzles, paths, NPC influence, and story progress

The only difference was the source representation:

- human-readable prose
- `nanoPL`

## First Result

Neither field behaved like a clean Gaussian distribution.

Both converged.

But they converged in **different ways**.

## Human ENCODE x100

Human ENCODE produced a very strong human-facing cluster.

The field collapsed around:

- UI friction
- complexity
- tutorial need
- onboarding
- streamlining

### Repeated Themes

Strong:

- thematic integration
- puzzle potential
- creative potential

Weak:

- complexity
- cumbersome crafting
- interface burden

Typical recommendation:

- keep the mechanic
- simplify the UI
- add tutorials
- improve clarity / feedback

### Shape

This field was highly clustered.

Observed:

- `100/100` still said keep the idea
- one near-identical judgment repeated `24` times
- only `60/100` outputs were unique

Interpretation:

Human ENCODE does not produce a broad free distribution here.
It rapidly collapses into a shared **player-facing UX critique**.

## nanoPL ENCODE x100

nanoPL produced a different field.

The evaluations converged less around UX
and more around structural loop analysis.

### Repeated Themes

Strong:

- clear progression
- visible loop:
  - `capture -> craft -> test -> progress`

Weak:

- repetition
- abstraction
- weak grounding of risk/story into the loop

Typical recommendation:

- keep the mechanic
- add challenge variety
- ground risk more concretely
- improve tactile or in-world feedback

### Shape

This field was less textually collapsed than the human run.

Observed:

- `100/100` still said keep the idea
- only the top response repeated `7` times
- `86/100` outputs were unique

But semantically the field still converged around a small number of structural concerns.

The result looked closer to a **two-cluster structural field**:

- repetition / need for variety
- abstraction / need for grounding

## Main Interpretation

This strongly supports the distinction:

- human ENCODE = human-facing interpretation
- `nanoPL` = structural machine-facing interpretation

Human ENCODE asks:

- will this overwhelm people?
- is the interface too heavy?
- does it need tutorials?

nanoPL asks:

- is the loop too repetitive?
- is the progression structurally clear?
- is risk properly grounded into the process?

## Why This Matters

This means these are not interchangeable views.

They are different evaluative instruments.

### Human ENCODE is useful for:

- likely player reaction
- onboarding friction
- perceived complexity
- UI burden
- tutorial need

### nanoPL is useful for:

- loop critique
- process critique
- structural weakness
- repetition analysis
- grounding analysis

## Architectural Consequence

This does not yet fully define:

- `Eva.Critic`
- `Eva.Test`

But it gives real tools for them.

Meaning:

- `Eva.Critic` can eventually critique from both:
  - human-facing view
  - structural nanoPL view

- `Eva.Test` can eventually test both:
  - player-facing friction
  - gameplay loop coherence

So these are not full future subsystems yet,
but they are already **usable evaluative instruments** for them.

## Final Insight

Large-scale parallel sampling is not useless,
but it does not create the same compression effect as debate.

Instead it reveals:

- where human-facing perception collapses
- where structural critique collapses

So:

- `parallel(human)` exposes likely UX consensus
- `parallel(nanoPL)` exposes likely structural consensus

This makes both useful,
but for different reasons.
