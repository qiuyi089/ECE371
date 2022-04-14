@Timer/LED button interrupt program
@
@This program will turn on LED0 when receive a low signal from GPIO1_30
@when the button is press it will sent a interrupt signal to IRQ and
@it will then turn on the LED0. The LED0 will stay on for 2 seconds using Timer5
@Once 2 seconds is up Timer5 will sent a interrupt signal and that will turn off the light
@
@Martin Nguyen
@
@This program is being base on Doughlas V. Hall program. It have been modify to work with GPIO1_30, GPIO1_21, and Timer5


.text
.global _start
.global INT_DIRECTOR

_start:
	ldr R13,=STACK1  @point to base of STACK for SVC mode
	add R13, R13,#0x1000 @point to top of STACK
	cps #0x12 @switch to IRQ mode
	ldr R13,=STACK2 @point to IRQ STACK
	add R13,R13,#0x1000 @point to top of STACK
	cps #0x13 @ switch back to SVC mode
	@turn on GPIO1 CLK
	ldr R0,=0x02 @value to enable the clock for an GPIO module
	ldr R1,=0x44E000AC @ address of CM_PER_GPIO1_CLKCTRL register
	str R0,[R1] @write 0x02 to register
	@make sure GPIO1_21 is off
	ldr R0,=0x4804C000 @base address of GPIO1 register
	add R4,R0,#0x190 @off set of CLEARDATAOUT, add the base address and the offset together
	mov R7,#0x00200000 @load the value that would turn off GPIO1_21 off to make sure that the LED0 isn't on
	str R7,[R4] @ write the value to CLEARDATAOUT
	@make GPIO1_21 as an output
	add R1,R0,#0x0134 @create GPIO1_OE address
	ldr R6,[R1] @read current GPIO1 output enable register
	ldr R7,=0xFFDFFFFF @enable GPIO1_21 as output
	and R6,R7,R6 @modify bit 21
	str R6,[R1] @write to GPIO1 output enable register
	@detect falling edge on GPIO1_30 on pin 21
	add R1,R0,#0x14C @GPIO_FALLINGDETECT register
	mov R2,#0x40000000 @Load value for bit 30
	ldr R3,[R1] @ read GPIO1_FALLINGDETECT register
	orr R3,R3,R2 @modify bit 30
	str R3,[R1] @write back
	add R1,R0,#0x34 @address of GPIO1_IRQSTATUS_SET_0 register
	str R2,[R1] @enable GPIO1_30 request on POINTRPEND1
	@initialize INTC
	ldr R1,=0x48200000 @base address for INTC
	mov R2,#0x2 @value to reset INTC
	str R2,[R1,#0x10] @write to INTC Config register
	mov R2,#0x20000000    @unmask INTC INT 93, Timer5 interrupt
	str R2,[R1,#0xC8] @write to INTC_MIR_CLEAR2
	mov R2,#0x04 @value to unmask INTC INT 98, GPIOINTA
	str R2,[R1,#0xE8] @write to INTC_MIR_CLEAR3 register
	@turn on Timer5 CLK
	mov R2,#0x2 @value to enable Timer5 CLK
	ldr R1,=0x44E000EC  @address of CM_PER_TIMER5_CLKCTRL
	str R2,[R1] @turn on
	ldr R1,=0x44E00518  @address of PRCMCLKSEL_TIMER5 register
	str R2,[R1] @select 32Khz CLK for Timer5
	@initialize timer 2 registers, with count, overflow interrupt generation
	ldr R1,=0x48046000  @Base address for Timer5 register
	mov R2,#0x1 @value to reset Timer5
	str R2,[R1,#0x10] @write to Timer5 CFG register
	mov R2,#0x2 @value to enable overflow interrupt
	str R2,[R1,#0x2C] @write to Timer5 IRQENABLE_SET
	ldr R2,=0xFFFF0000 @count value for 2 seconds
	str R2,[R1,#0x40] @Timer5 TLDR load register
	str R2,[R1,#0x3C] @write to Timer5 TCRR count register
	@make sure processor IRQ enabled in CPSR
	MRS R3, CPSR @copy CPSR to R3
	BIC R3,#0x80 @clear bit 7
	MSR CPSR_c, R3 @write back to CPSR
 @wait for interrupt
LOOP: NOP
	B LOOP

INT_DIRECTOR:
	STMFD SP!,{R0-R3,LR} @push registers on stack
	ldr R1,=0x482000F8 @address of INTC_PENDING_IRQ3 register
	ldr R2,[R1] @read INTC_PENDING_IRQ3 register
	TST R2,#0x00000004 @test bit 2
	BEQ TCHK @not GPIOINT1A, check if Timer5, else
	ldr R0,=0x4804C02C @GPIO_IRQSTATUS_0 register address
	ldr R1,[R0] @read STATUS register to see if button
	TST R1,#0x40000000 @check if bit 30 = 1
	bne BUTTON_SVC @ if bit 30 = 1, button push, service
	ldr R0,=0x48200048 @else, go back. INTC_CONTROL register
	mov R1,#01 @value to clear bit 0
	str R1,[R0] @write to INTC_CONTROL register
	LDMFD SP!,{R0-R3,LR} @restore register
	subs PC,LR,#4 @pass execution to wait LOOP for now

TCHK:
	ldr R1,=0x482000D8 @address of INTC PENDING_1IRQ2 register
	ldr R0,[R1] @read value
	TST R0,#0x20000000  @check if interrupt from Timer5
	BEQ PASS_ON @no, return yes, check for overflow
	ldr R1,=0x48046028  @address of Timer5 IRQSTATUS register
	ldr R0,[R1] @read value
	TST R0,#0x2 @check bit 1
	BNE LED @if overflow, then go toggle LED
	PASS_ON: @else go back to wait loop
	ldr R0,=0x48200048 @address of INTC_CONTROL register
	mov R1,#01    @value to clear bit 0
	str R1,[R0] @write to INT_CONTROL register
	LDMFD SP!,{R0-R3,LR} @restore register
	subs PC,LR,#4 @pass execution to wait LOOP for now

	LDMFD SP!,{R0-R3,LR} @restore register
	subs PC,LR,#4 @pass execution to wait LOOP for now

BUTTON_SVC:
	mov R1,#0x40000000 @value to turn off GPIO1_30 IRQ request. This will turn off INTC IRQ request also
	str R1,[R0] @write to GPIO1_IRQSTATUS_0 register
	@turn on LED0 GPIO1_21
	ldr R0,=0x4804C194 @load address of GPIO1_SETDATAOUT register
	mov R1,#0x00200000 @load value to turn on GPIO1_21
	str R1,[R0] @write value to GPIO1_SETDATAOUT register

	ldr R1,=0x48046000 @address of Timer5 TCLR register
	ldr R2,=0xFFFF0000 @value load for 2 seconds
	str R2,[R1,#0x40] @Timer5 TLDR load register
	str R2,[R1,#0x3C] @write to Timer5 TCRR count register

	mov R2,#0x01  @value to make timer wait for 2 seconds
	ldr R1,=0x48046038 @address of Timer5 TCLR register
	str R2,[R1] @write to TCLR register
	@turn off NEWIRQA bit in INTC_CONTROL, so can respond to new IRQ
	ldr R0,=0x48200048 @address of INTC_CONTROL register
	mov R1,#01 @value to clear bit 0
	str R1,[R0] @write to INTC_CONTROL register
	LDMFD SP!,{R0-R3,LR} @restore register
	subs PC,LR,#4 @pass execution on to wait LOOP for now
LED:
	@turn off timer 5 interrupt request and enable INTC for next IRQ
	ldr R1,=0x48046028  @load address of Timer5 IRQSTATUS register
	mov R2,#0x2 @value to reset Timer5 Overflow IRQ request
	str R2,[R1] @write
	@toggle LED
	ldr R1,=0x4804C000 @base address of GPIO1
	ldr R2,[R1,#0x013C] @read value from GPIO_DATAOUT
	TST R2,#0x00200000    @check bit 21 where LED is connect
	mov R2,#0x00200000    @value to set or clear bit 21
	BNE TOFF @LED on, go turn off
	str R2,[R1,#0x194] @LED off, turn on with GPTIO1_SETDATAOUT
	B BACK @back to wait LOOP
TOFF:
	ldr R2,=0x00200000 @value to turn off GPIO1_21
	str R2,[R1,#0x190] @turn LED off with GPIO1_CLEARDATAOUT
	BACK:
	ldr R1,=0x48200048 @address of INTC_CONTROL register
	mov R2,#0x01 @value to enable new IRQ response in INTC
	str R2,[R1] @write
	ldmfd SP!,{R0-R3,LR} @restore register
	subs PC,LR,#4 @return from IRQ interrupt procedure


.data
.align 2
STACK1: .rept 1024
		.word 0x0000
		.endr
STACK2: .rept 1024
		.word 0x0000
		.endr
.END
