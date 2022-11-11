#include "trap.h"
   .set noreorder
   .set noat
   .globl main
   .text
main:
   li $at, 0x80000000           
   lui   $v0,   0xf3a5
   nop
   nop
   nop
   ori   $v0,   $v0,   0x2aec
   nop
   nop
   nop
   slt $t0, $at, $v0                #最大负数<负数 结果为1

   lui   $at,   0x7fff    
   nop
   nop
   nop
   ori   $at,   $at,   0xffff
   lui   $v0,   0x4276
   nop
   nop
   nop
   ori   $v0,   $v0,   0xac24
   nop
   nop
   nop
   slt $t0, $at, $v0            #$最大正数>正数 结果为0

   lui   $at,   0xf3a5
   nop
   nop
   nop
   ori   $at,   $at,   0x2aec
   lui   $v0,   0x4276
   nop
   nop
   nop
   ori   $v0,   $v0,   0xac24
   nop
   nop
   nop
   slt $t0, $at, $v0            #负数<正数 结果为1

   li $at, 0x80000000           
   lui   $v0,   0xf3a5
   nop
   nop
   nop
   ori   $v0,   $v0,   0x2aec
   nop
   nop
   nop
   sltu $t0, $at, $v0                #结果为1

   lui   $at,   0x7fff
   nop
   nop
   nop
   ori   $at,   $at,   0xffff
   lui   $v0,   0x4276
   nop
   nop
   nop
   ori   $v0,   $v0,   0xac24
   nop
   nop
   nop
   sltu $t0, $at, $v0            #$结果为0

   lui   $at,   0xf3a5
   nop
   nop
   nop
   ori   $at,   $at,   0x2aec
   lui   $v0,   0x4276
   nop
   nop
   nop
   ori   $v0,   $v0,   0xac24
   nop
   nop
   nop
   sltu $t0, $at, $v0            #结果为0

   lui   $at,   0x7fff
   nop
   nop
   nop
   ori   $at,   $at,   0xffff
   nop
   nop
   nop
   slti $t0, $at, 0xf3a5           #最大负数<负数 结果为1

   lui   $at,   0x7fff
   nop
   nop
   nop
   ori   $at,   $at,   0xffff
   nop
   nop
   nop
   slti $t0, $at, 0x4276           #最大正数>正数 结果为0

   li $at, 0xfffffff5
   nop
   nop
   nop
   slti $t0, $at, 0xfff3           #符号扩展应该是大于 结果为0
   
   li $at, 0xffffffff
   nop
   nop
   nop
   slti $t0, $at, 0x2222           #-1<正数 结果为1

   li $at, 0x80000000
   nop
   nop
   nop
   sltiu $t0, $at, 0xf3a5           #结果为1

   lui   $at,   0x7fff
   nop
   nop
   nop
   ori   $at,   $at,   0xffff
   nop
   nop
   nop
   sltiu $t0, $at, 0x4276           #最大正数>正数 结果为0

   lui   $at,   0x7fff
   nop
   nop
   nop
   ori   $at,   $at,   0xffff
   nop
   nop
   nop
   sltiu $t0, $at, 0x2222           #无符号比较> 结果为1

   HIT_GOOD_TRAP		#stop temu

