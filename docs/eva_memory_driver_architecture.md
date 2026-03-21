# Eva.Memory As Driver

## Status

Accepted architectural direction.

`Eva.Memory` is **not** a separate manifestation of Eva.
It is **not** a demon.
It is **not** an autonomous entity.

`Eva.Memory` is a **driver / executor function inside Eva.Core**.

## Core Rule

There is only one real demon:

- `Eva.Core`

Everything else is either:

- manifestation called by user
- internal service called by `Eva.Core`

`Eva.Memory` belongs to the second category.

## What Eva.Memory Is

`Eva.Memory` is a narrow machine-facing driver that operates memory.

Its job is:

- read memory
- write memory
- prepare memory context
- return memory stats
- later support new memory layers without changing `Eva.Core`

It should be:

- narrow
- explicit
- deterministic
- boring in the good sense

## What Eva.Memory Is Not

`Eva.Memory` should not:

- decide truth
- decide what Eva means
- behave like a second Eva
- run as its own daemon
- become a hidden autonomous intelligence

All meaning decisions belong to:

- `Eva.Core`
- later the higher manifestations using `Eva.Core`

`Eva.Memory` only executes memory operations.

## Why Read Also Goes Through Eva.Memory

Reading memory should also go only through `Eva.Memory`.

This means:

- `Eva.Core` does not access history directly
- `Eva.Core` does not access residues directly
- `Eva.Core` does not access runtime storage directly
- future Packet memory also goes through the same driver

This makes the architecture cleaner for the machine:

- one memory contract
- one debug point
- one replacement point
- less hidden coupling

It may feel less convenient for a human,
but it is much cleaner for Eva as a machine.

## Relationship With Eva.Core

The correct relationship is:

- `Eva.Core` decides **when** and **why**
- `Eva.Memory` decides only **how**

So:

- `Eva.Core` asks for memory load
- `Eva.Memory` loads
- `Eva.Core` asks for memory context
- `Eva.Memory` assembles
- `Eva.Core` asks for commit
- `Eva.Memory` writes

## Behavioral Model

Inside Eva, `Eva.Memory` behaves like a driver with three operations:

- `load`
- `context`
- `commit`

Possible support operations:

- `stats`
- `clear`
- `trim`
- later `retrieve`

But the main idea stays:

- no autonomy
- no interpretation authority
- only memory execution

## Architectural Outcome

Correct stack:

- `Layer 0` = provider substrate
- `Layer 1` = `Eva.Core`
- inside `Eva.Core`:
  - `Eva.Memory` as driver
  - debug as technical trace
  - Packet access
  - routing

So `Eva.Memory` is not above Eva,
not beside Eva,
but **inside Eva.Core as a memory operator**.

## Long-Term Advantage

This allows future changes without tearing Eva apart:

- reduce human memory
- add Packet Layer 1 memory
- evolve residue logic
- change retrieval strategy
- replace storage layout

All of that can happen behind one interface:

- `Eva.Memory`

This is the main reason to build it as a driver now.
