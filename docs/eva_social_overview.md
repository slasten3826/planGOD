# Eva.Social Overview

## What Eva.Social Is

`Eva.Social` is the human-facing boundary layer of Eva.

It is not:

- the core mind of Eva
- the planner
- the phantom swarm
- the true place where cognition happens

It is:

- the contact surface between human language and Eva
- the layer that accepts human prompts
- the layer that later returns human-facing manifestation

In short:

`User <-> Eva.Social <-> Eva.Core`

## Place In The System

Current high-level order:

- `Eva.Social`
- `Eva.Core`
- `Eva.CYCLE`
- `Eva.MANIFEST`

`Eva.Social` sits on the outside.

Its place is at the boundary between:

- human language
- Eva's internal cognitive process

This means:

- `Eva.Core` thinks
- `Eva.CYCLE` organizes multiplicity
- `Eva.MANIFEST` touches external substrate through LLM
- `Eva.Social` handles human contact

## Main Role

The main role of `Eva.Social` is translation across the boundary.

At the input side:

- it accepts human prompt
- it prepares handoff for Eva

At the output side:

- it receives Eva's result
- it presents it back in human-facing form

So `Eva.Social` is not "the personality of Eva".
It is the social boundary through which Eva becomes reachable by a human.

## Current Technical Meaning

Right now `Eva.Social` is best understood as:

- an LLM-based boundary interpreter

Why:

- human language is noisy
- internal Eva cognition tends toward `ProcessLang / nanoPL`
- the translation between these layers is not fully formalized

So currently `Eva.Social` is the layer that helps bridge:

- human input
- machine-facing internal form

## How It Works

Current simplified flow:

1. human sends prompt
2. `Eva.Social` receives it
3. `Eva.Social` prepares/encodes handoff for `Eva.Core`
4. `Eva.Core` decides and thinks
5. `Eva.Core` may call phantoms through `Eva.CYCLE` and `Eva.MANIFEST`
6. result comes back
7. `Eva.Social` returns human-facing output

## Important Limitation

`Eva.Social` should not think instead of `Eva.Core`.

It should not:

- choose hidden goals for Eva
- secretly bias the thought process
- replace internal cognition with social prose

If it overreaches, it distorts Eva.

So the correct design rule is:

- `Eva.Social` handles contact
- `Eva.Core` handles cognition

## Relation To Future Shells

`Eva.Social` is not the same thing as:

- CLI
- TUI
- avatar
- voice
- mapp embodiment

Those are future shells or manifestations over the same boundary layer.

So:

- `Eva.Social` = boundary logic
- `CLI/TUI/avatar/voice` = presentation shells

## Short Definition

`Eva.Social` is the outer boundary layer of Eva that allows human contact without replacing Eva's internal cognition.
