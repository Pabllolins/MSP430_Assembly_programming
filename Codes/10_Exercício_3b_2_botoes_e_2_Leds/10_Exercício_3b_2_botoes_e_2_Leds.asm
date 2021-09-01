;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 01/09/2021(dd/mm/yyyy)
;Code: 14.2. Exercício 3b:2 botões e 2 Leds
;MCU: MSP430G2231
;
;MSP-EXP430G2 LaunchPad - Board Default set
;Switch S1 => RST/SBWTDIO (IN)	
;Switch S2 => P1.3 (IN)
;Switch S4 => P1.4 
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

		bic.b 	#018h,&P1SEL ; (18h)00011000 - Port P1 - pin 3 and pin 4 selection
		bic.b 	#018h,&P1DIR ; (18h)00011000 - Port P1 - pin 3 and pin 4 as input (clear putting 0 to be input)				
		bis.b 	#018h,&P1REN ; (18h)00011000 - Port P1 - pin 3 and pin 4 resistor enable
		bis.b 	#018h,&P1IE ; (18h)00011000 - Port P1 - pin 3 and pin 4 interrupt enable
		
		bis.b 	#041h,&P1DIR ; (F7h)01000001 - Port P1 - pin 0 and 6 as output	
AcendeP1_0_6	bis.b 	#041h,&P1OUT ; (41h)01000001 - LED1 => P1.0 and LED2 => P1.6 are ON

Loop	 	bis.w 	#LPM3+GIE,SR ; Enter LPM3, enable interrupts - (LPM3 - Low Power Mode 3)(GIE - General Interrupt Enable)(SR - Status Register)
		nop;

ApagaP1_0	bic.b 	#001h,&P1OUT ; (01h)00000001 - LED1 => P1.0 - Set the value 0 at this pin		
		jmp 	Porta1_int
ApagaP1_6	bic.b 	#040h,&P1OUT ; (01h)01000000 - LED2 => P1.6 - Set the value 0 at this pin				
		jmp	Porta1_int
		
;------------------------------------------------------------------------------		
Porta1_int	bit.b	#008h,&P1IN ; (08h)00001000 - Makes read at pin 3 from PORT1
		jz 	ApagaP1_0 ; If the previously test results 0, jump to label				
		bit.b	#010h,&P1IN ; (08h)00010000 - Makes read at pin 3 from PORT1
		jz 	ApagaP1_6 ; If the previously test results 0, jump to label				
		bic.b 	#008h,&P1IFG ; Port P1 - pin 3 interrupt flag	
		bic.b 	#010h,&P1IFG ; Port P1 - pin 4 interrupt flag
		jmp AcendeP1_0_6
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