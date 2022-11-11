#include "trap.h"
   .set noreorder
   .set noat
   .globl main
   .text
main: 
   li $s0, 7           
   li $s1, 8           
   nop
   nop
   nop
   add $s2, $s0, $s1            #7+8=15

   li $s0, -13           
   li $s1, 8           
   nop
   nop
   nop
   add $s2, $s0, $s1            #-13+8=5

   li $s0, 4           
   li $s1, 8           
   nop
   nop
   nop
   addu $s2, $s0, $s1            #4+8=12

   li $s0, -7           
   li $s1, 8           
   nop
   nop
   nop
   addu $s2, $s0, $s1           # 9+8=17

   li $s1, -12
   nop
   nop
   nop
   addi $s2, $s1, 16           #16-12=4

   li $s1, 3
   nop
   nop
   nop
   addi $s2, $s1, 8           #3+8=11

   li $s1, -5
   nop
   nop
   nop
   addiu $s2, $s1, 16           #16+11=27

   li $s1, 3
   nop
   nop
   nop
   addiu $s2, $s1, 7           #3+7=10

   li $s0, 7           
   li $s1, 8           
   nop
   nop
   nop
   sub $s2, $s0, $s1            #7-8=-1

   li $s0, 5           
   li $s1, -2           
   nop
   nop
   nop
   sub $s2, $s0, $s1            #5-(-2)=7

   li $s0, -3           
   li $s1, 8           
   nop
   nop
   nop
   subu $s2, $s0, $s1            #13-8=5

   li $s0, 7           
   li $s1, 8           
   nop
   nop
   nop
   subu $s2, $s0, $s1            #7-8=-1

   li $s0, -2           
   li $s1, 5           
   nop
   nop
   nop
   mult $s0, $s1            #-2*5=10

   li $s0, -5           
   li $s1, -3           
   nop
   nop
   nop
   mult $s0, $s1            #-5*(-3)=15

   li $s0, 2           
   li $s1, 4           
   nop
   nop
   nop
   mult $s0, $s1            #2*4=8

   li $s0, -5           
   li $s1, 2           
   nop
   nop
   nop
   multu $s0, $s1            #11*2=22

   li $s0, 3           
   li $s1, 4           
   nop
   nop
   nop
   multu $s0, $s1            #3*4=12
   nop
   nop
   nop
   mfhi $s2
   mflo $s3
   mthi $s0
   mtlo $s1

   HIT_GOOD_TRAP		#stop temu


