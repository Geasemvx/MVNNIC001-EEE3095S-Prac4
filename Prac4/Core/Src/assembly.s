/*
 * assembly.s
 *
 */

 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:
	LDR R0, GPIOA_BASE     	@ Read the GPIOA input register
	LDR R3, [R0, #0x10]    	@ Load the input data register for GPIOA (offset 0x10)
B check_sw0
B check_sw1
B check_sw2
B check_sw3
default:
	ADDS R2, R2, #1
long_delay:
	LDR R0, LONG_DELAY_CNT 	@load delay count value


write_leds:
	SUBS R0, R0, #1  		@decrement counter
	BNE write_leds			@if not zero, keep looping
	STR R2, [R1, #0x14]
	B main_loop
increment_by_2:
	ADDS R2, R2, #2

	LDR R0, GPIOA_BASE     @ Reload the GPIOA input register to reset R3
    LDR R3, [R0, #0x10]    @ Load the input data register for GPIOA (offset 0x10)
	MOVS R4, #2           	@ Move 2 into R4 (mask for bit 0)
    ANDS R3, R3, R4        	@ Perform AND operation to check if bit 0 is set
    BNE long_delay	        @ If button not pressed (logic low), branch to long_delay
    LDR R0, SHORT_DELAY_CNT @load delay count value
	B write_leds
short_delay:
	LDR R0, SHORT_DELAY_CNT @load delay count value
	ADDS R2, R2, #1
	B write_leds
check_sw0:
	MOVS R4, #1           	@ Move 1 into R4 (mask for bit 0)
    ANDS R3, R3, R4        	@ Perform AND operation to check if bit 0 is set
    BEQ increment_by_2	    @ If button pressed (logic low), branch to increment_by_2
    B check_sw1
check_sw1:
	LDR R0, GPIOA_BASE     @ Reload the GPIOA input register to reset R3
    LDR R3, [R0, #0x10]    @ Load the input data register for GPIOA (offset 0x10)
	MOVS R4, #2           	@ Move 2 into R4 (mask for bit 0)
    ANDS R3, R3, R4        	@ Perform AND operation to check if bit 0 is set
    BEQ short_delay	        @ If button pressed (logic low), branch to increment_by_2
    B check_sw2
check_sw2:
	LDR R0, GPIOA_BASE     @ Reload the GPIOA input register to reset R3
    LDR R3, [R0, #0x10]    @ Load the input data register for GPIOA (offset 0x10)
	MOVS R4, #4           	@ Move 4 into R4 (mask for bit 0)
    ANDS R3, R3, R4        	@ Perform AND operation to check if bit 0 is set
    BEQ set_to_AA	    @ If button pressed (logic low), branch to increment_by_2
    B check_sw3
check_sw3:
	LDR R0, GPIOA_BASE     @ Reload the GPIOA input register to reset R3
    LDR R3, [R0, #0x10]    @ Load the input data register for GPIOA (offset 0x10)
	MOVS R4, #8           	@ Move 8 into R4 (mask for bit 0)
    ANDS R3, R3, R4        	@ Perform AND operation to check if bit 0 is set
    BEQ freeze	    @ If button pressed (logic low), branch to increment_by_2
    B default
set_to_AA:
	MOVS R2, #0xAA  @ Set R2 to 0xAA
	B long_delay
freeze:
	B long_delay

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 2000000
SHORT_DELAY_CNT: 	.word 700000
