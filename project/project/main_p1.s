@LED Cycle program
@
@This program will cycle through LED0 to LED3 with a 2 seconds delay time between each LED.
@Each LED will turn on for 2 seconds and then turn off before the next LED is turn
@on. After that it will cycle back from LED3 to LED0 once it hit LED3 from the first cycle,
@and then the program will continue cycle from LED0 to LED3 then LED3 to LED0.
@
@Martin Nguyen
@
@The program is being base on Doughlas V. Hall and being modify to cycle through LED0 to LED3

.text
.global _start

_start:
LIGHT:
	mov R0, #0x02 @value to enable clock for GPIO module
    ldr R1, =0x44E000AC @address of CM_PER_GPIO clock
    str R0,[R1] @wake up the clock

    ldr R0,=0xFFDFFFFF @load word to GPIO21 as output
    ldr R1,=0x4804C134 @address of GPIO_OE register
    ldr R2,[R1] @read GPIO1_OE register
    and R2,R2,R0 @mod word read in
    str R2,[R1] @write back to GPIO1_OE


    mov R5,#0x00200000 @enable GPIO 21
    ldr R6,=0x4804C194 @Load address of GPIO1_SETDATAOUT reg
    str R5,[R6] @Write to GPIO1_SETDATAOUT reg

	mov R7,#0x00400000 @set 2 seconds delay by having 40k ns
loop:
	nop
	subs R7,#1 @minus 1ns from 40k ns
	bne loop @loop until R7 is 0

	mov R5,#0x00200000 @set GPIO 21  to turn off
	ldr R6,=0x4804C190 @sent the data to CLEARDATAOUT
	str R5,[R6] @turn off GPIO 21

	ldr R0,=0xFFBFFFFF @enable GPIO22
	and R2,R2,R0 @mod word read in
    str R2,[R1] @write back to GPIO1_OE

 	mov R5,#0x00400000 @enable GPIO 22
    ldr R6,=0x4804C194 @load the address of GPIO1_SETDATAOUT
    str R5,[R6] @Turn on the light by sent out the signal

	mov R7,#0x00400000 @set 2 seconds delay by having 40k ns
loop1:
	nop
	subs R7,#1 @minus 1ns from 40k ns
	bne loop1 @loop until R7 is 0

	mov R5,#0x00400000 @set GPIO 22  to turn off
	ldr R6,=0x4804C190 @sent the data to CLEARDATAOUT
	str R5,[R6] @turn off GPIO 22

	ldr R0,=0xFF7FFFFF @Enable GPIO23
	and R2,R2,R0 @mod word read in
    str R2,[R1] @write back to GPIO1_OE

 	mov R5,#0x00800000 @enable GPIO 23
    ldr R6,=0x4804C194
    str R5,[R6]

	mov R7,#0x00400000 @set 2 seconds delay by having 40k ns
loop2:
	nop
	subs R7,#1 @minus 1ns from 40k ns
	bne loop2 @loop until R7 is 0

	mov R5,#0x00800000 @set GPIO 23  to turn off
	ldr R6,=0x4804C190 @sent the data to CLEARDATAOUT
	str R5,[R6] @turn off GPIO 23

	ldr R0,=0xFEFFFFFF @enable GPIO24
	and R2,R2,R0 @mod word read in
    str R2,[R1] @write back to GPIO1_OE

 	mov R5,#0x01000000 @enable GPIO 24
    ldr R6,=0x4804C194
    str R5,[R6]
	nop

	mov R7,#0x00400000 @set 2 seconds delay by having 40k ns
loop3:
	nop
	subs R7,#1 @minus 1ns from 40k ns
	bne loop3 @loop until R7 is 0

	mov R5,#0x01000000 @set GPIO 24 to turn off
	ldr R6,=0x4804C190 @sent the data to CLEARDATAOUT
	str R5,[R6] @turn off GPIO 24

@display from 24 - 21 after all LED is shut off
	mov R7,#0x00400000 @set 2 seconds delay by having 40k ns
loop4:
	nop
	subs R7,#1 @minus 1ns from 40k ns
	bne loop4 @loop until R7 is 0

	ldr R0,=0xFEFFFFFF @enable GPIO24
	and R2,R2,R0 @mod word read in
    str R2,[R1] @write back to GPIO1_OE

 	mov R5,#0x01000000 @enable GPIO 24
    ldr R6,=0x4804C194
    str R5,[R6]
	nop

	mov R7,#0x00400000 @set 2 seconds delay by having 40k ns
loop5:
	nop
	subs R7,#1 @minus 1ns from 40k ns
	bne loop5 @loop until R7 is 0

	mov R5,#0x01000000 @set GPIO 24 to turn off
	ldr R6,=0x4804C190 @sent the data to CLEARDATAOUT
	str R5,[R6] @turn off GPIO 24

	ldr R0,=0xFF7FFFFF @Enable GPIO23
	and R2,R2,R0 @mod word read in
    str R2,[R1] @write back to GPIO1_OE

 	mov R5,#0x00800000 @enable GPIO 23
    ldr R6,=0x4804C194
    str R5,[R6]

	mov R7,#0x00400000 @set 2 seconds delay by having 40k ns
loop6:
	nop
	subs R7,#1 @minus 1ns from 40k ns
	bne loop6 @loop until R7 is 0

	mov R5,#0x00800000 @set GPIO 23 to turn off
	ldr R6,=0x4804C190 @sent the data to CLEARDATAOUT
	str R5,[R6] @turn off GPIO 23

	ldr R0,=0xFFBFFFFF @enable GPIO22
	and R2,R2,R0 @mod word read in
    str R2,[R1] @write back to GPIO1_OE

 	mov R5,#0x00400000 @enable GPIO 22
    ldr R6,=0x4804C194 @load the address of GPIO1_SETDATAOUT
    str R5,[R6] @Turn on the light by sent out the signal

	mov R7,#0x00400000 @set 2 seconds delay by having 40k ns
loop7:
	nop
	subs R7,#1 @minus 1ns from 40k ns
	bne loop7 @loop until R7 is 0

	mov R5,#0x00400000 @set GPIO 22 to turn off
	ldr R6,=0x4804C190 @sent the data to CLEARDATAOUT
	str R5,[R6] @turn off GPIO 22

	ldr R0,=0xFFDFFFFF @enable GPIO21
	and R2,R2,R0 @mod word read in
    str R2,[R1] @write back to GPIO1_OE

 	mov R5,#0x00200000 @enable GPIO 21
    ldr R6,=0x4804C194 @load the address of GPIO1_SETDATAOUT
    str R5,[R6] @Turn on the light by sent out the signal

 	mov R7,#0x00400000 @set 2 seconds delay by having 40k ns
loop8:
	nop
	subs R7,#1 @minus 1ns from 40k ns
	bne loop8 @loop until R7 is 0

	mov R5,#0x00200000 @set GPIO 21 to turn off
	ldr R6,=0x4804C190 @sent the data to CLEARDATAOUT
	str R5,[R6] @turn off GPIO 21


	b LIGHT
.END








