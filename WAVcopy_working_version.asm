.data
	file: 
		.asciiz "service-bell.wav" #filename
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
done:
	li	$v0, 16			# 16 = close file
	move	$a0, $s0		# move file descripter to a0
	syscall				# close file
	
#open file to write to
file_open:
    	li 	$v0, 13			# 13 = file open
    	la 	$a0, output_file	# open/create output file
    	li 	$a1, 1			# a1 = flags = 1 (for write)
    	li 	$a2, 0			# a2 = mode = 0
    	syscall  			# File descriptor gets returned in $v0
    
    		
#write file
file_write:
	
	#write header
    	move 	$a0, $v0  		# file write requieres file descriptor in $a0
    	li 	$v0, 15			# 15 = write to file
    	la 	$a1, WavHeader		# a1 = address of output buffer = WavHeader
    	li 	$a2, 44			# a2 = 44 bytes
    	syscall
    	
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
