.globl __start

.rodata
    msg0: .string "This is HW1-1: T(n) = 5T(n/2) + 6n + 4, T(1) = 2\n"
    msg1: .string "Enter a number: "
    msg2: .string "The result is: "

.text


__start:
  # Prints msg0
    addi a0, x0, 4
    la a1, msg0
    ecall

  # Prints msg1
    addi a0, x0, 4
    la a1, msg1
    ecall

  # Reads an int
    addi a0, x0, 5
    ecall

################################################################################ 
  # Write your main function here. 
  # Input n is in a0. You should store the result T(n) into t0
  # HW1-1 T(n) = 5T(n/2) + 6n + 4, T(1) = 2, round down the result of division
  # ex. addi t0, a0, 1

main:
  jal recurrence      # call the recurrence
  add t0, x0, a0      # let t0 = returned value (saved in a0)
  jal result          # jump to result

recurrence:
  # stack init
  addi sp, sp, -8     # adjust stack for 2 items
  sw a0, 4(sp)        # save a0 for use afterwards
  sw ra, 0(sp)        # save ra for use afterwards

  addi t0, x0, 1      # t0 = 1
  bgt a0, t0, else    # check if a0 = 1 (saved in t0), if not jump to else
    # case n = 1
    addi a0, x0, 2    # set the returned value = 2 (saved in a0)
    addi sp, sp, 8    # restore sp
    jr ra             # return

  else:
    # case n > 1
    addi t0, x0, 1    # t0 = 1
    srl a0, a0, t0    # right shift one bit (t0 = 1)
    jal recurrence    # recursive call
    lw t1, 4(sp)      # restore n into t1
    lw ra, 0(sp)      # restore ra
    addi sp, sp, 8    # restore sp

    add t2, t1, x0    # t2 = t1
    addi t0, x0, 6    # t0 = 6
    mul t2, t2, t0     # t2 = t2 * 6 (t0 = 6)
    addi t0, x0, 4    # t0 = 4
    add t2, t2, t0    # t2 = t2 + 4 (t0 = 4)
    addi t0, x0, 5    # t0 = 5
    mul a0, a0, t0     # a0 = a0 * 5 (a0 is now the returned value from the above recursive call, which is T(n/2) ,t0 = 5)
    add a0, a0, t2    # a0 = a0 + t2
    jr ra             # return


################################################################################

result:
  # Prints msg2
    addi a0, x0, 4
    la a1, msg2
    ecall

  # Prints the result in t0
    addi a0, x0, 1
    add a1, x0, t0
    ecall
    
  # Ends the program with status code 0
    addi a0, x0, 10
    ecall