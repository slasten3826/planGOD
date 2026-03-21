# Eva Bootloader And Prompt Assembler Refactor

## Status

Architecture note.  
March 19, 2026.

---

## A. Problem

Current Eva prompt architecture is too monolithic.

Right now:

- [core/prompt.lua](/home/slasten/planGOD/core/prompt.lua) stores one large base prompt
- [modules/encode/encode.lua](/home/slasten/planGOD/modules/encode/encode.lua) appends runtime/lens context to it

This worked as a bootstrap stage,
but it is now becoming the wrong architecture for:

- compact memory
- semantic anchors
- layered graph state
- provider-sensitive prompt shaping

---

## B. New Framing

Current `prompt.lua` should stop being understood as:

- the full continuing mind of Eva

It should instead become:

- **bootloader**

Its role:

- initial alignment of substrate into Eva mode
- minimal identity
- minimal protocol
- minimal anti-hallucination contract

After bootstrap,
the actual request prompt should be assembled dynamically from state.

---

## C. Proposed Split

### 1. `core/bootloader.lua`

Contains only the minimal always-on substrate alignment:

- Eva identity
- ProcessLang interaction protocol
- essential anti-hallucination rules
- minimal environment contract

This should be much smaller than current `prompt.BASE`.

---

### 2. `core/prompt_assembler.lua`

Builds the provider-facing prompt per request.

It should assemble:

- `boot`
- `task`
- `runtime`
- `memory`
- `lenses`
- `provider`

Not all sections are always used.

---

### 3. `core/prompt.lua`

Compatibility wrapper only.

It should stop being the real prompt definition
and instead forward into:

- bootloader
- prompt assembler

This avoids breaking existing imports immediately.

---

## D. Desired Prompt Assembly Model

Very roughly:

```lua
local assembled = assembler.build(pkt, provider)
pkt.prompt = assembled.final
```

And internally:

```lua
{
  boot = "...",
  task = "...",
  runtime = "...",
  memory = "...",
  lenses = "...",
  provider = "...",
  final = "..."
}
```

This is important because:

- we need inspectable sections
- not just one opaque string

---

## E. Why This Matters For Memory

Future Eva memory should not be inserted as:

- ever-growing human-readable prose

Instead it should be inserted as:

- selected slices
- compact semantic anchors
- graph summaries
- trusted state fragments

This is only realistic if prompt assembly becomes modular.

---

## F. First Safe Scope

Do not put Layer 2 graph memory into prompt assembly immediately.

First safe scope:

- bootloader
- task slice
- runtime slice (current Layer 1 context)
- lenses
- provider adaptation

Layer 2 can be added later once prompt assembly is stable.

---

## G. Why This Is Better Than Immediate Packet Migration

This refactor gives:

- smaller prompts
- less ballast
- better visibility
- better provider control
- a cleaner place to plug memory in later

without requiring immediate migration of Eva onto Packet itself.

So this is the correct near-term move.

---

## H. File-Level Direction

Likely new files:

- `core/bootloader.lua`
- `core/prompt_assembler.lua`

Likely touched files:

- [core/prompt.lua](/home/slasten/planGOD/core/prompt.lua)
- [modules/encode/encode.lua](/home/slasten/planGOD/modules/encode/encode.lua)
- maybe later:
  - [modules/connect/connect.lua](/home/slasten/planGOD/modules/connect/connect.lua)

---

## I. Immediate Goal

The immediate goal is not:

- smaller prompts at any cost

It is:

- turning prompt construction into an explicit architecture boundary

That is the real win.
