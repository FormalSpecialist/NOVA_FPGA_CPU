; NOVA hardware demonstration program
; Computes 10 + 9 + ... + 1 = 55 (0x37).
;
; Register use:
;   R0 = zero constant (never written)
;   R1 = decreasing loop counter
;   R2 = accumulated sum
;   R3 = constant one
;   R4 = value loaded back from data memory
;   R5 = final display-producing ALU result

        LDI R1, 10          ; counter = 10
        LDI R2, 0           ; sum = 0
        LDI R3, 1           ; decrement = 1

loop:
        ADD R2, R2, R1      ; sum = sum + counter
        SUB R1, R1, R3      ; counter = counter - 1
        JZ done             ; finish when counter reaches zero
        JMP loop

done:
        ST R2, 0x10         ; RAM[0x10] = 55
        LD R4, 0x10         ; R4 = RAM[0x10]
        ADD R5, R4, R0      ; execution result = 55 for the display
        HALT
