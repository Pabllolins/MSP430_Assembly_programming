#include <msp430G2231.h>
;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 13/08/2021(dd/mm/yyyy)
;Code: 10.2. Exercício 1b: 2 botoes e 2 Leds
;
;MCU: MSP430G2231
;	
;Adaptation switch x (Sx) => P1.4
		ORG 	0F800h ; Program Start
;--------------------------------------------------------
Partida		mov 	#0280h,SP ; Initialize stackpointer with label Partida
StopWDT 	mov.w 	#WDTPW+WDTHOLD,&WDTCTL ; Stop WDT

ConfiguraPorta1	bis.b 	#0E7h,&P1DIR ; (E7h)11100111 - just pin 3 an 4 are inputs, and all others pin is output
AcendeTudo	bis.b 	#0FFh,&P1OUT ; (FFh)11111111 - LED1 => P1.0 and LED2 => P1.6 all another pins from P1 is set
TestaChaveS2 	bit.b	#008h,&P1IN ; (08h)00001000 - S2 => P1.3 - Makes read at pin 3 from PORT1
		jz 	ApagaLed1 ; If the previously test results 0, jump to label
TestaChaveSx 	bit.b	#010h,&P1IN ; (10h)00010000 -  Makes read at pin 4 from PORT1
		jz 	ApagaLed2 ; If the previously test results 0, jump to label
		jmp 	AcendeTudo ; jump to label

ApagaLed1	bic.b 	#001h,&P1OUT ; (01h)00000001 - LED1 => P1.0 - Set the value 1 at this pin
		jmp 	TestaChaveS2 ; jump to label
ApagaLed2	bic.b 	#040h,&P1OUT ; (40h)01000000 - LED2 => P1.6 - Set the value 1 at this pin
		jmp 	TestaChaveSx ; jump to label
;--------------------------------------------------------
; Interrupt Vectors
;--------------------------------------------------------
		ORG 0FFFEh ; MSP430 RESET Vector
		DW Partida ; DW = Declarated Word
		END