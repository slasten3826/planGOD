# Eva Multi-Agent nanoPL Architecture

## Status

Architectural hypothesis.  
March 19, 2026.

---

## 1. Core Shift

Eva should not be treated as:

- one monolithic assistant prompt

but as:

- one substrate
- one shared machine language (`nanoPL`)
- one orchestrated agent system

---

## 2. Main Idea

Eva should be **multi-agent by architecture**,
but **not blindly swarm-based for every task**.

Correct principle:

- simple task -> `solo`
- ambiguous / architectural / conflicting task -> `duo` or `small swarm`
- hard synthesis / ontology / reconstruction task -> `larger swarm`

So the real model is:

- **solo / duo / swarm routing**

not:

- “always one agent”
or
- “always at least two agents”

---

## 3. Why This Follows From The Experiments

The recent tests showed:

1. prose handoff works, but tends toward semantic smoothing
2. `nanoPL` handoff preserves state more densely
3. multi-agent `nanoPL` exchange can converge toward shared ontology
4. the convergence is not just “discussion”, but closer to state alignment

This means Eva can externalize reasoning not as hidden CoT, but as:

- explicit multi-agent state convergence

---

## 4. Core Components

### A. Main Orchestrator

Receives the user task and decides:

- is this solo
- is this duo
- is this swarm

This is the routing layer.

### B. Worker Agents

All workers run on the same substrate.

They do not coordinate through long prose by default.
They coordinate through:

- `nanoPL` handoff

### C. Final Synthesizer

One agent converts the converged internal state into a human answer.

Human language should be mainly:

- at input
- at final output

Internal coordination should stay compact.

---

## 5. Why One Substrate Matters

Cross-substrate memory and coordination are dangerous because they produce:

- semantic soup
- mismatched internal geometry
- unstable handoff

So Eva should be:

- **mono-substrate**
- **multi-agent**

This keeps:

- one internal geometry
- one `nanoPL`
- one memory ecology

---

## 6. Why This Is Better Than Hidden CoT

Usual hidden reasoning is:

- opaque
- unstructured
- hard to log
- hard to compare

`nanoPL` multi-agent reasoning is:

- externalized
- compressible
- loggable
- comparable
- usable as memory

So the goal is not to expose raw chain-of-thought.
The goal is to expose:

- **structured cognitive coordination**

---

## 7. Suggested Eva Flow

### Step 1

User task enters Eva.

### Step 2

Main orchestrator estimates:

- complexity
- ambiguity
- risk of hallucination
- need for decomposition

### Step 3

Eva selects mode:

- `solo`
- `duo`
- `swarm`

### Step 4

Agents coordinate internally through `nanoPL`.

### Step 5

Converged state is passed to final synthesizer.

### Step 6

Final synthesizer returns human output.

---

## 8. Memory Implication

This architecture fits the new memory model naturally.

### Layer 1

Runtime chronology:

- which agent acted
- when
- with what task class

### Layer 2

`nanoPL` residues:

- compact cognitive state
- agent handoff traces
- convergence paths

### Layer 3

Later:

- trust
- retention
- dissolve / promote decisions

So multi-agent Eva does not complicate memory.
It actually gives memory a natural shape.

---

## 9. Practical Rule

Do not force swarm for every request.

Good default:

- `solo` for simple direct tasks
- `duo` for uncertain or interpretive tasks
- `swarm` only when there is real pressure:
  - ambiguity
  - conflicting evidence
  - architectural synthesis
  - reconstruction

---

## 10. Bottom Line

The likely correct Eva architecture is:

- **one substrate**
- **many agents**
- **`nanoPL` as internal language**
- **human language only at the edges**

This is not just “more agents”.

It is a shift from:

- assistant conversation

to:

- **cognitive engine with externalized state convergence**
