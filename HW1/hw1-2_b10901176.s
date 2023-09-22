.globl __start

.rodata
    msg0: .string "This is HW1-2: \n"
    msg1: .string "Enter shift: "
    msg2: .string "Plaintext: "
    msg3: .string "Ciphertext: "
.text

################################################################################
  # print_char function
  # Usage: 
  #     1. Store the beginning address in x20
  #     2. Use "j print_char"
  #     The function will print the string stored from x20 
  #     When finish, the whole program with return value 0

print_char:
  # Prints msg3
    addi a0, x0, 4    # a0 = 4 means "print string" system call
    la a1, msg3       # load the address of msg3 into a1
    ecall             # system call

    add a1, x0, x20   # Copy the value from x20 to a1
    ecall             # system call

  # Ends the program with status code 0
    addi a0, x0, 10   # a0 = 10 means "exit" system call
    ecall             # system call

    
################################################################################

__start:
  # Prints msg0
    addi a0, x0, 4    # a0 = 4 means "print string" system call
    la a1, msg0       # load the address of msg0 into a1
    ecall             # system call

  # Prints msg1
    addi a0, x0, 4    # a0 = 4 means "print string" system call
    la a1, msg1       # load the address of msg1 into a1
    ecall             # system call

  # Reads an integer
    addi a0, x0, 5    # a0 = 5 means "read integer" system call
    ecall             # execute a system call to read an integer
    add a6, a0, x0    # copy the read integer to register a6

  # Prints msg2
    addi a0, x0, 4    # a0 = 4 means "print string" system call
    la a1, msg2       # load the address of msg2 into a1
    ecall             # system call

  # Reads the input char array
    addi a0, x0, 8    # a0 = 8 means "read string" system call
    li a1, 0x10150    # load a1 with the string memory address
    li a2, 2047       # a2 = 2047 means maxLength = 2047
    ecall             # system call

  # Loads the address of the input string into a0
    add a0, x0, a1    # copy the address from a1 to a0 for further processing



################################################################################ 
  # Write your main function here. 
  # a0 stores the begining Plaintext
  # x16 stores the shift
  # Do store 66048(0x10200) into x20 
  # ex. j print_char

main:
  li x20, 66048       # x20 = 66048 , which is the address of string
  add a1, x0, x20     # let a1 be the pointer pointing x20
  li a2, -1           # let a2 be the spaceCounter with init value -1
  jal while_start     # call the while loop
  j print_char        # jump to print_char

while_start:
  # stack init
  addi sp, sp ,-4     # adjust stack for an item
  sw ra, 0(sp)        # store return address into stack

  # character reading
  lb t0, 0(a0)        # load t0 with the character pointed by a0
  beqz t0, while_end  # if t0 is null, jump to while_end

  # character encrypting
  li t1, 32           # t1 = 32, (' ' = 32)
  beq t0, t1, space   # if t0 = ' ', jump to space
  
  # not a space => add shift
  add t0, t0, x16     # add the shift on t0

  li t1, 122          # t1 = 122, ('z' = 122)
  bgt t0, t1, much    # if t0 > 'z' ('z' = 122), jump to much
  li t1, 97           # t1 = 97, ('a' = 97)
  blt t0, t1, less    # if t0 < 'a', jump to less
  
  # case else
  j next              # do not need to modify t0, jump to next

  space:
  # case space
  addi a2, a2, 1      # a2 += 1
  add t0, x0, a2      # t0 = a2
  addi t0, t0, 48     # t0 += '0', convert integers into ASCII number
  j next              # jump to next

  much:
  # case much
  addi t0, t0, -26    # t0 -= 26, fix t0 > 'z'
  j next              # jump to next

  less:
  # case less
  addi t0, t0, 26     # t0 += 26, fix t0 < 'a'
  j next              # jump to next

  next:
  # character storing
  sb t0, 0(a1)        # store the character (t0) into the address pointed by a1
  addi a0, a0, 1      # move the plaintext character pointer to the next
  addi a1, a1, 1      # move the cyphertext character pointer to the next
  j while_start       # jump to while_start

while_end:
  # clear stack
  lw ra, 0(sp)        # restore return address (back to main)
  addi sp, sp, 4      # restore stack pointer
  jr ra               # return to main

  
################################################################################

