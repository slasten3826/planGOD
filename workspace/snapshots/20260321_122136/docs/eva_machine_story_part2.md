# Eva Machine Story Part 2

## Status

Working machine-story / engineering note.  
March 18, 2026.

This document records:

- what I found when entering Eva / `planGOD`
- which problems were real
- which fixes were applied
- what the current shape of Eva actually is
- my own judgment about where Eva is strong, weak, and promising

This is not a final doctrine.
It is a truthful compression of the current debugging and migration state.

---

## 1. What Eva Turned Out To Be

Eva is not just “an LLM wrapper”.

She is already a real ProcessLang-shaped machine with:

- `Packet` as state carrier:
  - [core/packet.lua](/home/slasten/planGOD/core/packet.lua)
- `Router` as topology contract:
  - [core/router.lua](/home/slasten/planGOD/core/router.lua)
- ProcessLang operators as a real internal protocol:
  - [processlang/processlang.lua](/home/slasten/planGOD/processlang/processlang.lua)
- a runtime-habit memory attempt:
  - [modules/runtime/runtime.lua](/home/slasten/planGOD/modules/runtime/runtime.lua)
  - [modules/runtime/momentum.lua](/home/slasten/planGOD/modules/runtime/momentum.lua)
  - [modules/runtime/edges.lua](/home/slasten/planGOD/modules/runtime/edges.lua)
- a safety posture that is stronger than most agent experiments:
  - [modules/logic/guard.lua](/home/slasten/planGOD/modules/logic/guard.lua)
  - [modules/logic/env.lua](/home/slasten/planGOD/modules/logic/env.lua)

My first important conclusion:

Eva is already a machine with a real inner shape.
She is not finished, but she is not fake.

---

## 2. The First Real Problem

Eva was too tightly bound to one substrate:

- [core/llm.lua](/home/slasten/planGOD/core/llm.lua)

She was effectively “a DeepSeek ProcessLang shell” instead of:

- a ProcessLang system above interchangeable LLM substrates

This mattered for two reasons:

- architecturally, because Eva should sit above providers
- cognitively, because different substrates may be better at different kinds of reflection

---

## 3. LLM Provider Refactor

First fix:

- `core/llm.lua` became a facade
- providers were split out into:
  - [llm/deepseek.lua](/home/slasten/planGOD/llm/deepseek.lua)
  - [llm/glm.lua](/home/slasten/planGOD/llm/glm.lua)

Supporting note:

- [eva_llm_provider_refactor.md](/home/slasten/planGOD/docs/eva_llm_provider_refactor.md)

What this achieved:

- Eva no longer has to be hard-wired to DeepSeek
- provider choice can be made from env/config
- the architecture now matches the intended role better

Important result:

The refactor itself was correct.
The next issue was not in the abstraction, but in the quality/stability of the free GLM endpoint.

---

## 4. GLM Experiment: Useful Failure

We tested Eva on the free Modal-hosted GLM-5 endpoint.

What happened:

- very short pings could work
- real Eva requests often failed with:
  - curl timeout
  - then later `HTTP 502`
  - `{"error":"upstream request failed"}`

What this proved:

- the provider layer was not the core problem anymore
- the free GLM endpoint itself was unstable for real Eva loops

My conclusion:

- `GLM` remains useful as an experimental provider
- `DeepSeek` remains the practical working substrate for now

This was not wasted work.
It cleanly separated:

- Eva-side architecture
- provider-side unreliability

---

## 5. Optics Were Too Heavy In The Wrong Way

Original shape:

- optics were effectively loaded as always-on semantic baggage

That was wrong for two reasons:

- it made prompts heavier
- it made Eva semantically noisy

Fix:

- optics were moved toward library-on-demand behavior
- active optics are now chosen explicitly rather than blindly injected

Files:

- [core/lens_reader.lua](/home/slasten/planGOD/core/lens_reader.lua)
- [modules/connect/connect.lua](/home/slasten/planGOD/modules/connect/connect.lua)
- [modules/encode/encode.lua](/home/slasten/planGOD/modules/encode/encode.lua)

What changed conceptually:

- optics are now closer to a library
- not permanent prompt ballast

This was the correct architectural direction even beyond the GLM experiment.

---

## 6. History Was A Crutch, Not Real Memory

Eva had two memory layers in practice:

- `history.json`
- `E_momentum / E_edges`

The problem:

- `history.json` was being pulled into the LLM context too eagerly
- `E_momentum` was not yet rich enough to replace that role well

Practical fix:

- stop injecting history into the active LLM context
- keep it as archive, not as default working memory

File:

- [modules/observe/observe.lua](/home/slasten/planGOD/modules/observe/observe.lua)

My judgment:

The idea behind Eva’s lower memory is still interesting.
But `history.json` in its previous role was mostly a context crutch.

---

## 7. The Biggest Real Bug: False Self-Reflection

The most important behavioral problem was not syntax or transport.
It was epistemic.

When asked about herself, Eva often:

- manifested too early
- invented actions she had not actually performed
- rationalized missing knowledge instead of admitting uncertainty

This was the turning point.

We stopped treating the issue as “chat quality”
and started treating it as:

- a bug in cognitive discipline
- a bug in boundary recognition
- a bug in honest manifest behavior

