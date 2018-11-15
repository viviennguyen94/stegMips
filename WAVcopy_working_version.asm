.data
	file: 
		.asciiz "service-bell.wav" #filename
		.align 2
	
	WavHeader:
		.word 277100
		.align 2
		
	output_file: .asciiz "copy.wav"

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
	li	$a2, 277060			# Read 4 bytes
	syscall
	
#open file to write to
	file_open:
    	li 	$v0, 13			# 13 = file open
    	la 	$a0, output_file	# open/create output file
    	li 	$a1, 1			# a1 = flags = 1 (for write)
    	li 	$a2, 0			# a2 = mode = 0
    	syscall  			# File descriptor gets returned in $v0
    
    		
#write file
	file_write:
    	move 	$a0, $v0  		# file write requieres file descriptor in $a0
    	li 	$v0, 15			# 15 = write to file
    	la 	$a1, WavHeader		# a1 = address of output buffer = WavHeader
    	li 	$a2, 277060		# a2 = max n
    	syscall

#close file written to    
	file_close:
    	li 	$v0, 16  		# $a0 already has the file descriptor
    	syscall

	
# Close file
done:
	li	$v0, 16			# 16 = close file
	add	$a0, $s0, $0		# $s0 contains fd
	syscall				# close file
	
# Exit Gracefully
	li	$v0, 10
	syscall
