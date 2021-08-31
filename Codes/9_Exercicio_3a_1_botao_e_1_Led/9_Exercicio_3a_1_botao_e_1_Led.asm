;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 30/08/2021(dd/mm/yyyy)
;Code: 14.1. Exercício 3a:1 botão e 1 Led
;MCU: MSP430G2231
;
;MSP-EXP430G2 LaunchPad - Board Default set
;Switch S1 => RST/SBWTDIO (IN)	
;Switch S2 => P1.3 (IN)
;LED1 => P1.0 (OUT)	
;LED2 => P1.6 (OUT)	
;-------------------------------------------------------
#include <msp430G2231.h>
;-------------------------------------------------------------------------------
		RSEG CSTACK ; (RSEG - Register Segment) Define stack segment 
;-------------------------------------------------------------------------------
		RSEG CODE ; (RSEG - Register Segment) Informa ao compilador que abaixo é código a ser gravado/Assemble to Flash memory
;-----------------------------------------------------------------------------
Partida 	mov.w #SFE(CSTACK),SP ; (1ª Obrigação) Initialize stackpointer
StopWDT 	mov.w #WDTPW+WDTHOLD,&WDTCTL ; Stop WDT (3ª Obrigação) Manipular o Watch dog time

		bic.b 	#008h,&P1SEL ; (08h)00001000 - Port P1 - pin 3 selection
SetupPorta_1	bis.b 	#0F7h,&P1DIR ; (F7h)11110111 - just pin 3 is input, and all others pin is output
		bis.b 	#008h,&P1REN ; Port P1 - pin 3 resistor enable
		bis.b 	#008h,&P1IE ; Port P1 - pin 3 interrupt enable

ApagaTudo	bic.b 	#0FFh,&P1OUT ; (FFh)11111111 - LED1 => P1.0 and all another pins from P1 is clear
		;bis.b 	#008h,&P1OUT ; Port P1 - pin 3 output
		;bis.b 	#P1IE,&IE1 ; (Port P1 interrupt enable) - (IE1 - Interrupt enable 1) //Habilita a interrupução do periferico
		
Loop	 	bis.w 	#LPM3+GIE,SR ; Enter LPM3, enable interrupts - (LPM3 - Low Power Mode 3)(GIE - General Interrupt Enable)(SR - Status Register)
		;jmp ApagaTudo
		;nop ; Required for Debugger
;------------------------------------------------------------------------------
Port1_int	xor.b 	#001h,&P1OUT ; (01h)01 - Toggle P1.0 (LED)
		bic.b 	#008h,&P1IFG ; Port P1 interrupt flag		
		;bis.b 	#001h,&P1OUT ; (01h)00000001 - LED1 => P1.0 - Set the value 1 at this pin
		reti //Retorno de interrupção
				
;------------------------------------------------------------------------------
;		Interrupt Vectors 
;------------------------------------------------------------------------------
		COMMON INTVEC ;(COMMON) - INTVEC (INTERRUPT VECTOR)
		
		ORG RESET_VECTOR ; (ORG - Origin) MSP430 RESET Vector 
		DW Partida ; (Declara Word) da origem anterior (2ª Obrigação) Declara o vetor de reset
		ORG PORT1_VECTOR ; MSP430 Basic Timer Interrupt Vector
		DW Port1_int
		
		END
;------------------------------------------------------------------------------