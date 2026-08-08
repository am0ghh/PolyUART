# PolyUART

A UART (Universal Asynchronous Receiver/Transmitter) implemented in SystemVerilog and
verified in Xilinx Vivado, extended into a **one-to-many addressed topology**: a single
transmitter drives multiple address-selected receivers over one shared serial line.

That extension is the "Poly" in PolyUART — standard UART framing carrying a destination
address, so only the addressed receiver latches the byte. Conceptually it's the role SPI's
select lines play, done in the frame instead of with extra wires.

## Overview

UART is an asynchronous serial protocol widely used in RS-232 links and in microcontrollers
interfacing with sensors. Because it is asynchronous, the two endpoints do not share a clock;
instead they agree on a common **baud rate** and each side samples the line accordingly. This
implementation uses 16× oversampling on the receiver: the start edge is detected, re-checked
at the middle of the start bit to reject glitches, and each subsequent bit is then sampled at
its midpoint — which keeps the link robust against timing skew between two clocks that never
touch.

## Specification

| Parameter          | Value                            |
| ------------------ | -------------------------------- |
| Baud rate          | 115200 (default), 9600 capable   |
| Clock frequency    | 100 MHz                          |
| Oversampling rate  | 16×                              |
| Data bits          | 8, LSB first                     |
| Address bits       | `ADDR_BITS` (default 2 → 4 devices) |
| Parity             | None                             |
| Start / stop bits  | 1 / 1                            |
| Frame              | start + `ADDR_BITS` address + 8 data + stop (12 bits at the default width) |

The baud-rate divisor is `DIV = 53`, from `100 MHz / 115200 / 16 ≈ 54` clocks per
oversample tick.

Note that the addressed frame is **not** wire-compatible with a stock 8N1 UART peripheral —
the extra address bits sit between the start bit and the data byte, so both ends have to
speak PolyUART.

## Architecture

```
                +------------+  tick
   clk  ------> |  baud_gen  |----+-----------------------------+
   rst  ------> |            |    |                             |
                +------------+    v                             v
                            +-----------+              +------------------+
   data_in[7:0] ----------> |           |   tx_out     |  uart_rx (MY_ADDR=0) | --> rx_data[0]
   addr[N-1:0]  ----------> |  uart_tx  |------+-----> +------------------+
   tx_start     ----------> |           |      |       |  uart_rx (MY_ADDR=1) | --> rx_data[1]
                            +-----------+      +-----> +------------------+
                                  |            |       |        ...           |
                                  v            +-----> |  uart_rx (MY_ADDR=N) | --> rx_data[N]
                               tx_done                 +------------------+
                                              shared serial bus
```

`uart_top` instantiates one transmitter and `2**ADDR_BITS` receivers through a `generate`
loop, each with its own compile-time `MY_ADDR`, all listening on the same line. Every
receiver decodes the address field; only the match latches the data byte and pulses its
`rx_done`.

### Modules (`src/`)

| File            | Description                                                                 |
| --------------- | --------------------------------------------------------------------------- |
| `baud_gen.sv`   | Baud-rate generator. Produces a one-cycle `tick` every `DIV+1` clocks to drive the 16× oversampling. |
| `uart_tx.sv`    | Transmitter FSM (`IDLE → START → ADDR → DATA → STOP`). Shifts out the start bit, the address field LSB first, 8 data bits LSB first, and the stop bit. |
| `uart_rx.sv`    | Receiver FSM (`IDLE → START → ADDR → DATA → STOP`). Detects the start edge, samples at mid-bit, compares the received address against its `MY_ADDR` parameter, and deserializes into `data_out` only on a match. |
| `uart_top.sv`   | Top level. Parameterized by `ADDR_BITS` and `DIV`; instantiates `baud_gen`, one `uart_tx`, and `2**ADDR_BITS` addressed `uart_rx` instances on a shared line. |

### Testbenches (`sim/`)

| File               | Verifies                                                    |
| ------------------ | ---------------------------------------------------------- |
| `baud_gen_tb.sv`   | Tick generation / divisor timing.                          |
| `uart_tx_tb.sv`    | Full-frame transmission of `0x55` (uses a small divisor for fast simulation). |
| `uart_rx_tb.sv`    | Reception and deserialization of a driven frame back into `data_out`. |
| `uart_top_tb.sv`   | End-to-end multi-drop: sends `0xA5→addr 2`, `0x3C→addr 0`, `0x55→addr 3`, `0xF0→addr 1`, and checks that each byte is captured by only its addressed receiver. Frame timing is computed from the design parameters rather than hardcoded. |

## Documentation

Detailed project specifications, the state-machine design notes, and annotated simulation
waveforms are in [`docs/UART_Project_Specifications.pdf`](docs/UART_Project_Specifications.pdf).

## Simulation

Developed and simulated in **Xilinx Vivado**. Add the files in `src/` as design sources and
the files in `sim/` as simulation sources, then run behavioral simulation on the desired
testbench. Override `DIV` (e.g. to 2) in simulation to keep run times short.

## Current status

Behavioral simulation only — the design has not been synthesized or run on hardware, so there
are no Fmax, utilization, or timing-closure numbers yet. Next steps:

- Synthesize and report Fmax and LUT/FF utilization with a constraints file
- Simulate the real `DIV = 53` (115200 baud) configuration end to end
- Convert the testbenches to self-checking with assertions rather than `$display` inspection
- Bring the bus up on hardware over RS-485 transceivers
