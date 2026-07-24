# PolyUART

A UART (Universal Asynchronous Receiver/Transmitter) implemented in SystemVerilog and
verified in Xilinx Vivado.

## Project Roadmap

> **Current stage — Standard UART.**
> This stage of the project implements a conventional point-to-point UART: a transmitter,
> a receiver, and a baud-rate generator that let a single pair of devices exchange bytes
> asynchronously over a shared baud rate.

> **Next phase — Multi-device communication (the "Poly" in PolyUART).**
> The goal of the next phase is to extend this core so it can address and communicate with
> *multiple* devices on a shared bus — conceptually similar to how SPI uses select lines to
> talk to many peripherals from one controller. Hence the name **PolyUART**: standard UART
> framing, extended to a one-to-many topology.

## Overview

UART is an asynchronous serial protocol widely used in RS-232 links and in microcontrollers
interfacing with sensors. Because it is asynchronous, the two endpoints do not share a clock;
instead they agree on a common **baud rate** and each side samples the line accordingly. This
implementation uses 16× oversampling on the receiver so the incoming bit stream is sampled
near the middle of each bit for robustness against timing skew.

## Specification

| Parameter          | Value                          |
| ------------------ | ------------------------------ |
| Baud rate          | 115200 (default), 9600 capable |
| Data bits          | 8                              |
| Parity             | None                           |
| Start bit          | 1                              |
| Stop bit           | 1                              |
| Clock frequency    | 100 MHz                        |
| Oversampling rate  | 16×                            |

The baud-rate divisor is `DIV = 53`, from `100 MHz / 115200 / 16 ≈ 54` clocks per
oversample tick.

## Architecture

```
                +------------+
   clk  ------> |            | tick
   rst  ------> |  baud_gen  |------+-------------------+
                |            |      |                   |
                +------------+      v                   v
                              +-----------+       +-----------+
   data_in[7:0] ------------> |  uart_tx  |       |  uart_rx  | --> data_out[7:0]
   tx_start  ---------------> |           | tx_out|           | <-- rx_in
                              +-----------+       +-----------+ --> rx_done_tick
                                    |
                                    v
                                 tx_done_tick
```

### Modules (`src/`)

| File            | Description                                                                 |
| --------------- | --------------------------------------------------------------------------- |
| `baud_gen.sv`   | Baud-rate generator. Produces a one-cycle `tick` every `DIV+1` clocks to drive the 16× oversampling. |
| `uart_tx.sv`    | Transmitter FSM (`IDLE → START → DATA → STOP`). Shifts out start bit, 8 data bits (LSB first), and stop bit. |
| `uart_rx.sv`    | Receiver FSM (`IDLE → START → DATA → STOP`). Detects the start edge, samples at the mid-bit, and deserializes into `data_out`. |
| `uart_top.sv`   | Top-level wrapper instantiating `baud_gen`, `uart_tx`, and `uart_rx`.       |

### Testbenches (`sim/`)

| File               | Verifies                                                    |
| ------------------ | ---------------------------------------------------------- |
| `baud_gen_tb.sv`   | Tick generation / divisor timing.                         |
| `uart_tx_tb.sv`    | Full-frame transmission of `0x55` (uses a small divisor for fast simulation). |
| `uart_rx_tb.sv`    | Reception and deserialization of a driven frame back into `data_out`. |

## Documentation

Detailed project specifications, the state-machine design notes, and annotated simulation
waveforms are in [`docs/UART_Project_Specifications.pdf`](docs/UART_Project_Specifications.pdf).

## Simulation

The design was developed and simulated in **Xilinx Vivado**. Add the files in `src/` as design
sources and the files in `sim/` as simulation sources, then run behavioral simulation on the
desired testbench.
