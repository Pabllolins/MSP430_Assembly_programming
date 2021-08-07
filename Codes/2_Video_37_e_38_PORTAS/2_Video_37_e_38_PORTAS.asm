#include <msp430G2231.h>
;--------------------------------------------------------
;	ORG = ORIGEM - (DIRETIVA DO IAR)
	ORG 	0F800h ; Program Start
;--------------------------------------------------------
Simbora	mov 	#0280h,SP ; Initialize stackpointer with label Simbora
StopWDT mov.w 	#WDTPW+WDTHOLD,&WDTCTL ; Stop WDT
SetupP1	bis.b 	#0F7h,&P1DIR ; (F7h)11110111 just pin 3 from P1 is input all others as output
Main	xor.b 	#041h,&P1OUT ; Invert the values (41h) 01000001 
testap1 bit.b	#003h, &P1IN ; Makes read at pin 3 from PORT1
	;jnz	TestaP1
Wait	mov.w 	#65535,R15 ; Delay to R15
L1	dec 	R15 ; Decrement R15
	jnz 	L1 ; Delay over?
	jmp 	Main ; Again
;--------------------------------------------------------
; Interrupt Vectors
;--------------------------------------------------------
	ORG 0FFFEh ; MSP430 RESET Vector
	DW Simbora ; DW = Declarated Word
	END