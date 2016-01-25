# Code adapted from http://www.marcell-dietl.de/downloads/eratosthenes.s

# Code optimized by Brandon Sladek and Paul Burton
	
	.data			# the data segment to store global data
space:	.asciiz	" "		# whitespace to separate prime numbers

	.text			# the text segment to store instructions
	.globl 	main		# define main to be a global label
	
main:	
	li	$s0, 0x00000000	# initialize $s0 with zeros
	li	$s1, 0x11111111	# initialize $s1 with ones
	li	$t9, 200	# find prime numbers from 2 to $t9

	add	$t7, $sp, 0	# backup bottom of stack address in $t7, readonly
	
	subu	$sp, $sp, 4	# set stack pointer to point at 3
	li	$t0, 3		# i starts at 3
	
init:	
	sw	$s1, 0($sp)	# i
	sw	$s1, -8($sp)	# i + 2
	sw	$s1, -16($sp)	# i + 4
	sw	$s1, -24($sp)	# i + 6
	sw	$s1, -32($sp)	# i + 8
	sw	$s1, -40($sp)	# i + 10
	sw	$s1, -48($sp)	# i + 12
	sw	$s1, -56($sp)	# i + 14
	sw	$s1, -64($sp)	# i + 16
	sw	$s1, -72($sp)	# i + 18
	add	$t0, $t0, 20
	subu	$sp, $sp, 80
	blt	$t0, $t9, init
	
	li	$t0, 1		# reset counter variable to 1
	
outer:	
	add 	$t0, $t0, 2	# increment counter variable, start at 3, multiples of 2 [even numbers] already 0
	mul	$t1, $t0, $t0	# only need to go to square root of max value 200
	bgt	$t1, $t9, print	# start printing prime numbers when $t1 > $t9

check:	
	sll	$t3, $t0, 2	# calculate the number of bytes to jump over
	sub	$t6, $t7, $t3	# subtract them from bottom of stack address

	lw	$t4, 8($t6)	# load the content into $t4 (offset by 8 because we started counting at 2)
	
	beq	$t4, $s0, outer	# only 0's? go back to the outer loop, if it's not prime, don't go to inner loop
	
	sll	$t2, $t0, 1	# double the index value so the inner loop jumps double multiples to avoid even numbers
	
inner:				# unrolled this so it does this twice for each iteration
	sll	$t3, $t1, 2	# calculate the number of bytes to jump over, starting from square of outer index
	sub	$t6, $t7, $t3	# subtract them from bottom of stack address
	
	add	$t1, $t1, $t2	# do this for every other multiple of $t1 since half the multiples are even
				
	sw	$s0, 8($t6)	# store 0's -> it's not a prime number! (offset by 8 because we started counting at 2)
	
	sll	$t4, $t1, 2	# unrolled the inner loop twice so twice as much happens in one iteration
	sub	$t5, $t7, $t4
	add	$t1, $t1, $t2
	sw	$s0, 8($t5)
	
	ble	$t1, $t9, inner # some multiples left? go back to inner loop
	
	j outer			# every multiple done? go back to outer loop

print:				# Always print 2
	li	$v0, 1		# system code to print integer
	li	$a0, 2		# we know 2 is prime and we shouldn't have to check for that every time
	syscall			# print it!

	li	$v0, 4		# system code to print string
	la	$a0, space	# the argument will be a whitespace
	syscall			# print it!
				
	li	$t0, 1		# reset counter variable to 1
	
count:	add	$t0, $t0, 2	# (start at 3), add 2 every time to skip even numbers because we know they're not prime
	
	bgt	$t0, $t9, exit	# can exit when $t0 greater than $t9
	
	sll	$t3, $t0, 2	# calculate the number of bytes to jump over
	sub	$t2, $t7, $t3	# subtract them from bottom of stack address
	add	$t2, $t2, 8	# add 2 words - we started counting at 2!
				
	lw	$t3, ($t2)	# load the content into $t3
	
	bne	$t3, $s1, count	# only 0's? go back to count loop
	
	lw	$t5, -8($t2)	# let's just check the next odd number and see if it's prime

	sub	$t3, $t7, $t2	# substract higher from lower address (= bytes)
	srl	$t4, $t3, 2	# divide by 4 (bytes) = distance in words
	add	$t3, $t4, 2	# add 2 (words) = the final prime number!

	li	$v0, 1		# system code to print integer
	add	$a0, $t3, 0	# the argument will be our prime number in $t3
	syscall			# print it!

	li	$v0, 4		# system code to print string
	la	$a0, space	# the argument will be a whitespace
	syscall			# print it!
	
	add	$t0, $t0, 2
	bne	$t5, $s1, count
	
	lw	$t6, -16($t2)	# next odd number after $t5
	
	li	$v0, 1		# system code to print integer
	add	$a0, $t3, 2	# add 2 to the prime number in this loop since we checked the next odd number
	bgt	$a0, $t9, exit
	syscall			# print it!

	li	$v0, 4		# system code to print string
	la	$a0, space	# the argument will be a whitespace
	syscall			# print it!
	
	add	$t0, $t0, 2
	bne	$t6, $s1, count
	
	li	$v0, 1		# system code to print integer
	add	$a0, $t3, 4	# add 4 to the prime number in this loop since we checked the next odd number
	bgt	$a0, $t9, exit
	syscall			# print it!

	li	$v0, 4		# system code to print string
	la	$a0, space	# the argument will be a whitespace
	syscall			# print it!
	
	blt	$t0, $t9, count	# take loop while $t0 < $t9

exit:	li	$v0, 10		# set up system call 10 (exit)
	syscall	
