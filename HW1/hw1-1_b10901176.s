.globl __start

.rodata
    msg0: .string "This is HW1-1: T(n) = 5T(n/2) + 6n + 4, T(1) = 2\n"
    msg1: .string "Enter a number: "
    msg2: .string "The result is: "

.text


__start:
  # Prints msg0
    addi a0, x0, 4    # a0 = 4 means "pring string" system call
    la a1, msg0       # load a1 with the address of msg0
    ecall             # system call

  # Prints msg1
    addi a0, x0, 4    # a0 = 4 means "pring string" system call
    la a1, msg1       # load a1 with the address of msg1
    ecall             # system call

  # Reads an int
    addi a0, x0, 5    # a0 = 5 means "read integer" system call
    ecall             # system call

################################################################################ 
  # Write your main function here. 
  # Input n is in a0. You should store the result T(n) into t0
  # HW1-1 T(n) = 5T(n/2) + 6n + 4, T(1) = 2, round down the result of division
  # ex. addi t0, a0, 1

main:
  jal recurrence      # call the recurrence
  add t0, x0, a0      # let t0 = returned value (saved in a0)
  j result            # jump to result

recurrence:
  # stack init
  addi sp, sp, -8     # adjust stack for 2 items
  sw a0, 4(sp)        # save a0 for use afterwards
  sw ra, 0(sp)        # save return address for use afterwards

  li t0, 1            # t0 = 1
  bgt a0, t0, else    # if a0 > 1 (saved in t0), jump to else
  # case n = 1
    addi a0, x0, 2    # set the returned value = 2 (saved in a0)
    addi sp, sp, 8    # restore stack pointer
    jr ra             # return to main

  else:
  # case n > 1
    li t0, 1          # t0 = 1
    srl a0, a0, t0    # right shift one bit (t0 = 1), a0 /= 2
    jal recurrence    # recursive call
    lw t1, 4(sp)      # restore n into t1
    lw ra, 0(sp)      # restore return address back to main
    addi sp, sp, 8    # restore stack pointer

    # calculate T(n) = 5T(n/2) + 6n + 4
    add t2, t1, x0    # t2 = t1
    li t0, 6          # t0 = 6
    mul t2, t2, t0    # t2 = t2 * 6 (t0 = 6)
    li t0, 4          # t0 = 4
    add t2, t2, t0    # t2 = t2 + 4 (t0 = 4)
    li t0, 5          # t0 = 5
    mul a0, a0, t0    # a0 = a0 * 5 (a0 is now the returned value from the above recursive call, which is T(n/2) ,t0 = 5)
    add a0, a0, t2    # a0 = a0 + t2
    jr ra             # return to main


################################################################################

result:
  # Prints msg2
    addi a0, x0, 4    # a0 = 4 means "pring string" system call
    la a1, msg2       # load a1 with the address of msg2
    ecall             # system call

  # Prints the result in t0
    addi a0, x0, 1    # a0 = 1 means "pring float" system call
    add a1, x0, t0    # load a1 with the float value t0
    ecall             # system call
    
  # Ends the program with status code 0
    addi a0, x0, 10   # a0 = 10 means "exit" system call
    ecall             # system call