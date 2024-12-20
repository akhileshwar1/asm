#
# VARIABLES:
# 1. ebx - the number to be searched.
# 2. eax - the current number.
# 3. data_items - memory address that holds the list of numbers.

.section .data

data_items: .long 1, 2, 3, 4, 5, 0 # 0 signifies the end of the list.

.section .text

  .globl _start

_start:
  movl $4, %ebx                             # move the number to be searched into %ebx. change $4 to $7 for the other case.
  movl $0, %edi                             # start the offset from 0.
  movl data_items(,%edi,4), %eax

loop:
  cmpl $0, %eax
  je loop_exit

  cmpl %eax, %ebx
  je equal_exit                            # exits the loop.

  incl %edi                                # increment the offset.
  movl data_items(, %edi, 4), %eax         # set %eax to the next element.
  jmp loop

equal_exit:
  movl $1, %ebx
  jmp exit

loop_exit:
  movl $0, %ebx
  jmp exit

exit:
  movl $1, %eax
  int $0x80

# check the output by typing echo $? after the file run.
# NOTE: the relative order of the instructions here is preserved in the memory.
