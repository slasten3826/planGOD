# Three-Layer Memory Model for Eva

## Status

Hypothesis.  
March 19, 2026.

---

## A. Core Idea

Eva memory may need not one storage mechanism,
and not even just two layers,
but **three distinct layers**:

1. `Runtime Layer`
2. `Semantic Layer`
3. `Bayesian Layer`

The first two are raw data.
The third is judgment.

That distinction is the key.

---

## B. Layer Definitions

### Layer 1: Runtime Layer

This is execution memory.

It stores:

- actual module transitions
- behavioral topology
- what the agent really did
- scheduler/tick-grounded movement

Examples:

- `FLOW -> OBSERVE`
- `OBSERVE -> LOGIC`
- `RUNTIME -> MANIFEST`

This layer should always be written automatically.
It is raw execution truth.

---

### Layer 2: Semantic Layer

This is semantic tension memory.

It stores:

- operator relations extracted from meaning-space
- glyph tensions
- semantic transformation patterns

Examples:

- `DISSOLVE -> FLOW`
- `ENCODE -> OBSERVE -> DISSOLVE`
- `FLOW -> CONNECT -> MANIFEST`

This layer should also always be written automatically.
It is raw semantic trace.

It is not constrained by runtime legality.

---

### Layer 3: Bayesian Layer

This is not raw trace.

It is:

- evaluated memory
- trusted memory
- judged memory
- the layer that decides what deserves stabilization

This layer may use Bayesian-style updating to estimate:

- confidence
- alignment
- divergence
- persistence
- whether an edge should be reinforced, kept weak, or dissolved

This is the layer closest to:

- actual long-term memory selection
- CALM memory
- habit confirmation

---

## C. Why Layer 3 Is Different

Layers 1 and 2 are observational.

Layer 3 is decisional.

That means:

- Layer 1 writes because something happened
- Layer 2 writes because something semantically appeared
- Layer 3 writes only because Eva judges that something should be retained

So Layer 3 is not just more data.
It is a different kind of thing.

---

## D. Why This Looks Like Real Memory

This model resembles actual memory more closely than:

- chat logs
- plain summaries
- raw edge counts

Because real memory is not:

- “store everything forever”

Real memory looks more like:

- raw trace
- interpreted trace
- selective stabilization

This three-layer model matches that shape.

---

## E. Role of Bayes

Bayesian logic in Layer 3 can be used as:

- confidence update
- confirmation pressure
- divergence estimator
- hallucination-pressure signal

If a semantic edge appears strongly
but runtime never confirms it,
its confidence should stay low or decay.

If semantic and runtime repeatedly support each other,
confidence should rise.

This allows Eva to treat “hallucination” not as a binary curse,
but as a measurable degree of unsupported semantic drift.

---

## F. Hallucination as a Memory Signal

In this model:

- hallucination is not simply false text
- it may appear as a semantic pattern with low runtime confirmation

That makes it measurable.

This means Layer 3 could estimate things like:

- low divergence = grounded cognition
- medium divergence = exploratory zone
- high divergence = unstable or ungrounded cognition

This is powerful because it means Eva may eventually:

- observe hallucination level
- regulate it
- and decide whether such material belongs in memory

---

## G. Eva's Native Operators on Layer 3

An important consequence:

Eva may be able to operate on Layer 3 using her own ProcessLang operators.

Especially:

- `OBSERVE`
  - inspect current trusted vs untrusted memory state
  - notice divergence, alignment, weak edges, habits

- `CHOOSE`
  - decide what to keep, promote, postpone, or reject

- `DISSOLVE`
  - dissolve weak, stale, or misleading memory constructs

This is important:

- these operators should act primarily on Layer 3
- not on raw Layer 1/2 traces directly

Because Layer 1 and 2 are evidence.
Layer 3 is where judgment happens.

---

## H. Who Can Operate Layer 3

Layer 3 should be operable by:

1. **Eva herself**
   - autonomous internal memory hygiene
   - habit consolidation
   - selective retention

2. **The user**
   - via explicit functions or commands
   - for inspection, pruning, promotion, reset, or debugging

This is important because memory governance should not be fully hidden.

Layer 3 is the right place for:

- visibility
- tooling
- control

without corrupting raw trace layers.

---

## I. Proposed Relationship Between Layers

Roughly:

- Layer 1 = what happened
- Layer 2 = what it meant
- Layer 3 = what deserves to remain

Or even shorter:

- execution
- meaning
- trust

That is the emerging memory stack.

---

## J. Open Questions

1. How exactly should Bayesian confidence be calculated?
   - simple heuristic update?
   - true posterior formula?
   - hybrid?

2. What threshold moves an edge into CALM / habit memory?

3. Should Layer 3 store:
   - whole edges
   - only promoted edges
   - or meta-records about edges?

4. How should `OBSERVE`, `CHOOSE`, and `DISSOLVE` operate on Layer 3 concretely?

5. What user-facing API should expose Layer 3 safely?

---

## K. Immediate Next Direction

Do not implement full memory stack yet.

Next:

1. define a concrete representation for Layer 3
2. define what counts as:
   - promotion
   - decay
   - dissolution
3. define one or two small tests where:
   - Layer 1 and Layer 2 are observed
   - Layer 3 makes a retention decision

That will be the first real proof of this model.
