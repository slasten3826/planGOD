Packet bare-core bridge for Eva

What was added:
- A minimal bare-Packet reference slice was copied from `/home/slasten/dev/packet3` into:
  - `/home/slasten/planGOD/workspace/packet_core_ref`
- The copied files are:
  - `core.h`
  - `runtime_internal.h`
  - `pa_cognitive.h`
  - `pa_cognitive.c`
  - `app.c`
  - `world_runtime.c`
  - `manifestation_runtime.c`
  - `packet_runtime.c`

Why:
- ASCII Packet reports remain useful as a human/debug manifestation.
- Eva also needs access to Packet before render, at the level of raw runtime state and cognitive projection.
- `pa_cognitive.h/.c` already define a machine-facing state layer above `PaApp`, especially:
  - `PaObserveResult`
  - `PaChooseResult`
  - `PaDissolveResult`
  - `PaCogState`

Driver additions:
- `drivers.packet.core_files()`
  - returns the copied bare-core file paths
- `drivers.packet.read_core(name)`
  - reads one allowed bare-core file by name
- `drivers.packet.core_bundle()`
  - returns the whole copied slice as one concatenated text bundle

Current interpretation:
- Packet is not stored as an explicit graph structure.
- It is a toroidal field machine with:
  - operator topology
  - manifestation/calm fields
  - entropy and density
  - packet/transition positions
- The nearest machine-facing non-render layer is not a graph dump but the cognitive projection in `pa_cognitive`.

Practical effect:
- Eva can now inspect Packet in two modes:
  - rendered/debug view via `drivers.packet.probe*`
  - bare core / cognitive view via `drivers.packet.read_core*`

Important:
- Because the sandbox API changed, Eva must be restarted before it can use the new `drivers.packet` functions.
