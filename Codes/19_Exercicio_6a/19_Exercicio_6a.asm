;-------------------------------------------------------------------------------
;Programer: Pabllo Lins
;Date: 20/09/2021(dd/mm/yyyy)
;Code: 19_Exercicio_6a
;-------------------------------------------------------------------------------
;PLACA: Experimenter Board   
;MCU: MSP430FG4618F/2013 (SIMULATOR)(código não testado)

;Switch S1 => P1.0 (IN)
;Switch S2 => P1.1 (IN)
;LED1 => P2.2 (OUT)	
;LED2 => P2.1 (OUT)	
;LED4 => P5.1 (OUT)
;Buzzer => P3.5 (OUT)

;CA0 => P1.6 (IN)
;CA1 => P1.7 (IN)

;OA0I0 => P6.0 (IN) conector H8 - pino 1 - OA0 input multiplexer on + terminal and – terminal
;OA0I1 => P6.2 (IN) (OA0 input multiplexer on + terminal and – terminal)
;OA0O => P6.1 (OUT) OA0 output - conector H8 - pino 2
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;Active mode -> f(MCLK) = f(SMCLK) = 1,048576MHz // f(ACLK) = 32768 Hz
;Low-power mode (LPM3) -> f(MCLK) = f(SMCLK) = 0 MHz // f(ACLK) = 32768 Hz, SCG0 = 1,
;------------------------------------------------------------------------------
;Condição de funcionamento
;Caso o valor na entrada positiva do OA0I0 => P6.0 (IN) seja maior que a referência (VA00 + input, > 0,25*VCC),
;a saída do módulo OA0O => P6.1 (OUT) deve ficar em nível lógico 1, o que fará o LED4 -> pino P5.1 ficar aceso.
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

SetupAO0p60	bic.b 	#001h,&P6DIR ; (01h)0000 0001 - AO0 => P6.0 como entrada

SetupAO0p61	bis.b 	#002h,&P6DIR ; (02h)0000 0010 - AO0 => P6.1 como saida

		bis.b 	#002h,&P5DIR ; (02h)0000 0010 - LED4-P5.1 as output		
SetLED4		bic.b 	#002h,&P5OUT ; (02h)0000 0010 - LED4-P5.1 OFF

		;OA0CTL0 //Control Register
		;OA0CTL1
//OA Configurations
//The OA can be configured for different amplifier functions with the OAFCx bits.
OAFC0

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