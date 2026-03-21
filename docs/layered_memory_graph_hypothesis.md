# Layered Memory Graph Hypothesis

## Status

Hypothesis.  
March 19, 2026.

---

## A. Core Idea

Eva memory may need not one graph, but one **overlaid graph with two layers**:

- **Layer 1**: execution / runtime topology
- **Layer 2**: semantic / glyph-tension topology

These should share the same operator nodes:

- `FLOW`
- `CONNECT`
- `DISSOLVE`
- `ENCODE`
- `CHOOSE`
- `OBSERVE`
- `CYCLE`
- `LOGIC`
- `RUNTIME`
- `MANIFEST`

But they should **not** be reduced to the same kind of edge.

---

## B. Layer Definitions

### Layer 1: Runtime Topology

This is the already existing `E_momentum -> E_edges` style memory.

It captures:

- what the agent actually did
- how execution moved between modules
- scheduler- and tick-grounded transitions

Examples:

- `FLOW -> OBSERVE`
- `OBSERVE -> LOGIC`
- `RUNTIME -> MANIFEST`

This layer is constrained by:

- actual execution
- scheduler legality
- runtime truth

### Layer 2: Semantic Tension Graph

This is the newly discovered glyph-graph style memory.

It captures:

- what operators pulled on each other in meaning-space
- what semantic tension or transformation dominated an answer

Examples:

- `DISSOLVE -> FLOW`
- `ENCODE -> OBSERVE -> DISSOLVE`
- `FLOW -> CONNECT -> MANIFEST`

This layer is **not** constrained by runtime execution legality.

For example:

- `FLOW -> MANIFEST` in semantic space is not automatically wrong
- even if runtime scheduler would never take that direct path

---

## C. Why They Should Be Overlaid, Not Merged Blindly

If the two layers are collapsed into one undifferentiated edge set,
important differences are lost.

If they are kept as completely separate worlds,
their interaction becomes invisible.

So the right form may be:

- one node graph
- two edge channels

Metaphorically:

- `red` = execution
- `blue` = semantic

The colors are not literal.
The important thing is layered distinction.

---

## D. Why This Matters

Overlaying the layers may reveal:

- **alignment**
  - semantic pull and execution path agree

- **misalignment**
  - semantic graph leans one way, runtime graph executes another

- **latency**
  - semantic shift appears before runtime habit updates

- **inertia**
  - runtime still follows old habits while semantic graph has changed

- **emptiness**
  - runtime transition exists, but semantic layer is weak or missing

These are all memory-relevant signals.

---

## E. Hallucination / Drift Interpretation

This model suggests a new way to think about hallucination.

Hallucination may not simply mean:

- “the model said something false”

It may instead appear as:

- a large divergence between semantic layer and runtime-confirmed layer

This is important because hallucination itself is not always bad.
The problem is uncontrolled hallucination.

With a layered graph, it may become possible to distinguish:

- small divergence
  - acceptable exploration / creativity

- medium divergence
  - risk zone

- large divergence
  - ungrounded or unstable cognition

This means the system may eventually be able to:

- observe hallucination level
- and perhaps even regulate it

---

## F. Why This Fits Eva

Eva needs:

- runtime truth
- semantic sensitivity
- compact memory
- and a ProcessLang-native internal format

A layered graph fits all four better than:

- chat history
- single anchor text
- plain summaries

This would make Eva memory closer to:

- an actual cognitive instrument

rather than a log dump.

---

## G. Proposed Unified Edge Shape

Not final, but likely something like:

- `source`
- `target`
- `layer`
  - `execution`
  - `semantic`
- `weight`
- `hits`
- `domain`
- `confidence`
- maybe:
  - `kind`
  - `origin`

The critical point:

- same nodes
- distinct layers
- comparable weights

---

## H. Open Questions

1. How should the semantic layer be extracted most honestly?
   - model-mediated extraction?
   - rule-based microPL extraction?
   - hybrid?

2. Should semantic edges be directed, undirected, or mixed?

3. How should layer divergence be measured?
   - overlap ratio?
   - weighted distance?
   - graph edit distance?

4. When does semantic drift become useful creativity,
   and when does it become ungrounded hallucination?

5. How should the two layers update over time?
   - same decay?
   - different decay?

---

## I. Next Research Direction

The next task is not full implementation yet.

The next task is:

1. define a practical merge/overlay representation
2. decide what counts as a valid test for layered graphs
3. build first probes that compare:
   - execution edges
   - semantic edges
   - and their divergence

Only then should the memory layer be integrated into Eva proper.
