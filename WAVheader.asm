.data
	file: 
		.asciiz "service-bell.wav" #filename
		#.align 2
		
	WavHeader:
		.word 44
		#.align 2
	hello:
		.asciiz "h"
		#.align 2
.text

# Open file
	
	li 	$v0, 13			# 13 = open file
	la 	$a0, file		# a0 = name of file to be read
	add	$a1, $0, $0		# a1 = flags = 0
	add	$a2, $0, $0		# a2 = mode = 0
	syscall				# open FILE  v0<-file data
	add	$s0, $0, $v0		# s0 = file data
	
# Read Header
	li 	$s7, 277060
	
	li	$v0, 14			# 14 = read from file
	move 	$a0, $s0		# place s0 into a0
	la	$a1, WavHeader		# WavHeader holds hex
	la	$a2, 0($s7)			# Read 4 bytes
	syscall

# Print Riff

	li	$v0, 11			# Print string instuction
	la	$s0, WavHeader		# load WavHeader into s0
	lb	$a0, 46($s0)		# load address of s0 at offset 0
	syscall	
	
	# new line character
	li $a0, 10		# same as before, except we are printing ASCII 10, which is
	li $v0, 11		# a new line character. 
	syscall
	
	li	$v0, 4			# Print string instuction
	la	$a0, hello		# load address of s0 at offset 0
	syscall	

	move 	$t1, $a0 		# move text byte to $t1	
	lw	$t1, 0($t1)		
	srl	$t2, $t1, 4		# isolate, shift first 4 bits in text byte
	andi	$t3, $t1, 0x0f		# isolate last 4 bits in text byte
	
	
	
	# new line character
	li $a0, 10		# same as before, except we are printing ASCII 10, which is
	li $v0, 11		# a new line character. 
	syscall
	
	
# Print byte 40 and store in temporary variable
	la	$s0, WavHeader		# load WavHeader into s0
	lw	$s7, 40($s0)		# load word into a0
	
	li 	$v0, 1
	move 	$a0, $s7
	syscall
	
# Print out one byte in byte 45
	li	$v0, 1
	la	$a0, 40($s0)
	syscall

# Close file
done:
	li	$v0, 16			# 16 = close file
	add	$a0, $s0, $0		# $s0 contains fd
	syscall				# close file
	
# Exit Gracefully

	li	$v0, 10
	syscall
