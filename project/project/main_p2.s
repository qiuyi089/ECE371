@LED interrupt program
@
@The program whole purpose is to turn on LED0 when the button is being press.
@when the output from GPIO1_30 is being low, it will sent an interrupt signal to the processor.
@the processor will then turn on LED0 for 2 second before turning it off, and then wait for the
@next interrupt signal from the button.
@
@Martin Nguyen
@
@This program is being base on Doughlas V. Hall original code and it been modify to turn on LED0 on the BeagleBone Black


.text
.global _start
.global INT_DIRECTOR

_start:
	LDR R13,=STACK1  @Point to base of STACK for svc mod
	ADD R13,R13,#0x1000 @Point to top of STACK
	CPS #0x12    @Switch to IRQ mode
	LDR R13,=STACK2  @Point to IRQ mode
	ADD R13,R13,#0x1000  @Point to top of STACK
	CPS #0x13  @Back to SVC mode
	@Turn on GPIO CLK
	LDR R0,=0x02 @Enable clock for GPIO
	LDR R1,=0x44E000AC @Address of GPIO1_CLKCTRL register
	STR R0,[R1] @Enable GPIO1
	@Turn off GPIO21 just to make sure that the light is off when the program first run
	LDR R0,=0x4804C000  @Base address for GPIO1
	ADD R4, R0,#0x190  @Load in the address of CLEARDATAOUT by adding the base to 0x190
	MOV R7,#0x00200000 @Address of GPIO1_21
	STR R7,[R4]   @Turn off GPIO_21
	@make GPIO1_21 as an output
	ADD R1,R0,#0x0134  @Make the GPIO1_OE register address
	LDR R6,[R1]  @READ current GPIO1 output Enable register
	LDR R7,=0xFFDFFFFF @word to enable GPIO1_21 as output
	AND R6,R7,R6 @clear bit 21
	STR R6,[R1] @write to GPIO1 output register
	@Detect falling edge on GPIO1_30 which is pin 21
	ADD R1,R0,#0x14C @R1 = address of GPIO1_FALLINGDETECT register
	MOV R2,#0x40000000 @Load value for bit 30
	LDR R3,[R1] @Read GPIO1_FALLINGDETECT register
	ORR R3,R3,R2 @Modify (set bit 21)
	STR R3,[R1] @Write back
	ADD R1,R0,#0x34 @Address of GPIO1_IRQSTATUS_SET_0 register
	STR R2, [R1] @Enable GPIO1_21 request on POINTRPEND1
	@initialize INTC
	LDR R1,=0x482000E8 @Address of INTC_MIR_CLEAR3 register
	MOV R2,#0x04 @value to unmask INTC INT 98, GPIOINT1A
	STR R2,[R1] @Write to INTC_MIR_CLEAR3 register
	@Make sure processor IRQ enabled in CPSR
	MRS R3,CPSR @Copy CPSR to R3
	BIC R3,#0x80 @clear bit 7
	MSR CPSR_c,R3 @Write back to CPSR
	@Wait for interrupt
Loop: NOP
	B Loop

INT_DIRECTOR:
	STMFD SP!,{R0-R3,LR} @Push registers on stack
	LDR R0,=0x482000F8 @Address of INTC-PENDING_IRQ3 register
	LDR R1,[R0] @read INTC-PENDING_IRQ3 register
	TST R1,#0x00000004 @test bit 2
	BEQ PASS_ON  @Not from GPIOINT1A, go to back to wait loop, else
	LDR R0,=0x4804C02C @load GPIO1_IRQSTATUS_0 register address
	LDR R1,[R0] @read STATUS register
	TST R1,#0x40000000 @Check if bit 21 = 1
	BNE BUTTON_SVC @if bit 21 = 1, then button pushed
	BEQ PASS_ON @if bit 21 = 0, then go back to wait loop
PASS_ON:
	LDMFD SP!,{R0-R3,LR} @restore register
	SUBS PC,LR,#4 @pass execution on to wait Loop for now
BUTTON_SVC:
	MOV R1,#0x40000000 @Value turns off GPIO1_30 interrupt request and also turn off INTC interrupt request
	STR R1,[R0] @write to GPIO1_IRQSTATUS_0 register
	@Turn off NEWIRQA bit in INTC_CONTROL, so processor can respondto new IRQ
	LDR R0,=0x48200048 @address of INTC_CONTROL register
	MOV R1,#01 @value to clear bit 0
	STR R1,[R0] @write to INTC_CONTROL register
	@Turn on LED on GPIO1_21
	LDR R0,=0x4804C194 @load address of GPIO1_SETDATAOUT register
	MOV R1,#0x00200000 @load address of GPIO1_21 to turn on
	STR R1,[R0] @write to GPIO1_21SETDATAOUT register
	@wait for 2 seconds
	MOV R2,#0x00400000
Loop1:
	NOP
	SUBS R2,#1
	BNE Loop1
	@Turn off the LED GPIO1_21

	LDR R0,=0x4804C190 @load address of GPIO1_CLEARDATAOUT register
	STR R1,[R0] @write 0x00200000 GPIO1_21 turn on address to GPIO1_CLEARDATAOUT
	@return to wait loop
	LDMFD SP!,{R0-R3,LR}  @restore refisters
	SUBS PC,LR,#4 @return from IRQ interrupt procedure

.align 2
SYS_IRQ: .WORD 0 @location to store system IRQ address
.data
.align 2
STACK1: .rept 1024
		.word 0x0000
		.endr
STACK2: .rept 1024
		.word 0x0000
		.endr
.END



