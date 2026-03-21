# Eva LLM Provider Refactor

## Status

Planned and first-pass implementation target.  
March 18, 2026.

This document defines the minimal refactor needed to turn Eva from:

- a DeepSeek-bound agent

into:

- a ProcessLang orchestrator that can call multiple LLM substrates.

The immediate target is:

- `DeepSeek`
- `GLM-5`

without breaking the current public call shape:

```lua
llm.ask(messages, options)
```

---

## Why this refactor is needed

Current state:

- [core/llm.lua](/home/slasten/planGOD/core/llm.lua) is hard-wired to DeepSeek
- all higher Eva layers depend on that one substrate indirectly

That is too narrow for the next migration.

Eva should own:

- ProcessLang topology
- routing
- memory
- optics
- task framing

but not be fused to exactly one model provider.

---

## Refactor goal

Keep the current outer contract stable:

```lua
local response, err = llm.ask(messages, options)
```

But make the inside modular:

```text
core/llm.lua          -> facade
llm/deepseek.lua      -> DeepSeek provider
llm/glm.lua           -> GLM-5 provider
```

---

## Provider contract

Each provider should expose:

```lua
local provider = {}

function provider.ask(messages, options)
    -- returns:
    -- content_string
    -- or nil, error_string
end

return provider
```

No provider should know about:

- Packet
- optics
- scheduler
- RUNTIME memory

Provider layer is transport/adaptation only.

---

## Config model

Environment variables:

- `EVA_LLM_PROVIDER`
  - `deepseek`
  - `glm`
- `DEEPSEEK_API_KEY`
- `MODAL_GLM_API_KEY`

Default behavior:

- if `EVA_LLM_PROVIDER` is unset:
  - use `deepseek`

This keeps the old behavior working by default.

---

## DeepSeek provider

Move current logic from:

- [core/llm.lua](/home/slasten/planGOD/core/llm.lua)

to:

- `llm/deepseek.lua`

The request remains OpenAI-style:

- `messages`
- `temperature`
- optional `model`

Default model:

- `deepseek-chat`

---

## GLM provider

Add a new provider:

- `llm/glm.lua`

Based on the currently available Modal endpoint:

- `https://api.us-west-2.modal.direct/v1/chat/completions`

OpenAI-compatible request shape:

- `model`
- `messages`
- `max_tokens`
- `temperature`

Suggested defaults:

- model:
  - `zai-org/GLM-5-FP8`
- env key:
  - `MODAL_GLM_API_KEY`

---

## Non-goals of this pass

Not yet:

- automatic provider selection by task
- provider memory / routing habits
- fallback-on-error policy
- provider benchmarking
- streaming
- tool calling

This pass is only:

- modular provider support
- stable outer API
- no architectural breakage

---

## Future direction to remember

Later, Eva may learn:

- which provider is better for which class of task

That would be a higher-level `CHOOSE` + `RUNTIME` feature:

- provider-selection habits
- provider-specific strengths
- semantic routing memory

But that is not the first step.

First step:

- make multiple providers possible at all.

---

## Minimal implementation checklist

1. Create `llm/`
2. Add `llm/deepseek.lua`
3. Add `llm/glm.lua`
4. Turn `core/llm.lua` into provider facade
5. Preserve `llm.ask(messages, options)` outwardly
6. Keep DeepSeek as default if no provider selected
7. Return clear errors if key/provider is missing

---

## Working conclusion

This refactor is the correct first technical move for Eva.

It does not yet make Eva smarter.
It makes Eva less artificially narrow.

That is the right first condition
for later improving her ProcessLang reflection and agentic usefulness.

