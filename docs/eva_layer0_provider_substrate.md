# Eva Layer 0: Provider Substrate

## Status

Accepted architectural direction.

Layer 0 exists **below** `Eva.Core`.
It is not part of Eva's identity, cognition, memory, or manifestation.
It is the current substrate Eva runs on.

Current examples:
- `deepseek`
- `glm`

## Core Principle

Providers are not Eva.
Providers are the material substrate Eva temporarily inhabits.

So the stack becomes:

- `Layer 0` = provider substrate
- `Layer 1` = `Eva.Core`
- `Layer 2` = `Eva.Social`, `Eva.Developer`, `Eva.Game`, later others

## What Belongs To Layer 0

Layer 0 should contain:

- provider registry
- active provider selection
- active model selection
- provider fingerprinting
- provider-specific error normalization
- technical execution logs
- network / timeout / transport handling

Layer 0 should **not** contain:

- Eva memory
- Packet memory
- gameplay logic
- style / fun judgement
- manifestation logic

## Provider Fingerprint

Every run should be able to carry a substrate fingerprint.

Minimum useful fields:

- `provider`
- `model`
- `temperature`
- `timeout`
- `timestamp`

Possible future fields:

- `latency_ms`
- `transport`
- `status`
- `token_budget`

Fingerprint is important because different substrates may produce different readings, residues, or failures.

## Logs And Layer 0

Technical logs belong to Layer 0.

This includes:

- provider call start
- provider call end
- timeout / DNS / transport failures
- active provider/model
- execution trace of substrate-level events

This is different from memory:

- `Layer 0 logs` = how execution happened
- `Layer 1/2 memory` = what world / reading was preserved

So logs and memory must stay separated.

## Provider Choice Policy

Future possibility:
- Eva may later learn which provider is better for which task
- this may be decided via testing, evaluation, or `Eva.Test`

But **not now**.

For now:

- provider choice is **not** delegated to Eva
- there is **one active provider at a time**
- provider switching is treated as disabled future functionality

## Current Rule

For the current phase:

- one provider is active
- provider auto-choice is disabled
- provider switching is conceptually present, but set to `0`

This means:

- easier debugging
- less ambiguity
- cleaner testing of Eva memory and behavior
- clearer understanding of what came from which substrate

## Switch Concept

Future switch concept:

- `provider_switch = 0`

Meaning:

- no automatic selection
- no substrate self-routing
- no provider policy engine yet

Later this may become:

- manual switching
- evaluated switching
- eventually learned switching

But not in the current phase.

## Practical Outcome

Immediate implementation should aim for:

- explicit active provider visibility
- stored provider fingerprint for runs
- technical logs staying in Layer 0
- no autonomous provider choice

This keeps the substrate simple and debuggable while preserving the future path.
