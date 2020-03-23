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
	lw $t0, displayAddress	# $t0 stores the base address for display
li      $t1, 0x2ca0b8     #Loading RED in register
li      $t2, 0x2cb870     #Loading GREEN in register
big_loop:
    move  $a0, $gp
    # 14 red rows with yellow endings+starts
    li      $t0, 31
red_rows_loop:
    li      $a1, 31
    move    $a2, $t1
    jal     setPixels           # set 30 red pixels in middle
    #sw      $t2, ($a0)          # set 1 yellow at end, and 1 at start of next row
    #sw      $t2, 4($a0)
    #addi    $a0, $a0, 8
    addi    $t0, $t0, -1
    bnez    $t0, red_rows_loop
    # finish last row to be full yellow
    li      $a1, 31           # 31 pixels more needed (1 is already there)
    move    $a2, $t1            # yellow
    jal     setPixels

    li      $v0, 32             # MARS service delay(ms)
    li      $a0, 40             # 40ms = ~25 FPS if the draw would be instant
    syscall

    addiu   $t1, $t1, 0xFE0408  # adjust main color (red -2, green +4, blue +8 + overflows (B -> G -> R)
    andi    $t1, $t1, 0xFFFFFF  # force "alpha" to zero
    j       Exit           # infinite loop will animated colours...

# Sets $a1 pixels to $a2 value starting at $a0 (memory fill)
# a0 = pointer to write to, a1 = count of pixels, a2 = value of pixel to set
# a0 will be updated to point right after the last written word
setPixels:
move $s0, $ra
#beq $a1,14,setgreen
#beq $a1,15,setgreen
#beq $a1,17,setgreen
    sw      $a2, ($a0)      # set pixel (or simply memory word)
    addi    $a0, $a0, 4     # advance memory pointer
    addi    $a1, $a1, -1    # count-down loop
    bnez    $a1, setPixels
    jr      $s0             # return
setgreen:
	move $a2, $t2
	jr $ra
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
