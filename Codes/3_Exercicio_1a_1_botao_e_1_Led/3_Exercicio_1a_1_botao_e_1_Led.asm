#include <msp430G2231.h>
;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 12/08/2021(dd/mm/yyyy)
;Code: 10.1. Exercício 1a: 1 botão e 1 Led
;
;MCU: MSP430G2231
;	
		ORG 	0F800h ; Program Start
;--------------------------------------------------------
Partida		mov 	#0280h,SP ; Initialize stackpointer with label Partida
StopWDT 	mov.w 	#WDTPW+WDTHOLD,&WDTCTL ; Stop WDT

ConfiguraPorta1	bis.b 	#0F7h,&P1DIR ; (F7h)11110111 - just pin 3 is input, and all others pin is output
ApagaTudo	bic.b 	#0FFh,&P1OUT ; (FFh)11111111 - LED1 => P1.0 and all another pins from P1 is clear
TestaChave2 	bit.b	#008h,&P1IN ; (08h)00001000 - Makes read at pin 3 from PORT1
		jz 	AcendeLed1 ; If the previously test results 0, jump to label
		jmp 	ApagaTudo ; jump to label

AcendeLed1	bis.b 	#001h,&P1OUT ; (01h)00000001 - LED1 => P1.0 - Set the value 1 at this pin
		jmp 	ApagaTudo ; jump to label
;--------------------------------------------------------
; Interrupt Vectors
;--------------------------------------------------------
		ORG 0FFFEh ; MSP430 RESET Vector
		DW Partida ; DW = Declarated Word
		END