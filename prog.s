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
	
.text
#lw $t0, displayAddress	# $t0 stores the base address for display
	li      $t1, 0x2ca0b8     #Loading BLUE in register
	li      $t2, 0x2cb870     #Loading GREEN in register
	li      $t3, 0xffea00	# Load YELLOW into this register

reset:
	li      $s0, 1 #keeps track of where to draw the pipe
	li      $a0, 0 #reset random pipe height
	li      $t5, 2 #pipe max height for top
	li      $t6, 11 #pipe max height for bottom

main:
	move    $a3, $gp
	li      $t3, 32 #keeps track of which row we are on 

blue_rows_loop:
	li      $t4, 32 #keeps track of which column we are on
	jal     setPixels           
	addi    $t3, $t3, -1
	bnez    $t3, blue_rows_loop # colours a row and loops back if not on the last row

	li      $v0, 32             # MARS service delay(ms)
	li      $a0, 250             # 40ms = ~25 FPS if the draw would be instant
	syscall

    #addiu   $t1, $t1, 0xFE0408  # adjust main color (red -2, green +4, blue +8 + overflows (B -> G -> R)
    #andi    $t1, $t1, 0xFFFFFF  # force "alpha" to zero
    
	add     $s0, $s0, 1 #moves the pipe down one pixel to create animation
	bge     $s0, 32, reset 
	j       main           # infinite loop will animated colours...

setPixels:
	beq     $t4,26,setYellow
pipeCont:
	move    $a2, $t1 #set painting colour to blue
	beqz    $a0,pipe_height #if a0=0, then we need to find a new pipe height for this "frame"
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
	bne     $t3,16,pipeCont
	li      $a2, 0xffea00 #set painting colour to yellow
	j	Paint

setGreen_a:
	addi    $s0,$s0,-1 #updates t0 to curr col
	j       setGreen
setGreen_b:
	addi    $s0,$s0,1 #updates t0 to curr col
setGreen:
	blt     $t3,$t5,pass #if t3 is less than the max height of the pipe, colour green
	blt     $t3,$t6,Paint #if t3 is greater than the min height of the pipe, colour green
	
pass:
	move    $a2, $t2  #set painting colour to green
	j       Paint


pipe_height:
li $v0, 42
li $a1,20 #randomizer range
syscall 
li $v0,1
syscall
add $t5,$t5,$a0 #changes pipes height
add $t6,$t6,$a0
j  setGreen
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
