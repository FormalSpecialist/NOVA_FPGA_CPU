#!/usr/bin/env python3
"""Two-pass assembler for the 8-bit NOVA CPU's 16-bit instruction set."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


OPCODES = {
    "NOP": 0x0,
    "LDI": 0x1,
    "MOV": 0x2,
    "ADD": 0x3,
    "SUB": 0x4,
    "AND": 0x5,
    "OR": 0x6,
    "XOR": 0x7,
    "LD": 0x8,
    "ST": 0x9,
    "JMP": 0xA,
    "JZ": 0xB,
    "JC": 0xC,
    "SHL": 0xD,
    "SHR": 0xE,
    "HALT": 0xF,
}

NO_OPERAND = {"NOP", "HALT"}
THREE_REGISTER = {"ADD", "SUB", "AND", "OR", "XOR"}
TWO_REGISTER = {"MOV", "SHL", "SHR"}
MEMORY = {"LD", "ST"}
BRANCH = {"JMP", "JZ", "JC"}
LABEL_PATTERN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
REGISTER_PATTERN = re.compile(r"^[Rr]([0-7])$")


class AssemblerError(ValueError):
    """An assembly error containing a source-line number."""


@dataclass(frozen=True)
class SourceInstruction:
    line_number: int
    address: int
    text: str


@dataclass(frozen=True)
class AssemblyResult:
    words: list[int]
    labels: dict[str, int]
    instructions: list[SourceInstruction]


def _strip_comments(line: str) -> str:
    """Remove NOVA ';' and '//' comments without consuming '#10' immediates."""
    semicolon = line.find(";")
    slash = line.find("//")
    cut_positions = [position for position in (semicolon, slash) if position >= 0]
    if cut_positions:
        line = line[: min(cut_positions)]
    return line.strip()


def _tokenize(instruction: str) -> list[str]:
    return [token for token in re.split(r"[\s,]+", instruction.strip()) if token]


def _require_operands(
    mnemonic: str, operands: list[str], expected: int, line_number: int
) -> None:
    if len(operands) != expected:
        raise AssemblerError(
            f"line {line_number}: {mnemonic} expects {expected} operand(s), "
            f"but received {len(operands)}"
        )


def _parse_register(token: str, line_number: int) -> int:
    match = REGISTER_PATTERN.fullmatch(token)
    if match is None:
        raise AssemblerError(
            f"line {line_number}: expected register R0 through R7, got '{token}'"
        )
    return int(match.group(1))


def _parse_value(token: str, labels: dict[str, int], line_number: int) -> int:
    candidate = token[1:] if token.startswith("#") else token
    label_key = candidate.upper()
    if label_key in labels:
        value = labels[label_key]
    else:
        try:
            value = int(candidate, 0)
        except ValueError as error:
            raise AssemblerError(
                f"line {line_number}: unknown label or number '{token}'"
            ) from error

    if not 0 <= value <= 0xFF:
        raise AssemblerError(
            f"line {line_number}: value {value} is outside the 8-bit range 0..255"
        )
    return value


def _encode_instruction(
    source: SourceInstruction, labels: dict[str, int]
) -> int:
    tokens = _tokenize(source.text)
    mnemonic = tokens[0].upper()
    operands = tokens[1:]

    if mnemonic not in OPCODES:
        raise AssemblerError(
            f"line {source.line_number}: unknown instruction '{tokens[0]}'"
        )

    opcode = OPCODES[mnemonic] << 12

    if mnemonic in NO_OPERAND:
        _require_operands(mnemonic, operands, 0, source.line_number)
        return opcode

    if mnemonic == "LDI":
        _require_operands(mnemonic, operands, 2, source.line_number)
        destination = _parse_register(operands[0], source.line_number)
        immediate = _parse_value(operands[1], labels, source.line_number)
        return opcode | (destination << 9) | immediate

    if mnemonic in TWO_REGISTER:
        _require_operands(mnemonic, operands, 2, source.line_number)
        destination = _parse_register(operands[0], source.line_number)
        source_a = _parse_register(operands[1], source.line_number)
        return opcode | (destination << 9) | (source_a << 6)

    if mnemonic in THREE_REGISTER:
        _require_operands(mnemonic, operands, 3, source.line_number)
        destination = _parse_register(operands[0], source.line_number)
        source_a = _parse_register(operands[1], source.line_number)
        source_b = _parse_register(operands[2], source.line_number)
        return opcode | (destination << 9) | (source_a << 6) | (source_b << 3)

    if mnemonic in MEMORY:
        _require_operands(mnemonic, operands, 2, source.line_number)
        register = _parse_register(operands[0], source.line_number)
        address = _parse_value(operands[1], labels, source.line_number)
        return opcode | (register << 9) | address

    if mnemonic in BRANCH:
        _require_operands(mnemonic, operands, 1, source.line_number)
        address = _parse_value(operands[0], labels, source.line_number)
        return opcode | address

    raise AssemblerError(
        f"line {source.line_number}: encoder is missing instruction '{mnemonic}'"
    )


def assemble_text(source_text: str, depth: int = 256) -> AssemblyResult:
    """Assemble source text and return unpadded machine words plus symbol data."""
    if depth <= 0 or depth > 256:
        raise AssemblerError("memory depth must be between 1 and 256 words")

    labels: dict[str, int] = {}
    instructions: list[SourceInstruction] = []
    address = 0

    # Pass one assigns addresses to labels and records instruction source lines.
    for line_number, original_line in enumerate(source_text.splitlines(), start=1):
        line = _strip_comments(original_line)
        if not line:
            continue

        if ":" in line:
            label_text, line = line.split(":", 1)
            label = label_text.strip()
            if LABEL_PATTERN.fullmatch(label) is None:
                raise AssemblerError(
                    f"line {line_number}: invalid label name '{label}'"
                )
            label_key = label.upper()
            if label_key in labels:
                raise AssemblerError(
                    f"line {line_number}: duplicate label '{label}'"
                )
            labels[label_key] = address
            line = line.strip()

        if line:
            if address >= depth:
                raise AssemblerError(
                    f"line {line_number}: program exceeds {depth} instruction words"
                )
            instructions.append(SourceInstruction(line_number, address, line))
            address += 1

    # Pass two resolves labels and encodes every instruction.
    words = [_encode_instruction(source, labels) for source in instructions]
    return AssemblyResult(words, labels, instructions)


def write_memory_file(result: AssemblyResult, output_path: Path, depth: int) -> None:
    padded_words = result.words + [0x0000] * (depth - len(result.words))
    output_path.write_text(
        "".join(f"{word:04X}\n" for word in padded_words), encoding="ascii"
    )


def write_listing_file(result: AssemblyResult, listing_path: Path) -> None:
    rows = ["ADDR  WORD  SOURCE\n", "----  ----  ------\n"]
    for source, word in zip(result.instructions, result.words):
        rows.append(f"{source.address:02X}    {word:04X}  {source.text}\n")

    if result.labels:
        rows.append("\nSYMBOLS\n")
        rows.append("-------\n")
        for name, address in sorted(result.labels.items(), key=lambda item: item[1]):
            rows.append(f"{name:<16} {address:02X}\n")

    listing_path.write_text("".join(rows), encoding="utf-8")


def build_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="input NOVA assembly file")
    parser.add_argument(
        "-o", "--output", type=Path, help="output .mem file (default: source.mem)"
    )
    parser.add_argument("--listing", type=Path, help="optional human-readable listing")
    parser.add_argument(
        "--depth", type=int, default=256, help="ROM depth in words (default: 256)"
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_argument_parser().parse_args(argv)
    output_path = args.output or args.source.with_suffix(".mem")

    try:
        source_text = args.source.read_text(encoding="utf-8")
        result = assemble_text(source_text, args.depth)
        write_memory_file(result, output_path, args.depth)
        if args.listing is not None:
            write_listing_file(result, args.listing)
    except (AssemblerError, OSError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print(
        f"Assembled {len(result.words)} instruction(s) into "
        f"{output_path} ({args.depth} words)."
    )
    if result.labels:
        print(
            "Labels: "
            + ", ".join(
                f"{name}=0x{address:02X}"
                for name, address in sorted(
                    result.labels.items(), key=lambda item: item[1]
                )
            )
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
