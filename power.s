  # PURPOSE: Program to illustrate how functions work
  # This program will compute the value of
  # 2^3 + 5^2
  #
  #Everything in the main program is stored in registers,
  #so the data section doesn’t have anything.
  .section .data
  .section .text
  .globl _start
_start:
  pushl $3
  pushl $2
  call power

  addl $8, %esp                                   # move the stack back. Remember a stack grows downwards in memory.
  pushl %eax                                      # save the result on the stack, we don't store it in the registers because any function can overwrite them.

  pushl $5
  pushl $2
  call power
  addl $8, %ebp                                   # stack pointer will now point to the previously stored result on the stack.
  popl %ebx                                       # pop the top of the stack into the ebx register.
  addl %eax, %ebx                                 # add and put the result in the ebx register.

  movl $1, %eax
  int $0x80

#PURPOSE: This function is used to compute
# the value of a number raised to
# a power.
#
#INPUT: First argument - the base number
# Second argument - the power to
# raise it to
#
#OUTPUT: Will give the result as a return value
#
#NOTES: The power must be 1 or greater
#
#VARIABLES:
# %ebx - holds the base number
# %ecx - holds the power
#
# -4(%ebp) - holds the current result
#
# %eax is used for temporary storage
#

  .type power, @function
power:
  pushl %ebp                                   # store the previous stack frame's base pointer.
  movl %esp, %ebp
  movl 8(%ebp), %ebx                           # move the first argument into ebx.
  movl 12(%ebp), %ecx                          # move the second argument into ecx.
  subl $4, %esp                                # make room for the intermediate result.
  movl %ebx, -4(%ebp)                          # store the base number as result.
                                               # NOTE: could have written as (%esp) instead of -4(%ebp), but that is the
                                               # point of ebp, it doesn't change, so everything is at a constant offset
                                               # from it.

loop:
  cmpl $1, %ecx
  je exit_power

  movl -4(%ebp), %eax                         # the imull below needs to have the data in two registers, again note the constant offset.
  imull %ebx, %eax
  movl %eax, -4(%ebp)                         # this may seem redundant but we do it since a general purpose register can be overwritten by some other operation.
  decl %ecx                                   # decrease the power.
  jmp loop

exit_power:
  # popl %eax                                  # pop the stored result into eax register.
  movl -4(%ebp), %eax                          # this is more safe, since you don't have to depend on something variable like the stack pointer for popl.
  # subl $4, %esp                              # move the stack pointer back to the return address section.
  movl %ebp, %esp                              # restore the stack pointer, better than the commented one because of the level of certainty here.
  popl %ebp                                    # now you are sure that you are at the previously stored ebp value.
  ret


# CALLING CONVENTION: (this is how our stack looks like.)
# Base Number <--- 12(%ebp)──────────────────────────────┐
# Power <--- 8(%ebp)                                     │ this block is setup by the caller, so it is the responsibility of the caller to purge it.
                                                           the return address is implicitly pushed by the call instruction.
# Return Address <--- 4(%ebp) ◄──────────────────────────┘
# Old %ebp <--- (%ebp)─────────────────────────────────────────────────────────────────────┐ this is setup by the called function, it will purge this from the frame.
# Current result <--- -4(%ebp) and (%esp)◄─────────────────────────────────────────────────┘
