  # PURPOSE: to calculate the factorial of a number.

.section .data

.section .text

  .globl _start
_start:
  pushq $6
  call factorial                                # result stored in %rax.
  addq $8, %rsp                                 # restore the stack pointer.

  movq %rax, %rbx
  movq $1, %rax
  int $0x80

# Variables:

  .type factorial, @function
factorial:
  subq $8, %rsp
  movq %rbp, (%rsp)                            # save previous rbp on the stack.
  movq %rsp, %rbp                              # the new rbp now points to the top of the stack.

  cmpq $1,16(%rbp)
  movq $1, %rax                                # no worries, since it will be overwritten down the line if je fails.
  je factorial_exit

  movq 16(%rbp), %rbx
  decq %rbx                                   # decrement the value.
  pushq %rbx                                  # push the parameter for the call.
  call factorial                              # assuming the result is in %rax.
  popq %rbx                                   # remove the parameter from the stack frame and restore the stack pointer after the call.

  movq 16(%rbp), %rcx                        # load the parameter of this particular function instance's activation record into rcx.
  imul %rcx, %rax                             # f(n) = n*f(n-1)
  jmp factorial_exit

factorial_exit:
  movq %rbp, %rsp                            # restore the stack pointer.
  popq %rbp                                  # restore the old base pointer of the previous stack frame/activation record.
  ret                                        # works, since the rsp now points to return address, popq implicitly decreased it by 8.

# NOTE: in recursive calls the base communicate their results to the predecessors using registers.
# NOTE: if you have a set of insructions that use a particular register before and after a function call, make sure
#       the function has not overwritten its value. Safer to save the register value on its current stack frame and 
#       reload it into the register for processing again after the function call.