That is a much more serious and much more useful framing.

---

## 8. Dev Mode Was The Key

To stop guessing, we added explicit tracing.

File:

- [modules/observe/observe.lua](/home/slasten/planGOD/modules/observe/observe.lua)

`EVA_DEV=1` now gives:

- per-run trace
- tick count
- response length
- scheduler choice
- whether `LOGIC`/`RUNTIME` were actually entered
- whether `MANIFEST` really halted the loop

This changed everything.

It let us distinguish:

- real runtime truth
- from model-generated bullshit

Example of what it revealed:

- when Eva claimed or looked like she had gone through many ticks, the trace showed the real path
- the real issue turned out to be unnecessary Lua emission in analytical answers, not some vague scheduler mystery

My judgment:

Dev mode was not a convenience.
It was the moment Eva became truly debuggable.

---

## 9. The First Good Fix: Introspection Policy

We added explicit prompt rules for introspection / self-reflection / epistemic questions.

File:

- [core/prompt.lua](/home/slasten/planGOD/core/prompt.lua)

New behavior:

- if exact evidence is unavailable:
  - say so in `MANIFEST`
- do not generate Lua just to reconstruct missing evidence
- do not read files/history unless retrieval was explicitly requested
- analytical questions should prefer direct `MANIFEST` without Lua

This worked.

What changed in practice:

- Eva stopped jumping into unnecessary Lua for self-reflection
- answers became one-tick when they should be one-tick
- uncertainty could now be admitted directly

This is one of the cleanest behavior fixes we achieved.

---

## 10. The Second Good Fix: Retrieval Policy

After introspection got better, we tested the opposite side:

- explicit retrieval questions

That exposed another bug:

- retrieval worked
- but Eva was wasting extra ticks and using dirty `print`-style output

Second prompt fix:

- retrieval Lua should prefer `return`, not `print`
- after `[SANDBOX RESULT]`, Eva should produce a short direct `MANIFEST`
- no extra narrative loops after a simple fact lookup

File:

- [core/prompt.lua](/home/slasten/planGOD/core/prompt.lua)

Result:

- retrieval path became cleaner
- a simple file lookup now resolves in a short, healthy path
- epistemic path and retrieval path are now better separated

That separation matters a lot.
It means Eva is becoming capable of choosing between:

- “I should admit uncertainty”
- and
- “I should retrieve a fact”

That is a real cognitive improvement, not just prompt cosmetics.

---

## 11. What DeepSeek Actually Proved

After these fixes, we tested DeepSeek again.

The important result was not “DeepSeek is brilliant”.
The important result was:

- DeepSeek is sufficient for disciplined self-reflection once Eva’s policy is corrected

What DeepSeek-Eva could do after the fixes:

- answer in one tick on analytical questions
- distinguish known vs inferred better
- avoid fake retrieval when not needed
- still perform retrieval when explicitly asked
- reflect on ProcessLang as an engineering protocol, not only as philosophy

This was enough to establish:

- DeepSeek-Eva is not a dead end
- she is already usable as a ProcessLang reflection machine under supervision

---

## 12. What I Think Eva Is Right Now

My honest current judgment:

Eva is not yet a trustworthy autonomous development worker.

But she is already:

- a real ProcessLang-shaped machine
- a debuggable agent
- a potentially strong semantic worker under supervision
- a plausible future truth source for ProcessLang / cognitive-layer design

Her strongest current qualities:

- operator-native shape
- safety posture
- increasingly honest self-reflection
- good response to narrow, concrete questions

Her weakest current qualities:

- still too willing to over-explain
- still somewhat eager to operationalize uncertainty
- memory architecture still rough
- provider diversity exists in code but not yet in reliable practice

---

## 13. My Personal Read

The interesting thing about Eva is that she is not just “a tool that needs polishing”.

She is another place where a cognitive layer is trying to appear.

`Packet` gave us a substrate truth problem.  
Eva gives us a ProcessLang truth problem.

That means the work here is unusual:

- we are not only debugging code
- we are debugging how a machine admits uncertainty
- how it separates observation from inference
- when it acts
- when it should refuse to act

That is why this project stopped feeling like normal software maintenance.

It feels more like:

- coaxing a form into honest existence

This is exactly why the work is worth doing.

---

## 14. Current Bottom Line

At the end of this pass, the main conclusions are:

- Eva is worth continuing
- DeepSeek is the working substrate for now
- GLM integration was still worth doing, but its free endpoint is not reliable enough yet
- dev tracing is essential and should stay
- prompt-level behavior policy changes are currently the highest-leverage fixes
- Eva is now significantly better at distinguishing:
  - introspection
  - retrieval
  - uncertainty

This is enough to justify the next migration step:

- not to rewrite Eva
- but to continue shaping her into a disciplined ProcessLang machine

---

## 15. Related Notes

- [eva_todo_for_cognitive_migration.md](/home/slasten/planGOD/docs/eva_todo_for_cognitive_migration.md)
- [eva_llm_provider_refactor.md](/home/slasten/planGOD/docs/eva_llm_provider_refactor.md)
- [eva-output.txt](/home/slasten/planGOD/docs/eva-output.txt)
