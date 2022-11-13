   .set noat
   .set noreorder
   .globl main
   .text
main:
   lui  $at,0x1
   j      L2
   nop
   
L3:
   jal L4
   lui $at,0x3

L2:
   la $v0, L3
   jr $v0
   lui $at,0x2

L4:
   bne $at,$v0,L5
   lui $at 0x4

L6:
   lui $at,0xA

L5:
   lui $at,0x5
   lui $v0,0x6
   beq $at,$v0,L6
   nop

loop:
   j loop
   nop