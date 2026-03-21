# Eva PacketCLI2Machine Bridge

## Status

Prepared first integration bridge.  
March 19, 2026.

---

## 1. Goal

Give Eva a real machine-facing way to inspect Packet runtime now, without
waiting for full Slastris integration.

The target repository already exists:

- `/home/slasten/dev/packet3/packetcli2machine`

This repository is explicitly machine-oriented and already provides a stable
entrypoint for another machine:

- `python3 packet_machine/packet_machine_render.py`

---

## 2. Why This Is The Right First Integration

Eva does not need raw TTY control over `packet_cli` first.

It needs:

- a stable way to trigger runtime
- a stable report format
- a clean observation surface

`packet_machine_render.py` already provides exactly that.

So the first integration should be:

- report-based machine observation

not:

- raw terminal wrestling

---

## 3. First Bridge Shape

Eva should be able to do one thing:

1. run Packet machine render with a command script
2. receive path to the generated report
3. inspect the report
4. reason about Packet state and behavior

This is enough for first usefulness.

---

## 4. Recommended Entry

Canonical runtime bridge:

```bash
cd /home/slasten/dev/packet3/packetcli2machine
python3 packet_machine/packet_machine_render.py --commands "n,QUIT"
```

For Eva-facing tooling, a wrapper should:

- isolate this call
- write reports into a known workspace folder
- expose command string + report path

---

## 5. What Eva Can Do With This

Once this bridge exists, Eva can already:

- inspect startup state
- inspect post-tick state
- compare multiple command scripts
- reason about runtime behavior
- help debug Packet Adventure

This is enough to make Eva a real Packet co-developer.

---

## 6. What Not To Do Yet

Not yet:

- full interactive Packet control from inside Eva
- full MCP bridge
- Packet write-side mutation through Eva
- long-running orchestration over Packet runtime

First we need clean observation.

---

## 7. Bottom Line

The correct first Packet integration is:

- **Eva -> packetcli2machine machine render -> report -> reasoning**

That is small, real, and immediately useful.
