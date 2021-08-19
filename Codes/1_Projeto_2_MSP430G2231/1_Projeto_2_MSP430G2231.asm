;#include <msp430.h>
#include <msp430G2231.h>
;--------------------------------------------------------
;	ORG = ORIGEM - (DIRETIVA DO IAR)
	ORG 	0F800h ; Program Start
;--------------------------------------------------------
;RESET	mov 	#0280h,SP ; Initialize stackpointer
Simbora	mov 	#0280h,SP ; Initialize stackpointer
StopWDT mov.w 	#WDTPW+WDTHOLD,&WDTCTL ; Stop WDT
SetupP1	bis.b 	#0F7h,&P1DIR ; All P1 as output, less P1.3 input
;Main	xor.b 	#1,&P1OUT ; Toggle P1.0 and
Main	xor.b 	#041h,&P1OUT ; Toggle P1.0 and
testap1 bit.b	#003h, &P2IN
	;jnz	TestaS1
Wait	mov.w 	#65535,R15 ; Delay to R15
L1	dec 	R15 ; Decrement R15
	jnz 	L1 ; Delay over?
	jmp 	Main ; Again
;--------------------------------------------------------
; Interrupt Vectors
;--------------------------------------------------------
	ORG 0FFFEh ; MSP430 RESET Vector
	;DW RESET ; DW = Declarated Word
	DW Simbora ; DW = Declarated Word
	END