#include "trap.h"
   .set noreorder
   .set noat
   .globl main
   .text
main:
   li $at, 0xffffffff           
   lui   $v0,   0xf3a5
   nop
   nop
   nop
   ori   $v0,   $v0,   0x2aec
   nop
   nop
   nop
   and $t0, $at, $v0            #0xf3a52aec

   li $at, 0xffffffff
   nop
   nop
   nop
   andi $t0, $at, 0x24ac          #0x000024ac

   li $at, 0xffffffff
   nop
   nop
   nop
   andi $t0, $at, 0xf4ac     #0xfffff4ac

   li $at, 0x00000000           
   lui   $v0,   0x8888
   nop
   nop
   nop
   ori   $v0,   $v0,   0x8888
   nop
   nop
   nop
   nor $t0, $at, $v0            #0x77777777

   li $at, 0x00000000           
   lui   $v0,   0xf3a5
   nop
   nop
   nop
   ori   $v0,   $v0,   0x2aec
   nop
   nop
   nop
   or $t0, $at, $v0            #0xf3a52aec

   li $at, 0x00000000
   nop
   nop
   nop
   ori $t0, $at, 0x24ac          #0x000024ac

   li $at, 0x00000000
   nop
   nop
   nop
   ori $t0, $at, 0xf4ac    #0x0000f4ac

   lui   $at,   0xaaaa
   nop
   nop
   nop
   ori   $at,   $at,   0xaaaa
   lui   $v0,   0xaaaa
   nop
   nop
   nop
   ori   $v0,   $v0,   0xaaaa
   nop
   nop
   nop
   xor $t0, $at, $v0            #00000000

   lui   $at,   0x8888
   nop
   nop
   nop
   ori   $at,   $at,   0x8888
   lui   $v0,   0x7777
   nop
   nop
   nop
   ori   $v0,   $v0,   0x7777
   nop
   nop
   nop
   xor $t0, $at, $v0            #ffffffff


   li $at, 0xffffffff
   nop
   nop
   nop
   xori $t0, $at, 0xffff          #ffff0000

   li $at, 0xffffffff
   nop
   nop
   nop
   xori $t0, $at, 0x0fff    #fffff000

   HIT_GOOD_TRAP		#stop temu


