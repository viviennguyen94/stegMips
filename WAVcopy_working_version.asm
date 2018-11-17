.data
	file: 
		.asciiz "service-bell.wav" #filename
		.align 2
	
	message:
		.asciiz "LETS GO TO KOIZI, BRAD!!//" #must have // at end of message to prevent decoding more than just message
		.align 2
	
	WavHeader:
		.space 44
		.align 2
		
	WavData:
		.space 1000000
		.align 2
		
	output_file: .asciiz "copied.wav"

.text

main:

# Open file
	li 	$v0, 13			# 13 = open file
	la 	$a0, file		# a0 = name of file to be read 
	add	$a1, $0, $0		# a1 = flags = 0
	add	$a2, $0, $0		# a2 = mode = 0
	syscall				# open FILE  v0<-file data
	move	$s0, $v0		# move file descriptor to s0

# Read Header
	li	$v0, 14			# 14 = read from file
	move 	$a0, $s0		# place s0 into a0
	la	$a1, WavHeader		# WavHeader holds hex
	li	$a2, 44			# Number of bytes to read
	syscall

	la	$s1, WavHeader		# load address of WavHeader
	
# Read data portion

	li	$v0, 14			# 14 = read from file
	move 	$a0, $s0		# place s0 into a0
	la	$a1, WavData		# WavData holds data
	lw	$a2, 40($s1)		# Number of bytes to read. size from 40th byte of header
	syscall
	
# Close file
readClose:
	li	$v0, 16			# 16 = close file
	move	$a0, $s0		# move file descripter to a0
	syscall				# close file

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

	la	$s0, WavData		# load WavHeader into s0
	la	$s1, message		# load address of s0 at offset 0
	#addi	$s0, $s0, 44		# increment to 44th byte
	#li	$s3, 5			# 5 counts

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
	beqz	$t0, write_open
	addi	$s1, $s1, 1
	j	ENCODE
	
#open file to write to
write_open:
    	li 	$v0, 13			# 13 = file open
    	la 	$a0, output_file	# open/create output file
    	li 	$a1, 1			# a1 = flags = 1 (for write)
    	li 	$a2, 0			# a2 = mode = 0
    	syscall  			# File descriptor gets returned in $v0
    
    		
#write file
write_file:
	
	#write header
    	move 	$a0, $v0  		# file write requieres file descriptor in $a0
    	li 	$v0, 15			# 15 = write to file
    	la 	$a1, WavHeader		# a1 = address of output buffer = WavHeader
    	li 	$a2, 44			# a2 = 44 bytes
    	syscall
    	
    	la	$s1, WavHeader
    	
    	#write data
    	li 	$v0, 15			# 15 = write to file
    	la 	$a1, WavData		# a1 = address of output buffer = WavData
    	lw 	$a2, 40($s1)		# a2 = num of bytes to read from 4th byte in wavheader
    	syscall
    	
#close file written to    
file_close:
    	li 	$v0, 16  		# $a0 already has the file descriptor
    	syscall

# Exit Gracefully
	li	$v0, 10
	syscall
