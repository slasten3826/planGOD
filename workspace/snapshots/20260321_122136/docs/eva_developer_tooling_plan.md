# Eva Developer Tooling Plan

## Status

Planning note.  
March 19, 2026.

---

## A. Problem

Right now Eva testing is too manual.

Current workflow often requires:

- user enters prompt through web UI
- user copies response/logs back into chat
- developer reasons from pasted results

This is too slow and too lossy for real development.

---

## B. Goal

Codex should be able to test Eva more directly,
without relying on the user to manually shuttle prompts
through the browser interface.

This does **not** mean replacing Eva.
It means adding developer-facing tooling around Eva.

---

## C. Minimum Useful Dev Tools

### 1. CLI prompt runner

Ability to run one Eva prompt directly from terminal tooling and capture:

- final response
- dev trace
- runtime events

Without manual web UI interaction.

Example target usage:

```bash
lua tools/eva_run.lua --prompt "..." --dev
```

---

### 2. Scenario runner

Ability to run a fixed set of prompts as one test pack.

Useful for:

- epistemic honesty checks
- retrieval checks
- memory checks
- prompt regression checks

---

### 3. Trace collector

Automatic capture of:

- `workspace/observe_trace.log`
- final response
- llm errors
- maybe prompt sections

into one debug artifact.

---

### 4. Comparison runner

Ability to run same test prompt(s) under:

- different providers
- different prompt assembly modes
- different memory injections

This is especially important after prompt refactor begins.

---

## D. Why This Matters Now

Upcoming work will require repeated testing of:

- bootloader vs assembler behavior
- prompt length reductions
- memory slices
- layered graph prompt insertion

Trying to do all of this through browser copy/paste is wasteful.

---

## E. First Safe Tool

The first tool should be the smallest one:

- one-shot CLI Eva runner

Not a giant test framework.

Why:

- smallest integration risk
- immediate payoff
- easiest way to remove web UI dependency

---

## F. Likely Implementation Shape

Possible path:

- extract the current loop in [main.lua](/home/slasten/planGOD/main.lua) into a reusable function
- make web UI and CLI both call that same path

This avoids forking Eva behavior into:

- web Eva
- terminal Eva

There should be one Eva execution path,
multiple frontends.

---

## G. First Tooling Deliverables

1. `tools/eva_run.lua`
2. reusable session runner in core/module layer
3. artifact capture for response + trace

Only after that:

- scenario packs
- regression suites
- automated comparisons

---

## H. Key Principle

Do not build “testing around the web UI”.
Build:

- one Eva execution path
- multiple developer entry points

That is the correct architecture.
