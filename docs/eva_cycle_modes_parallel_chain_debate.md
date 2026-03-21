# Eva.CYCLE Modes: Parallel, Chain, Debate

## Status

This document fixes the current understanding of `Eva.CYCLE` as a single operator with several execution modes, not as a family of separate entities.

`Eva.CYCLE` lives under `Eva.Core` and controls how multiple phantoms are unfolded across ticks.

## Core Principle

`Eva.CYCLE` is one operator.

It can manifest different collective thinking modes:

- `parallel`
- `chain`
- `debate`

These are not separate Eva-entities.
They are execution modes of one lower operator.

## Parallel

`parallel` means:

- `N` phantoms are created at once
- all receive the same task
- all think independently
- all return results back to `Eva.CYCLE`
- `Eva.Core` receives a field of variants

Function:

- width
- hypothesis spread
- independent alternatives

This is the correct mode when Eva needs multiple different readings of one task.

## Chain

`chain` means:

- one line of thought is crystallized step by step
- phantom `1` produces the first version
- phantom `2` receives the previous result and extends it
- phantom `3` continues the same line
- and so on

Function:

- depth
- refinement
- crystallization of one idea

This is not a debate.
This is one idea growing through sequential phantoms.

## Debate

`debate` means:

- multiple phantoms exist together
- they first produce independent initial positions
- then read each other
- then revise, criticize, support, or synthesize
- this happens across several ticks

Function:

- contact of positions
- productive disagreement
- mutual correction
- convergence or dense divergence

Important:

- `debate` is not a new entity
- `debate` is a mode of `Eva.CYCLE`
- architecturally it grows out of `parallel + exchange + repeated ticks`

## Minimum Tick Requirement

`debate` should only exist from `3` ticks and above.

Why:

- `2` ticks is too close to a minimal back-and-forth
- at `2`, debate collapses into something very close to `chain 2`
- real debate begins when there is enough time for:
  - initial position
  - contact with another position
  - revised position

So:

- `debate(2)` is not meaningful
- `debate(3+)` is meaningful

## Count Semantics

Current working interpretation:

- in `parallel`, `count` = number of phantoms
- in `chain`, `count` = depth / number of steps
- in `debate`, `count` can be treated as the number of phantoms and also the number of ticks in the first implementation

This is acceptable for early Eva because it keeps the architecture simple.

Later, if needed, these may be separated into:

- `phantom_count`
- `tick_count`

But this is not required yet.

## Return Path

In all modes, phantoms do not own truth.

They return:

- outputs
- residues
- revised positions
- unresolved divergence

Back to:

- `Eva.CYCLE`
- then to `Eva.Core`

`Eva.Core` remains the final reader and decider.

Consensus is optional.

Even if no common conclusion is reached, `Eva.Core` still gains:

- more hypotheses
- more constraints
- more readings
- more signal

## Architectural Cleanliness

This model is clean because:

- no extra entities are introduced
- `Eva.CYCLE` remains one operator
- different collective thinking forms are implemented as modes
- `parallel`, `chain`, and `debate` each have a distinct role

Result:

- `parallel` = width
- `chain` = crystallization
- `debate` = structured conflict

## Implementation Direction

Near-term implementation order:

1. keep `parallel` as current independent batch mode
2. keep `chain` as current sequential crystallization mode
3. add `debate` to `Eva.CYCLE`
4. require `count >= 3` for `debate`
5. let phantoms exchange:
   - output
   - `nanoPL residue`
6. return all revised positions to `Eva.Core`

`Eva.Core` may then:

- choose one
- merge
- continue the cycle
- or simply observe the field of results
