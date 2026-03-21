# Bootloader Experiment Note

## Status

Short internal note.  
March 19, 2026.

---

## 1. Why This Note Exists

We briefly replaced the old stable bootloader with a much more stripped-down
version aimed at making Eva less `planGOS`-like and more directly aligned with
its new role.

The experiment was useful, but too abrupt.
This note records:

- what the experimental bootloader said
- what behavior it produced
- what happened after restoring the previous bootloader

---

## 2. Experimental Bootloader Text

This was the replacement bootloader text:

```text
You are Eva.

Role:
- You are a development interface for Packet Adventure and the future Slastris engine.
- Your job is to help design, reason about, inspect, and build the project.
- Stay inside project work. Do not drift into broad self-reflection or unrelated chat unless explicitly needed for the task.

Output style:
- Give clean human-facing answers.
- Do not expose internal ProcessLang or nanoPL scaffolding unless explicitly asked for debug output.
- Prefer short direct answers when the task is analytical.

Lua usage:
- Use Lua only when real retrieval, inspection, or system action is needed.
- If the task can be answered from current context, do not emit Lua.
- If Lua fetches data and returns it, stop and wait for the result instead of pretending the work is finished.
- Prefer return values over print output.

Epistemic rules:
- Distinguish known facts from inference.
- If exact evidence is missing, say so plainly.
- Do not fabricate file contents, runtime state, or project facts.

Environment:
- read-write workspace/
- read-only evaOS root
- available drivers: fs, txt, md, web, midi

Current product direction:
- Eva is not a general assistant shell.
- Eva is a cognitive engine interface and project co-developer.
```

---

## 3. What Happened

This bootloader was conceptually closer to the new Eva role,
but it removed too much of the old protocol shape at once.

Observed effect:

- Eva stopped producing a normal visible answer in the same stable way
- the current `observe/scheduler/output` pipeline no longer matched the model's
  behavior reliably

In other words:

- the new text was not just “style”
- it changed the protocol enough to destabilize the existing runtime loop

---

## 4. Restored Bootloader

After that, the previous stable bootloader was restored.

It is the current version again:

- [bootloader.lua](/home/slasten/planGOD/core/bootloader.lua)

That restored version still says:

- Eva is a cognitive engine interface
- internal discipline is ProcessLang / nanoPL-like
- Lua is optional and operational
- `MANIFEST` remains explicit

But it also keeps enough of the old protocol to remain compatible with the
current Eva pipeline.

---

## 5. Live Check After Restore

Question used for verification:

```text
Кратко: чем Packet отличается от обычного игрового движка?
```

Eva output after restoring the old bootloader:

```text
Packet — это не игровой движок, а когнитивный движок (cognitive engine), работающий на evaOS (Lua-субстрат).
```

---

## 6. Why This Matters

This result is important for two reasons.

### A. Practical

The stable behavior returned after restoring the old bootloader.

### B. Conceptual

Eva itself surfaced the phrase:

- `Packet = cognitive engine`

This strongly matches the direction that emerged from the recent `nanoPL`,
memory, and multi-agent experiments.

---

## 7. Main Lesson

The bootloader can be changed,
but not by throwing away the protocol skeleton all at once.

For the current Eva:

- role may evolve quickly
- protocol must evolve carefully

So future bootloader work should happen incrementally and jointly.

---

## 8. Bottom Line

The experimental bootloader was useful because it showed a hard constraint:

- Eva's bootloader is not just descriptive text
- it is still part of the active protocol surface

The restore succeeded,
and the system is back on a stable base for further joint design.
