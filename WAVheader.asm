.data
	file: 
		.asciiz "service-bell.wav" #filename
		.align 2
	WavHeader:
		.word 44
		.align 2
.text

# Open file
	
	li 	$v0, 13			# 13 = open file
	la 	$a0, file		# a0 = name of file to be read
	add	$a1, $0, $0		# a1 = flags = 0
	add	$a2, $0, $0		# a2 = mode = 0
	syscall				# open FILE  v0<-file data
	add	$s0, $0, $v0		# s0 = file data
	
# Read Header
	
	li	$v0, 14			# 14 = read from file
	move 	$a0, $s0		# place s0 into a0
	la	$a1, WavHeader		# WavHeader holds hex
	li	$a2, 44			# Read 4 bytes
	syscall

# Print Riff

	li	$v0, 4			# Print string instuction
	la	$s0, WavHeader		# load WavHeader into s0
	la	$a0, 0($s0)		# load address of s0 at offset 0
	syscall	
	
# Print byte 40

	li	$v0, 1			# Print int instruction
	la	$s0, WavHeader		# load WavHeader into s0
	lw	$a0, 40($s0)		# load word into a0
	syscall	
	
# Close file
done:
	li	$v0, 16			# 16 = close file
	add	$a0, $s0, $0		# $s0 contains fd
	syscall				# close file
	
# Exit Gracefully

	li	$v0, 10
	syscall
