;-------------------------------------------------------------------------------
;Programer: Pabllo Lins
;Date: 18/09/2021(dd/mm/yyyy)
;Code: 18_Exercicio_5b
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
;CA1 (P1.7) - Comparator_A input
;Se VCA1 > 0,25*vcc = Buzzer-P3.5(OFF) e LED4-P5.1(ON)
;Se VCA1 < 0,25*vcc = Buzzer-P3.5(ON) e LED4-P5.1(OFF)
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

SetupCA1	bic.b 	#080h,&P1DIR ; (80h)1000 0000 - CA1 => P1.7 (IN) as input
		bis.b  	#05Eh,&CACTL1 ; Comparator A Control 1
		//(5Eh)0101 1110
		//bit 7 = 0 -> CAEX (Comparator_A exchange)
		//bit 6 = 1 -> CARSEL (Comparator_A reference select)
		//bit 5,4 = 01 -> CAREF (Comparator_A reference)
		//bit 3 = 1 -> CAON (Comparator_A on)
		//bit 2 = 1 -> CAIES (Comparator_A interrupt edge select)(0 Rising edge) (1 Falling edge)
		//bit 1 = 1 -> CAIE (Comparator_A interrupt enable)
		//bit 0 = 0 -> CAIFG (Comparator_A interrupt flag)
		
		bis.b  	#006h,&CACTL2 ; Comparator A Control 2 
		//(006h)xxxx 1010
		//bit 7,4 -> Unused
		//bit 3 = 1 -> P2CA1 (Pin to CA1. This bit selects the CA1 pin function)
		//bit 2 = 0 -> P2CA0 (Pin to CA0. This bit selects the CA0 pin function)(1 The pin is connected to CA0)
		//bit 1 = 1 -> CAF (Comparator_A output filter)
		//bit 0 = 0 -> CAOUT (Comparator_A output. This bit reflects the value of the comparator output)
		
SetBuzzer	bis.b 	#020h,&P3DIR ; (20h)0010 0000 - Buzzer-P3.5 output
		bic.b 	#020h,&P3OUT ; (20h)0010 0000 - Buzzer-P3.5 OFF
		
		bis.b 	#002h,&P5DIR ; (02h)0000 0010 - LED4-P5.1 as output		
SetLED4		bis.b 	#002h,&P5OUT ; (02h)0000 0010 - LED4-P5.1 ON

Mainloop 	bis.w 	#LPM3+GIE,SR ; Enter LPM3, enable interrupts (SR - Status Register)(GIE - General Interrupt Enable)
		nop	

;------------------------------------------------------------------------------		
InterruptCompA //Label
;------------------------------------------------------------------------------	
		xor.b 	#020h,&P3OUT ; (20h)0010 0000 - Invert state of Buzzer-P3.5 OFF
		xor.b 	#002h,&P5OUT ; (02h)0000 0010 - Invert state of LED4-P5.1 ON

Wait		mov.w 	#50000,R15 ; Delay to R15
L1		dec 	R15 ; Decrement R15
		jnz 	L1 ; Delay over?
	
		xor.b 	#020h,&P3OUT ; (20h)0010 0000 - Invert state of Buzzer-P3.5 OFF
		xor.b 	#002h,&P5OUT ; (02h)0000 0010 - Invert state of LED4-P5.1 ON

		reti
;------------------------------------------------------------------------------
		COMMON INTVEC ; Interrupt Vectors
;------------------------------------------------------------------------------
		ORG RESET_VECTOR ; MSP430 RESET Vector (ORG - Origin)
		DW RESET 	

		ORG COMPARATORA_VECTOR 
		DW InterruptCompA
		
		END