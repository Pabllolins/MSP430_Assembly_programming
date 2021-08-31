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
		bic.b 	#008h,&P1DIR ; (F7h)00001000 - Port P1 - pin 3 as input (clear putting 0 to be input)				
		bis.b 	#008h,&P1REN ; (08h)00001000 - Port P1 - pin 3 resistor enable
		bis.b 	#008h,&P1IE ; (08h)00001000 - Port P1 - pin 3 interrupt enable

		bis.b 	#001h,&P1DIR ; (01h)00000001 - LED1 => P1.0 as output (clear putting 1 to be output)
ApagaP1_0	bic.b 	#001h,&P1OUT ; (01h)00000001 - LED1 => P1.0 and all another pins from P1 is clear

Loop	 	bis.w 	#LPM3+GIE,SR ; Enter LPM3, enable interrupts - (LPM3 - Low Power Mode 3)(GIE - General Interrupt Enable)(SR - Status Register)
		nop;
;------------------------------------------------------------------------------
AcendeLed1	bis.b 	#001h,&P1OUT ; (01h)00000001 - LED1 => P1.0 - Set the value 1 at this pin
Porta1_int	bit.b	#008h,&P1IN ; (08h)00001000 - Makes read at pin 3 from PORT1
		jz 	AcendeLed1 ; If the previously test results 0, jump to label
		bic.b 	#008h,&P1IFG ; Port P1 - pin 3 interrupt flag			
		jmp ApagaP1_0			
		reti //Retorno de interrupção				
;------------------------------------------------------------------------------
;		Interrupt Vectors 
;------------------------------------------------------------------------------
		COMMON INTVEC ; Interrupt Vectors //(COMMON) Begins a common segment.
		ORG RESET_VECTOR ; (ORG - Origin) MSP430 RESET Vector 
		DW Partida ; (Declara Word) da origem anterior (2ª Obrigação) Declara o vetor de reset
		ORG PORT1_VECTOR ; MSP430 Basic Timer Interrupt Vector 0xFFE4
		DW Porta1_int		
		END
;------------------------------------------------------------------------------