;-------------------------------------------------------------------------------
;Programer: Pabllo Lins
;Date: 17/09/2021(dd/mm/yyyy)
;Code: 17_Exercicio_5a
;-------------------------------------------------------------------------------
;PLACA: Experimenter Board   
;MCU: MSP430FG4618F/2013 (SIMULATOR)

;Switch S1 => P1.0 (IN)
;Switch S2 => P1.1 (IN)
;LED1 => P2.2 (OUT)	
;LED2 => P2.1 (OUT)	
;LED4 => P5.1 (OUT)
;Buzzer => P3.5 (OUT)
;CA0 => P1.6 (IN)
;CA1 => P1.7 (IN)
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;Active mode -> f(MCLK) = f(SMCLK) = 1,048576MHz // f(ACLK) = 32768 Hz
;Low-power mode (LPM3) -> f(MCLK) = f(SMCLK) = 0 MHz // f(ACLK) = 32768 Hz, SCG0 = 1,

;CAOUT (P2.6) - Comparator_A output
;CA1 (P1.7) - Comparator_A input
;CA0 (P1.6) - Comparator_A input
;------------------------------------------------------------------------------
;Condição de funcionamento
;CA0 (P1.6) - Comparator_A input
;Se VCA0 > 0,5*vcc = LED1-P2.2(ON) e LED2-P2.1(OFF)
;Se VCA0 < 0,5*vcc = LED1-P2.2(OFF) e LED2-P2.1(ON)
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
#include <msp430xG46x.h>
;-------------------------------------------------------------------------------
		RSEG CSTACK ; Define stack segment (RSEG - Register Segment)
;-------------------------------------------------------------------------------
		RSEG CODE ; Assemble to Flash memory
;-----------------------------------------------------------------------------
RESET 		mov.w 	#SFE(CSTACK),SP ; Initialize stackpointer
StopWDT 	mov.w 	#WDTPW+WDTHOLD,&WDTCTL ; Stop WDT
SetupFLL 	bis.b 	#XCAP14PF,&FLL_CTL0 ; Configure load caps		

SetupCA0	bic.b 	#040h,&P1DIR ; (40h)0100 0000 - CA0 => P1.6 (IN) as input
		bis.b  	#06Ah,&CACTL1 ; Comparator A Control 1
		//(6Ah)0110 1010
		//bit 7 = 0 -> CAEX (Comparator_A exchange)
		//bit 6 = 1 -> CARSEL (Comparator_A reference select)
		//bit 5,4 = 10 -> CAREF (Comparator_A reference)
		//bit 3 = 1 -> CAON (Comparator_A on)
		//bit 2 = 0 -> CAIES (Comparator_A interrupt edge select)(0 Rising edge) (1 Falling edge)
		//bit 1 = 1 -> CAIE (Comparator_A interrupt enable)
		//bit 0 = 0 -> CAIFG (Comparator_A interrupt flag)
		
		bis.b  	#006h,&CACTL2 ; Comparator A Control 2 
		//(006h)xxxx 0110
		//bit 7,4 -> Unused
		//bit 3 = 0 -> P2CA1 (Pin to CA1. This bit selects the CA1 pin function)
		//bit 2 = 1 -> P2CA0 (Pin to CA0. This bit selects the CA0 pin function)(1 The pin is connected to CA0)
		//bit 1 = 1 -> CAF (Comparator_A output filter)
		//bit 0 = 0 -> CAOUT (Comparator_A output. This bit reflects the value of the comparator output)
		
		bis.b 	#006h,&P2DIR ; (06h)0000 0110 - LED1=>P2.2 and LED2 => P2.1 as output		
SetLEDs		bic.b 	#004h,&P2OUT ; (04h)0000 0100 - LED1=>P2.2 OFF
	        bis.b 	#002h,&P2OUT ; (02h)0000 0010 - LED2 => P2.1 ON
		
Mainloop 	bis.w 	#LPM3+GIE,SR ; Enter LPM3, enable interrupts (SR - Status Register)(GIE - General Interrupt Enable)
		nop	

;------------------------------------------------------------------------------		
InterruptCompA //Label
;------------------------------------------------------------------------------	
		xor.b 	#006h,&P2OUT ; (06h)0000 0110 - Invert state of LED1=>P2.2 and LED2 => P2.1 
Wait		mov.w 	#50000,R15 ; Delay to R15
L1		dec 	R15 ; Decrement R15
		jnz 	L1 ; Delay over?	
		xor.b 	#006h,&P2OUT ; (06h)0000 0110 - Invert state of LED1=>P2.2 and LED2 => P2.1 
		reti
;------------------------------------------------------------------------------
		COMMON INTVEC ; Interrupt Vectors
;------------------------------------------------------------------------------
		ORG RESET_VECTOR ; MSP430 RESET Vector (ORG - Origin)
		DW RESET 	

		ORG COMPARATORA_VECTOR 
		DW InterruptCompA
		
		END