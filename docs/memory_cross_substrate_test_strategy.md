# Memory Cross-Substrate Test Strategy

## Status

Working strategy note.  
March 19, 2026.

This document fixes one methodological decision:

- memory tests across different substrates should be run separately

Not as one giant combined run.

---

## 1. Why Split By Substrate

The current candidate substrates are:

- local `ollama` / `llama3.1:8b`
- `DeepSeek`
- `GLM`

These are not just different models.
They are different execution environments with different failure modes:

- latency
- transport
- reliability
- prompt sensitivity
- output style

If we combine them into one run,
the result becomes noisy and harder to debug.

---

## 2. Working Rule

Each substrate gets:

- its own run
- its own result document
- its own raw artifact

Then comparison happens later, at the document layer.

This keeps:

- failures isolated
- repetition easy
- reasoning clear

---

## 3. Roles Of Current Substrates

### Local `llama3.1:8b`

Role:

- lower-bound stress test
- harsh environment
- useful to detect fragile anchors

Not the final judge of Eva memory.

### DeepSeek

Role:

- primary next external substrate
- practical strong-model comparison

### GLM

Role:

- secondary external substrate
- useful for cross-family confirmation
- but must be treated carefully due to prior endpoint instability

---

## 4. Sequence

Current order:

1. local reference runs
2. DeepSeek run
3. GLM run
4. later cross-substrate comparison note

This means:

- local research continues to matter
- but external stronger models now become the next serious checkpoint

---

## 5. Bottom Line

Cross-substrate memory testing should be:

- one hypothesis
- multiple separate executions
- one later comparison layer

This is cleaner than one combined mega-run.
