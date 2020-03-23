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
li      $t1, 0x2ca0b8     #Loading BLUE in register
li      $t2, 0x2cb870     #Loading GREEN in register

reset:
li $t4, 1

big_loop:

move  $a0, $gp
li      $t0, 32
    # 14 red rows with yellow endings+starts
blue_rows_loop:
    li      $a1, 32
    move    $a2, $t1
    jal     setPixels           # set 30 red pixels in middle
    addi    $t0, $t0, -1
    bnez    $t0, blue_rows_loop

    li      $v0, 32             # MARS service delay(ms)
    li      $a0, 40             # 40ms = ~25 FPS if the draw would be instant
    syscall

    #addiu   $t1, $t1, 0xFE0408  # adjust main color (red -2, green +4, blue +8 + overflows (B -> G -> R)
    #andi    $t1, $t1, 0xFFFFFF  # force "alpha" to zero
    add $t4, $t4, 1
    bge $t4, 33, reset 
    j       big_loop           # infinite loop will animated colours...

# Sets $a1 pixels to $a2 value starting at $a0 (memory fill)
# a0 = pointer to write to, a1 = count of pixels, a2 = value of pixel to set
# a0 will be updated to point right after the last written word
setPixels:
beq $a1,$t4,setgreen

    sw      $a2, ($a0)      # set pixel (or simply memory word)
    addi    $a0, $a0, 4     # advance memory pointer
    addi    $a1, $a1, -1    # count-down loop
    bnez    $a1, setPixels
    jr      $ra             # return
setgreen:
    move $a2, $t2
    sw      $a2, ($a0)      # set pixel (or simply memory word)
    addi    $a0, $a0, 4     # advance memory pointer
    addi    $a1, $a1, -1    # count-down loop
    move $a2, $t1
    bnez    $a1, setPixels
    jr      $ra             # return
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
