# nanoPL Multi-Agent Language Test Plan

## Status

Working research plan.  
March 19, 2026.

---

## 1. Goal

Test whether `nanoPL` can function not only as:

- memory residue

but also as:

- a communication language between agents on the same substrate

---

## 2. Core Idea

Human language should be used only for:

- initial task statement
- final result

All internal agent-to-agent exchange should be forced into `nanoPL` residues or
short `nanoPL`-style messages.

---

## 3. Important Attitude

If agents generate what looks like “pseudo-nanoPL”, that is **not automatically
a failure**.

Possible cases:

1. meaningless fake language
2. partial coordination code
3. emergent machine shorthand
4. real substrate-native communication layer

This test exists to distinguish these cases empirically.

---

## 4. Phase Order

### Phase 1

`2` agents

Purpose:

- verify basic exchange
- see whether one agent can hand state to another in `nanoPL`

### Phase 2

`4` agents

Purpose:

- test coordination pressure
- see whether `nanoPL` remains readable / stable under branching

### Phase 3

`8+` agents

Purpose:

- look for swarm effects
- look for collapse, drift, or emergent machine law

---

## 5. First Experimental Shape

For the first test:

- one substrate
- two agents
- one bounded task
- human prompt only at start
- final prose answer only at end
- all intermediate messages in `nanoPL`

---

## 6. Suitable First Tasks

Good first tasks:

- classify a small situation together
- refine a small plan
- inspect a short text and reach a compact conclusion
- solve a bounded reasoning task with 2-3 sub-parts

Bad first tasks:

- giant coding task
- open-ended creative writing
- broad research

---

## 7. What To Observe

### A. Language behavior

- does `nanoPL` remain stable
- does it mutate
- do both agents use compatible forms

### B. Coordination behavior

- do agents converge
- do they hand off state
- do they recover from ambiguity

### C. Task behavior

- is the final answer coherent
- does the result improve over a single-agent run

---

## 8. What Counts As Early Success

Promising early signal:

- agent 1 emits a compact `nanoPL` handoff
- agent 2 produces a relevant next-step `nanoPL` response
- final answer is coherent and related to the original task

This is enough for first proof-of-effect.

---

## 9. What Counts As Failure

Failure signs:

- agents collapse back into prose immediately
- `nanoPL` messages become unrelated noise
- no usable handoff occurs
- final answer is detached from the task

---

## 10. Implementation Direction

The first test environment should be minimal:

- direct substrate only
- no Eva integration yet
- explicit turn order
- full logging

That is enough for first validation.

---

## 11. Bottom Line

This test asks a new question:

- not “can `nanoPL` store state?”

but:

- **can `nanoPL` carry state between agents as language?**
