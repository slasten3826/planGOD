# nanoPL Multi-Agent Packet16 Test

## Status

Prepared research test.  
March 19, 2026.

---

## 1. Goal

Test whether a larger `nanoPL` agent swarm can reconstruct and explain a real
multi-layer system architecture from source material, not from toy prompts.

The specific target is the Zig Packet prototype:

- `layer0_substrate.zig`
- `layer1_chaos.zig`
- `layer2_boundary.zig`
- `layer3_calm.zig`
- `layer4_tension.zig`

---

## 2. Why This Test Matters

Previous `2-agent` and `4-agent` tests showed:

- `nanoPL` can carry state between agents
- agents can converge to a useful final answer
- the language tends to preserve process topology, not prose

This test raises the bar:

- more agents
- more ambiguity
- real architecture
- nontrivial layered system

If the swarm succeeds here, that is much closer to real cognitive-engine work
than archive/policy toy tasks.

---

## 3. Core Hypothesis

A `16-agent` swarm on one substrate can use `nanoPL` to:

1. distribute architectural understanding
2. compress partial findings into handoffs
3. converge toward a coherent explanation of what Packet is
4. do this without collapsing entirely into prose or meaningless pseudo-code

---

## 4. Human Task Shape

The agents are not asked to merely summarize files.

They are asked to answer a harder question:

- what kind of machine is Packet?
- how do the layers interact?
- what is the computational cycle?
- why is it more than “just an engine”?
- what architectural risks or unstable assumptions are visible?

---

## 5. Why This Is Harder

The Zig prototype contains several interacting ideas:

- static substrate
- chaos VM
- boundary crystallization
- calm trigram VM
- tension feedback loop

The swarm must recover:

- layer responsibilities
- data flow
- one-way vs feedback transitions
- system purpose
- emerging ontology

This is much harder than choosing a policy rule.

---

## 6. Expected Good Outcome

Promising signal:

- the swarm stabilizes around a coherent architecture
- final answer identifies the Packet cycle
- final answer distinguishes substrate / chaos / boundary / calm / tension
- intermediate handoffs remain recognizably `nanoPL`

---

## 7. Expected Failure Modes

Possible failures:

- empty or useless handoffs
- collapse into repeated generic glyph shells
- drift into prose disguised as `nanoPL`
- shallow summary of filenames instead of system reconstruction
- premature finalization before enough integration happened

---

## 8. What To Observe

### A. Swarm behavior

- does the swarm actually use many turns
- do later agents add structure rather than repeat
- does convergence improve with more agents

### B. Language behavior

- does `nanoPL` remain stable at scale
- do new constructions emerge
- are new constructions readable or just noise

### C. Architecture behavior

- does the final answer recover the computational loop
- does it identify the asymmetry:
  - chaos → boundary → calm
  - calm residue → tension → chaos

---

## 9. Practical First Run

Recommended first run:

- provider: `deepseek`
- model: `deepseek-chat`
- agents: `16`
- max turns: `24`
- minimum turns before final: `16`

This gives every agent at least one turn and leaves room for one extra cycle.

---

## 10. Bottom Line

This test is no longer about memory only.

It asks whether `nanoPL` can act as:

- a swarm language
- an architectural reasoning medium
- a substrate-native cognitive coordination layer

on top of real system material.
