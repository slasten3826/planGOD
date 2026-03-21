# Prose Multi-Agent Packet16 Baseline

## Status

Prepared comparison baseline.  
March 19, 2026.

---

## 1. Goal

Provide a fair comparison against the `nanoPL` swarm test on the same Packet
task.

This baseline keeps:

- the same task
- the same provider
- the same model
- the same number of agents
- the same minimum turn count

but replaces internal `nanoPL` handoffs with short natural-language handoffs.

---

## 2. Why This Matters

The `nanoPL` swarm looked strong, but without a text baseline there is no clean
comparison.

This test asks:

- does a prose/RAG-like coordination loop converge as cleanly
- does it stay coherent under 16 agents
- does it collapse into semantic soup
- does it surface the same architectural invariant

---

## 3. Internal Format

Each agent may output:

- one `HANDOFF:` line in ordinary concise prose
- optionally one `FINAL:` line when the swarm is ready to close

The handoff should contain:

- current understanding
- next unresolved point
- no long essay

---

## 4. Success Criteria

Useful baseline signal:

- the swarm converges to a coherent final architectural answer
- intermediate handoffs remain relevant
- later turns refine instead of drift

---

## 5. Failure Signs

Likely baseline failure modes:

- long repetitive paraphrase
- semantic soup across turns
- premature confident closure
- loss of the cycle / asymmetry insight
- less stable convergence than `nanoPL`

---

## 6. Bottom Line

This baseline exists to answer one practical question:

- is `nanoPL` actually better than ordinary prose handoff for swarm cognition?
