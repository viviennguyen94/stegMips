.data
	message:
		.asciiz "hello"
		#.align 2
	
	file: 
		.asciiz "service-bell.wav" #filename
		#.align 2
	
			
	WavHeader:
		.word 44
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

	
strLen:
	la	$s0, message		# load string from message
	add	$t0, $t0, $zero		# initialize count to 0
loop:
	lb	$t1, 0($s0)		# load chr byte into t1
	beqz	$t1, exit		# if chr is \0, stop
	addi	$t0, $t0, 1		# add 1 to count t0
	addi	$s0, $s0, 1		# point to next chr
	j	loop			# loops
exit:
	
#PREP DATA AND STRING TO ENCODE

	la	$s0, WavHeader		# load WavHeader into s0
	la	$s1, message		# load address of s0 at offset 0
	addi	$s0, $s0, 44		# increment to 44th byte
	li	$s3, 5			# 5 counts

ENCODE:
#SEPARATING THE CHARACTER 
		
	# splitting hex value of letter 
	
	lb	$t1, 0($s1)		# text byte stored in $t1
	srl	$t2, $t1, 4		# isolate, shift first 4 bits in text byte
	andi	$t3, $t1, 0x0f		# isolate last 4 bits in text byte
	
	# increment to first byte
	addi	$s0, $s0, 2		
	
	# putting first 4 bits of text byte and clearing out least 4 significant bits of wav byte 
	lb	$t4, 0($s0)		# load first byte into t4
	andi	$t4, $t4, 0xf0		# clear last 4 lsb of t4 
	or	$t4, $t4, $t2		# insert first half of letter into t4
	sb	$t4, 0($s0)		# change byte in wav file
	
	# increment to second byte
	addi	$s0, $s0, 2		
	
	# putting last 4 bits of text byte and clearing out least 4 significant bits of wav byte  
	lb	$t4, 0($s0)		# move next 2 bytes in wav
	andi 	$t4, $t4, 0xf0		# clear out 
	or 	$t4, $t4, $t3 		# insert last half of letter into t4
	sb	$t4, 0($s0)		# store back into data
	
	# branch check
	subi	$t0, $t0, 1
	beqz	$t0, done
	addi	$s1, $s1, 1
	j	ENCODE
	

# Close file
done:
	li	$v0, 16			# 16 = close file
	add	$a0, $s0, $0		# $s0 contains fd
	syscall				# close file
	
# Exit Gracefully

	li	$v0, 10
	syscall
