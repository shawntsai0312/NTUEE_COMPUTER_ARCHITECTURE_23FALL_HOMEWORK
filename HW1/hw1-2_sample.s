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
    addi a0, x0, 4
    la a1, msg3
    ecall
  
    add a1,x0,x20
    ecall

  # Ends the program with status code 0
    addi a0,x0,10
    ecall
    
################################################################################

__start:
  # Prints msg
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
    add a6, a0, x0
    
  # Prints msg2
    addi a0, x0, 4
    la a1, msg2
    ecall
    
    addi a0,x0,8
    li a1, 0x10150
    addi a2,x0,2047
    ecall
  # Load address of the input string into a0
    add a0,x0,a1


################################################################################ 
  # Write your main function here. 
  # a0 stores the begining Plaintext
  # x16 stores the shift
  # Do store 66048(0x10200) into x20 
  # ex. j print_char
  
################################################################################

