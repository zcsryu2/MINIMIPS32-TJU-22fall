#include "trap.h"
   .set noreorder
   .set noat
   .globl main
   .text
main:
   lui	$at,   0x4276  
   nop
   nop
   nop
   ori	$at,   $at,   0xac24
   addiu   $v0,   $zero,   0x0008           
   nop
   nop
   nop
   sllv $t0, $at, $v0              #76ac2400

   lui	$at,   0xf3a5  
   nop
   nop
   nop
   ori	$at,   $at,   0x2aec
   nop
   nop
   nop
   sll $t0, $at, 0x0008          #a52aec00

   lui	$at,   0x4276  
   nop
   nop
   nop
   ori	$at,   $at,   0xac24
   addiu   $v0,   $zero,   0x0008           
   nop
   nop
   nop
   srav $t0, $at, $v0            #004276ac

   lui	$at,   0xf3a5  
   nop
   nop
   nop
   ori	$at,   $at,   0x2aec
   nop
   nop
   nop
   sra $t0, $at, 0x0008          #fff3a52a

   lui	$at,   0x4276  
   nop
   nop
   nop
   ori	$at,   $at,   0xac24
   addiu   $v0,   $zero,   0x0008           
   nop
   nop
   nop
   srlv $t0, $at, $v0            #004276ac

   lui	$at,   0xf3a5  
   nop
   nop
   nop
   ori	$at,   $at,   0x2aec
   nop
   nop
   nop
   srl $t0, $at, 0x0008          #00f3a52a
   
   HIT_GOOD_TRAP		#stop temu

