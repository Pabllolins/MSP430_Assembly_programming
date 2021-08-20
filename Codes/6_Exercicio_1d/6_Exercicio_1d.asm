#include <msp430G2231.h>
;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 19/08/2021(dd/mm/yyyy)
;Code: 10.4. 2 botões, 2 Leds e temporização simples
;MCU: MSP430G2231
;
;MSP-EXP430G2 LaunchPad - Board Default set
;Switch S1 => RST/SBWTDIO (IN)	
;
;P1.0 => LED1 (OUT)
;P1.3 => Switch S2 (IN)
;P1.4 => Switch S2 
;P1.6 => LED2 (OUT)		

		ORG 	0F800h ; Program Start
;--------------------------------------------------------
Partida		mov 	#0280h,SP ; Initialize stackpointer with label Partida
StopWDT 	mov.w 	#WDTPW+WDTHOLD,&WDTCTL ; Stop WDT

ConfiguraPorta1	bis.b 	#0E7h,&P1DIR ; (E7h)11100111 - just pin 3 an 4 are inputs, and all others pin is output
ConfiguraPorta2	bis.b 	#0FFh,&P2DIR ; (E7h)11111111 - All pins are output

AcendeTudoP1	bis.b 	#0FFh,&P1OUT ; (FFh)11111111 - LED1 => P1.0 and LED2 => P1.6 and all another pins from P1 is set
TestaChaveS2 	bit.b	#008h,&P1IN ; (08h)00001000 - S2 => P1.3 - Makes read at pin 3 from PORT1
		jz 	ApagaLED1 ; If the previously test results 0, jump to label
TestaChaveS1 	bit.b	#010h,&P1IN ; (10h)00010000 - S1 => P1.4 - Makes read at pin 4 from PORT1
		jz 	ApagaLED2 ; If the previously test results 0, jump to label
		jmp 	AcendeTudoP1 ; jump to label

ApagaLED1	bic.b 	#001h,&P1OUT ; (01h)00000001 - LED1 => P1.0 - Set the value 1 at this pin
		jmp	MultiplicaDec
		
ApagaLED2	bic.b 	#040h,&P1OUT ; (40h)01000000 - LED2 => P1.6 - Set the value 1 at this pin
		jmp	MultiplicaDec		
		
MultiplicaDec   mov.b 	#6,R4 ; Set a number at R4 register
Poe_50000_R15	mov.w 	#50000,R15 ; Set a number at R15 register
DecrementaR15	dec 	R15 ; Decrement 1 from R15
		jnz 	DecrementaR15 ; If R15 is not zero, decrement R15 again	
		dec 	R4 ; Decrement 1 from R4		
		jnz 	Poe_50000_R15 ; If R4 is not zero, set 50000 at R15 again

		jmp 	AcendeTudoP1 ; jump to label
;--------------------------------------------------------
; Interrupt Vectors
;--------------------------------------------------------
		ORG 0FFFEh ; MSP430 RESET Vector
		DW Partida ; DW = Declarated Word
		END