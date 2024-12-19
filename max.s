#VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
#
# The following memory locations are used:
#
# data_items - contains the item data. A 0 is used
# to terminate the data
#
.section .data

#These are the data items, the assembler would replace this symbol with the address of the first number when converting to machine code..
data_items:
 .long 3,67,34,222,45,75,54,34,44,33,22,11,66,0 # .long reserves space for longs in the memory.

.section .text

 .globl _start

_start:
 movl $0, %edi
 movl data_items(,%edi, 4), %eax            # indexed addressing mode, where first operand is = data_items + 4*edi, edi holds the offset.
 movl %eax, %ebx                            # set the first value as the largest.

start_loop:                                 # even this is label/symbol that gets converted to address of the next instruction while assembling.
 cmpl $0, %eax                              # subtracts two values and sets the result in %eflags registers.
 je loop_exit                               # looks at the %eflags register and jumps if second value is eq to first.

 incl %edi                                  # increment edi's value by 1.
 movl data_items(, %edi, 4), %eax
 cmpl %eax, %ebx
 jg start_loop                              # if the max remains unbeaten jump to top of the loop.

 movl %eax, %ebx                            # set the new max.
 jmp start_loop                             # unconditional jmp to the start of the loop.

loop_exit:
 movl $1, %eax
 int $0x80

# NOTE: think of the PC(progam counter) running through this file line by line, whenever it encounters a jmp instruction
# it goes to the instruction next to the label, and resumes going line by line. So you see, the PC moved from start
# block to the start_loop block as if the label wasn't even there. This is all thanks to the assembler replacing the
# labels throughout the code with the addresses of the first instructions following the labels.
