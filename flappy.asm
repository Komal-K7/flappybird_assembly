# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
	displayAddress:	.word	0x10008000
	lose: .asciiz "YOU LOST"
	blue: .word  0x2ca0b8
	green: .word 0x2cb870
	yellow: .word 0xffea00
	
.text
#lw $t0, displayAddress	# $t0 stores the base address for display

	lw	$t1, 0xffff0000 #keeps track if keyboard input happened
	lw	$t0, 0xffff0004 #holds which letter was inputted
reset:
	li      $s0, 1 #keeps track of where to draw the pipe
	li      $a0, 0 #reset random pipe height
	li      $t5, 2 #pipe max height for top
	li      $t6, 11 #pipe max height for bottom
	li	$t2, 16 #bird height location
main:
	
	li    	$a3, 0x10008000 #address of original display address
	li      $t3, 32 #keeps track of which row we are on 

blue_rows_loop:
	li      $t4, 32 #keeps track of which column we are on
	jal     setPixels           
	addi    $t3, $t3, -1
	bnez    $t3, blue_rows_loop # colours a row and loops back if not on the last row

	li      $v0, 32             # MARS service delay(ms)
	li      $a0, 40             # 40ms = ~25 FPS if the draw would be instant
	syscall

    #addiu   $t1, $t1, 0xFE0408  # adjust main color (red -2, green +4, blue +8 + overflows (B -> G -> R)
    #andi    $t1, $t1, 0xFFFFFF  # force "alpha" to zero
    
	add     $s0, $s0, 1 #moves the pipe down one pixel to create animation
	bge     $s0, 32, reset 
	j       main           # infinite loop will animated colours...


setPixels:
	beq     $t4,20,setYellow
pixelCont:
	lw      $a2, blue #set painting colour to blue
	beqz    $a0,pipeHeight #if a0=0, then we need to find a new pipe height for this "frame"
	addi    $s0,$s0,-1
	beq     $t4,$s0,setGreen_b #makes prev col green
	addi    $s0,$s0,1
	beq     $t4,$s0,setGreen #makes curr col green
	addi    $s0,$s0,1
	beq     $t4,$s0,setGreen_a #makes next col green
	addi    $s0,$s0,-1
Paint:
	sw      $a2, ($a3)      # set pixel (or simply memory word)
	addi    $a3, $a3, 4     # advance memory pointer
	addi    $t4, $t4, -1    # count-down loop
	bnez    $t4, setPixels
	jr      $ra             # return

setYellow:
#	beq	$t0,066, Fly 	 #if input == ascii val of 'f', then fly
	bne     $t3,$t2,pixelCont
	lw      $a2, yellow #set painting colour to yellow
	lw 	$s1, 4($a3) #stores colour of next pixel 
	beq	$s1,$t2,DEAD #if yellow, you lose
	j	Paint

setGreen_a:
	addi    $s0,$s0,-1 #updates t0 to curr col
	j       setGreen
setGreen_b:
	addi    $s0,$s0,1 #updates t0 to curr col
setGreen:
	blt     $t3,$t5,Pass #if t3 is less than the max height of the pipe, colour green
	blt     $t3,$t6,Paint #if t3 is greater than the min height of the pipe, colour green
Pass:
	lw      $a2, green  #set painting colour to green
	lw 	$s1, 4($a3) #stores colour of next ipxel 
	beq	$s1,0xffea00,DEAD #if yellow, you lose
	j       Paint
pipeHeight:
	li $v0, 42
	li $a1,20 #randomizer range
	syscall 
	li $v0,1
	syscall
	
	add $t5,$t5,$a0 #changes pipes height
	add $t6,$t6,$a0
	j  setGreen
#Fall:
#	addi    $t2,$t2,-3
#	bne     $t3,$t2,pixelCont
#	lw      $a2, yellow #set painting colour to yellow
#	lw 	$s1, 4($a3) #stores colour of next pixel 
#	beq	$s1,$t2,DEAD #if yellow, you lose
#	j	Paint
#Fly:
#	addi    $t2,$t2,3
#	bne     $t3,$t2,pixelCont
#	lw      $a2, yellow #set painting colour to yellow
#	lw 	$s1, 4($a3) #stores colour of next pixel 
#	beq	$s1,$t2,DEAD #if yellow, you lose
#	j	Paint
DEAD:
	la $a0, lose
	li $v0,4
	syscall
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall