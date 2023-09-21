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
# Main function to calculate T(n)
# .global main
main:
  # Load the input value n into a1
  mv a1, a0

  # Check if n is equal to 1 (base case)
  li t0, 1
  beq a1, t0, base_case

  # Calculate n/2 by right-shifting n by 1
  srai a1, a1, 1

  # Recursively call the function to calculate 5T(n/2)
  jal main

  # Multiply the result by 5 (t0 = 5T(n/2))
  li t1, 5
  mul t0, a0, t1

  # Calculate 6n
  li t2, 6
  mul t2, a1, t2

  # Calculate 5T(n/2) + 6n + 4
  add t0, t0, t2
  li t3, 4
  add t0, t0, t3

  # Return to the caller
  ret

# # Base case when n = 1
base_case:
  li t0, 2  # T(1) = 2
  jal ra, result  # Jump to the result section to print the result and terminate
  
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