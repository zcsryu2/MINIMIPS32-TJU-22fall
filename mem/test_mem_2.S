#include "trap.h"
   .set noreorder
   .globl main
   .text
main:
   lui   $s0,   0xf1f2
   nop
   nop
   nop
   ori   $s0,   $s0,   0xf3f4
   nop
   nop
   nop
   sb $s0, 4($zero)
   nop
   nop
   nop
   lb $s1,4($zero)     #fffffff1
   lbu $s1,4($zero)      #000000f1

   lui   $s0,   0xf1f2
   nop
   nop
   nop
   ori   $s0,   $s0,   0xf3f4
   nop
   nop
   nop
   sh $s0, 8($zero)
   nop
   nop
   nop
   lh $s1,8($zero)    #fffff1f2
   lhu $s1,8($zero)    #0000f1f2


   lui   $v0,  0x8000
   lui   $s0,   0xf1f2
   nop
   nop
   nop
   ori   $s0,   $s0,   0xf3f4
   nop
   nop
   nop
   sw $s0, 16($zero)
   nop
   nop
   nop
   lw $s1,16($zero) #0xf1f2f3f4

   HIT_GOOD_TRAP		#stop temu

