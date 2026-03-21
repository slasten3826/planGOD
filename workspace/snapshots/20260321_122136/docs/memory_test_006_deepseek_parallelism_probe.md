# Memory Test 006: DeepSeek Parallelism Probe

## Status

Planned.  
March 19, 2026.

---

## A. Hypothesis

`DeepSeek` should tolerate a small amount of parallel request load for `memory_lab`
without immediate collapse in:

- transport stability
- practical latency
- or response validity

The goal is not to prove infinite scalability.
The goal is to find a safe working parallelism level for current memory experiments.

---

## B. Why This Test Exists

Sequential `DeepSeek` testing works,
but long repeat-series become slow.

Before parallelizing actual memory runs,
we need to know whether small parallel request batches such as:

- `5`
- `10`

are stable enough to use.

This is a transport/execution probe first,
not a semantic memory verdict.

---

## C. Environment

- Provider: `deepseek`
- Model: `deepseek-chat`
- Probe style:
  - identical or near-identical small requests
  - concurrent batch launch
- Planned batch sizes:
  - `5`
  - `10`

---

## D. Test Steps

1. Build a minimal DeepSeek parallel probe runner
2. Launch a batch of `5` parallel requests
3. Record:
  - success count
  - failures
  - approximate latency spread
4. If stable, repeat with `10`
5. Record verdict here

---

## E. Expected Signals

### Success

- all or nearly all requests succeed
- no immediate rate-limit wall
- latencies remain acceptable

### Partial Success

- some failures or heavy slowdown appear
- but a smaller parallel level is still usable

### Failure

- parallel requests immediately destabilize
- or transport errors dominate

---

## F. Results

Run completed.

Artifacts:

- [20260319_110251_deepseek_parallel_probe_5.jsonl](/home/slasten/planGOD/memory_lab/runs/20260319_110251_deepseek_parallel_probe_5.jsonl)
- [20260319_110311_deepseek_parallel_probe_10.jsonl](/home/slasten/planGOD/memory_lab/runs/20260319_110311_deepseek_parallel_probe_10.jsonl)

Observed results:

### Batch size `5`

- success: `5/5`
- failure: `0`
- wall time: `~7.96s`
- per-request latency: roughly `6.66s` to `7.92s`

### Batch size `10`

- success: `10/10`
- failure: `0`
- wall time: `~7.83s`
- per-request latency: roughly `6.38s` to `7.83s`

Important practical reading:

- doubling batch size from `5` to `10` did not produce collapse
- wall time stayed near the same range
- this strongly suggests that small-to-medium DeepSeek parallelism is viable for current memory research

Semantic note:

- probe outputs remained valid and coherent under parallel load
- no obvious degradation or malformed responses appeared in the probe itself

---

## G. Verdict

`works`

---

## H. Notes / Next Step

`DeepSeek` can currently handle at least `10` parallel requests cleanly in this probe setup.

Next step:

- switch future long `DeepSeek` memory runs from sequential to chunked parallel execution
- keep chunk size conservative at first, but `10` is already validated
- only revisit higher parallelism if needed
