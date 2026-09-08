#!/usr/bin/env python3

import unittest

from novaAssembler import AssemblerError, assemble_text


class NovaAssemblerTests(unittest.TestCase):
    def test_summation_program_machine_code(self):
        source = """
            LDI R1, 10
            LDI R2, 0
            LDI R3, 1
        loop:
            ADD R2, R2, R1
            SUB R1, R1, R3
            JZ done
            JMP loop
        done:
            ST R2, 0x10
            LD R4, 0x10
            ADD R5, R4, R0
            HALT
        """
        result = assemble_text(source)
        self.assertEqual(
            result.words,
            [
                0x120A,
                0x1400,
                0x1601,
                0x3488,
                0x4258,
                0xB007,
                0xA003,
                0x9410,
                0x8810,
                0x3B00,
                0xF000,
            ],
        )
        self.assertEqual(result.labels, {"LOOP": 0x03, "DONE": 0x07})

    def test_all_sixteen_opcodes(self):
        source = """
        start: NOP
               LDI  R1, #0x2A
               MOV  R2, R1
               ADD  R3, R1, R2
               SUB  R4, R3, R1
               AND  R5, R4, R3
               OR   R6, R5, R4
               XOR  R7, R6, R5
               LD   R0, 0x80
               ST   R7, 0x81
               JMP  start
               JZ   0x10
               JC   0x20
               SHL  R1, R2
               SHR  R3, R4
               HALT
        """
        result = assemble_text(source)
        self.assertEqual(
            result.words,
            [
                0x0000,
                0x122A,
                0x2440,
                0x3650,
                0x48C8,
                0x5B18,
                0x6D60,
                0x7FA8,
                0x8080,
                0x9E81,
                0xA000,
                0xB010,
                0xC020,
                0xD280,
                0xE700,
                0xF000,
            ],
        )

    def test_labels_are_case_insensitive(self):
        result = assemble_text("Loop: NOP\nJMP loop\n")
        self.assertEqual(result.words, [0x0000, 0xA000])

    def test_duplicate_label_is_rejected(self):
        with self.assertRaisesRegex(AssemblerError, "duplicate label"):
            assemble_text("same: NOP\nsame: HALT\n")

    def test_invalid_operands_are_rejected(self):
        invalid_sources = (
            "LDI R8, 1",
            "LDI R1, 256",
            "ADD R1, R2",
            "JMP missing_label",
            "NOT_AN_OPCODE",
        )
        for source in invalid_sources:
            with self.subTest(source=source):
                with self.assertRaises(AssemblerError):
                    assemble_text(source)

    def test_program_depth_is_enforced(self):
        with self.assertRaisesRegex(AssemblerError, "exceeds 4 instruction words"):
            assemble_text("NOP\nNOP\nNOP\nNOP\nNOP\n", depth=4)


if __name__ == "__main__":
    unittest.main(verbosity=2)
