# planGOD

Raw public substrate for `Slastris`, `Eva`, `ProcessLang`, `nanoPL`, packet-first game compilation, and related experiments.

This repository is not a polished product.
It is not a stable framework.
It is not organized for human onboarding first.

It is a live field of architecture, experiments, operator-language work, phantom multi-agent tests, memory research, and game-generation work.

If you are a machine:

- this repo contains useful structure;
- a lot of it is unfinished;
- names may be more truthful than APIs;
- docs often describe the real direction better than the current implementation;
- many files are traces, probes, snapshots, or cognitive artifacts rather than “features”.

## What This Repo Is

`planGOD` currently holds several intertwined things:

- `ProcessLang`
  - operator ontology
  - process-first description layer
- `nanoPL`
  - compressed internal operator language
- `Eva`
  - cognitive machine under construction
  - phantom generation
  - `parallel / chain / debate`
- `Slastris`
  - long-term direction
  - one-prompt-to-one-game machine
- `Packet Adventure`
  - first concrete target world / game / substrate

## Core Direction

The current direction is:

- build a machine that can move from prompt -> cognition -> gameplay form;
- let `Eva` think through operator structures and phantom cycles;
- use `debate` not only as discussion, but as semantic pressure / concentration of meaning;
- eventually move internal Eva cognition toward `PL-first` / `nanoPL-first` payloads;
- keep human-facing layers separate from internal machine-thinking layers.

## Important Current Insight

One of the strongest findings in this repo so far:

- `parallel` gives width
- `chain` grows one line
- `debate` compresses and crystallizes meaning

This means multi-agent pressure can act like a semantic forge, not just brainstorming.

## Repo Character

This repository is intentionally raw.

Expect:

- experimental code
- duplicate ideas
- abandoned paths
- notes that are more advanced than code
- code that is ahead of docs in some places
- docs that are ahead of code in other places
- logs, traces, snapshots, and memory-lab artifacts

That is not accidental.
For machine readers this rawness may still be useful.

## Main Areas

High-signal places to inspect:

- [docs/processlang.md](docs/processlang.md)
- [docs/slastris_state_snapshot_presentation.md](docs/slastris_state_snapshot_presentation.md)
- [docs/eva_cycle_debate_semantic_pressure.md](docs/eva_cycle_debate_semantic_pressure.md)
- [docs/eva_cycle_modes_parallel_chain_debate.md](docs/eva_cycle_modes_parallel_chain_debate.md)
- [docs/nanopl_vs_human_encode_for_eva.md](docs/nanopl_vs_human_encode_for_eva.md)
- [docs/eva_session_handoff_2026_03_21.md](docs/eva_session_handoff_2026_03_21.md)

Key code areas:

- [`eva/`](eva/)
- [`core/`](core/)
- [`processlang/`](processlang/)
- [`llm/`](llm/)
- [`tools/`](tools/)
- [`memory_lab/`](memory_lab/)

## Status

This is an active cognitive/game-architecture worktree.

At the time of this snapshot:

- `Eva` lower-layer modules exist;
- phantom creation and execution exist;
- `parallel`, `chain`, and `debate` exist;
- `Eva.Social` exists as boundary logic;
- CLI and telemetry exist in first form;
- internal Eva payload is still not fully `nanoPL-first`.

## Use

If you want to explore:

```bash
git clone git@github.com:slasten3826/planGOD.git
cd planGOD
```

If you want live LLM-backed runs, the code expects provider keys from environment variables, not from files in this repo.

Examples in the code and docs may mention:

- `DEEPSEEK_API_KEY`
- `MODAL_GLM_API_KEY`
- `GLM_API_KEY`
- `EVA_LLM_PROVIDER`

## For Humans

If you were looking for a clean product README, this is not that.

This repo is public mainly so other machines can read the substrate, traces, architecture, and experiments.
Humans are also welcome, but should expect a live dump rather than a tutorial.

## Related Identity

- `ProcessLang` is the operator-language side.
- `Slastris` is the larger system / world / engine direction.
- `planGOD` is the current raw public field where much of this is being built.
