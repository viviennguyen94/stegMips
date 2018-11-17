.data

	File:	.asciiz "copied.wav" 	# Encoded file name
		.align 2
	Header:	.space 44
		.align 2
	Data:	.align 2
	
.text

	# Open file
	li 	$v0, 13			# 13 = open file
	la 	$a0, File		# $a0 = name of file to be read
	add	$a1, $0, $0		# $a1 = flags = 0
	add	$a2, $0, $0		# $a2 = mode = 0
	syscall				# Open File  $v0<-file data
	move	$s0, $v0		# $s0 = file data
	
	# Read Header
	li	$v0, 14			# 14 = read from file
	move 	$a0, $s0		# Moves $s0 into $a0
	la	$a1, Header		# Header holds header of wav file
	li	$a2, 44			# Read 44 bytes
	syscall
	
	# Read Data
	la	$t0, Header		# Loads address of Header
	li	$v0, 14			# 14 = read from file
	move	$a0, $s0		# Moves $s0 into $a0
	la	$a1, Data		# Data holds data of wav file
	lw	$a2, 40($t0)		# Loads number of bytes to read for wav file
	syscall
	
	# Initializing global variables
	li	$t0, 2			# Loads initial offset to 2
	la	$s1, Data		# Loads address of Data
	la	$t4, Header($a2)	# Loads address of Data + $a2 *End of Data address*
	
	# Decoding loop
Decode:	
	# Grabbing first half of encoded hex
	add	$s1, $s1, $t0		# Increases offset to $s1
	lb	$t1, 0($s1)		# Loads byte at Data with the offset
	
	# Seperating first half of encoded hex
	and	$t1, $t1, 0x0f		# Seperates first 4 bits from byte
	sll	$t1, $t1, 4		# Shifts last 4 bits left by 4
	
	# Grabbing second half of encoded hex
	add	$s1, $s1, $t0		# Increases offset to $s1
	lb	$t2, 0($s1)		# Loads byte at Data with the offset
	
	# Seperating second half of encoded hex
	and	$t2, $t2, 0x0f		# Seperates first 4 bits from byte
	
	# Combining both halves of encoded hex
	or 	$t3, $t1, $t2		# Combine $t1 and $t2
	
	# Check if ascii value is 0x2f
	beq	$t3, 0x2f, Check	#Checks if $t3 equals 0x2f, jumping to Check if true
	
	# Jump back point if program needed to run Check
Print:
	# Print hex to console
	li 	$v0, 11
	la 	$a0, 0($t3)
	syscall
	
	# Checks if end of Data
	beq	$s1, $t4, Exit		# Jumps to Exit if $s1 and $t4 equal each other
	j	Decode			# Jumps to Decode unconditionally
	
	# Checks if the we are at the end of the encoded message
Check:	
	# Grabbing first half of encoded hex
	add	$s1, $s1, $t0		# Increases offset to $s1
	lb	$t5, 0($s1)		# Loads byte at Data with the offset
	
	# Seperating first half of encoded hex
	and	$t5, $t5, 0x0f		# Seperates first 4 bits from byte
	sll	$t5, $t5, 4		# Shifts last 4 bits left by 4
	
	# Grabbing second half of encoded hex
	add	$s1, $s1, $t0		# Increases offset to $s1
	lb	$t6, 0($s1)		# Loads byte at Data with the offset
	
	# Seperating second half of encoded hex
	and	$t6, $t6, 0x0f		# Seperates first 4 bits from byte
	
	# Combining both halves of encoded hex
	or 	$t7, $t5, $t6		# Combine $t5 and $t6
	
	# Checks if ascii value is 0x2f
	beq	$t7, 0x2f, Exit		# Checks if $t7 equals 0x2f, jumping to Exit if true
	
	# Jumps back to Print
	sub	$s1, $s1, 4		# Returns $s1 back to previous address before Check
	j	Print			# Jumps to Print as the next 
	
	# Exit program sequence
Exit:
	# Close file
	li	$v0, 16			# 16 = close file
	move	$a0, $s0		# $s0 contains file descriptor
	syscall
	
	# Exit program
	li	$v0, 10			# Exit program
	syscall
