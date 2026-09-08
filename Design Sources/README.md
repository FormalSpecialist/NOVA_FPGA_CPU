# Design Sources

This directory contains the hand-maintained NOVA RTL, program image, and assembler. The `NOVA/` directory contains the Vivado project that references these files.

| Folder | Contents | Main dependencies |
|---|---|---|
| `ALU/` | Eight-operation ALU and candidate flags | `novaDefinitions.vh` |
| `BOARD/` | Button conditioning, CPU clock control, LEDs, and seven-segment output | `cpuCore`, `sevenSegmentDisplay` |
| `CU/` | Shared encodings, controller FSM, and integrated CPU | All datapath and storage modules |
| `MEMORY/` | Register file, PC, ROM, RAM, status register, demo top, and program artifacts | `sum_1_to_10.mem` |
| `PYTHON/` | Assembler and Python unit tests | Python 3 only |

## Integration hierarchy

```text
novaSumDemoTop
└── novaNexysA7
    ├── buttonConditioner
    ├── sevenSegmentDisplay
    └── cpuCore
        ├── cu
        ├── programCounter
        ├── instructionMemory
        ├── instructionRegister
        ├── registers
        ├── alu
        │   └── arithmeticFlags
        ├── statusRegister
        └── dataMemory
```

`novaDefinitions.vh` is the single source of truth for instruction opcodes, ALU selections, writeback selections, and controller states. Vivado must treat it as a Verilog header and make its directory available to modules that use `` `include "novaDefinitions.vh" ``.

## Selecting a top

| Goal | Top module | Constraint |
|---|---|---|
| Current hardware demo | `novaSumDemoTop` | `novaNexysA7_v3.xdc` |
| Reusable board wrapper | `novaNexysA7` | `novaNexysA7_v3.xdc` |
| Core-only synthesis | `cpuCore` | `cpuCore_synthesis_v1.xdc` |

The current ROM image is `MEMORY/sum_1_to_10.mem`. Keep it in the Vivado design source set for both synthesis and simulation so `$readmemh` can find it.
