# NOVA Assembler

| File | Role |
|---|---|
| `novaAssembler.py` | Two-pass assembler for the complete 16-instruction NOVA ISA |
| `test_novaAssembler.py` | Six Python unit tests for encodings, labels, errors, and ROM depth |

Python 3 is required; no third-party packages are used.

## Run the tests

From this folder:

```bash
python test_novaAssembler.py
```

Expected summary:

```text
Ran 6 tests
OK
```

## Assemble the hardware demo

From the repository root:

```text
python "Design Sources/PYTHON/novaAssembler.py" "Design Sources/MEMORY/sum_1_to_10.asm" -o "Design Sources/MEMORY/sum_1_to_10.mem" --listing "Design Sources/MEMORY/sum_1_to_10.lst"
```

The assembler accepts `;` or `//` comments, case-insensitive labels, registers `R0` through `R7`, decimal/hexadecimal 8-bit values, and an optional `#` prefix for immediate values. It rejects duplicate labels, invalid operands, values outside `0..255`, unknown instructions, and programs larger than the selected ROM depth.

The `.mem` output is padded to 256 words by default. The optional `.lst` output is for people and should not be added as a Vivado source.
