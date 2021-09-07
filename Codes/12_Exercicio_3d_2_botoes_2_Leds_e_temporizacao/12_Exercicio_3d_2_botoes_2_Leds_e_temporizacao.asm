;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 07/09/2021(dd/mm/yyyy)
;Code: Exercicio_3d_2_botoes_2_Leds_e_temporizacao
;MCU: MSP430FG4618F/2013 Experimenter Board	(SIMULATOR)

;Switch S1 => P1.0 (IN)
;Switch S2 => P1.1 (IN)
;LED1 => P2.2 (OUT)	
;LED2 => P2.1 (OUT)	

;S2 -> LED1
;S1 -> LED2
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
		
		bic.b 	#003h,&P1SEL ; (18h)00011000 - Port P1 - pin 1 S2 and pin 0 S1 selection
		bic.b 	#003h,&P1DIR ; (03h)00000011 - Port P1 - pin 1 S2 and pin 0 S1 as input (1->Output, 0->Input)			
		bis.b 	#003h,&P1IE  ; (03h)00000011 - Port P1 - pin 1 S2 and pin 0 S1 interrupt enable

		bis.b 	#006h,&P2DIR ; (06h)00000110 - LED1=>P2.2 and LED2 => P2.1 as output		
AcendeLED1	bis.b 	#006h,&P2OUT ; (06h)00000110 - LED1=>P2.2 and LED2 => P2.1 are ON

Mainloop 	bis.w 	#LPM3+GIE,SR ; Enter LPM3, enable interrupts (SR - Status Register)(GIE - General Interrupt Enable)
		nop
	
;------------------------------------------------------------------------------	
Porta1_int  ;Port1 Interrupt Service Routine
;------------------------------------------------------------------------------						
		bit.b 	#001h,&P1IN ; test if interrupt flag P1 - pin 0 (S1) is rised		
		jz ApagaLED2

		bit.b 	#002h,&P1IN ; test if interrupt flag P2 - pin 1 (S2) is rised
		jz ApagaLED1
		
		jmp AcendeLED1		
;------------------------------------------------------------------------------
Basic_Timer_ISR ;// Basic Timer Interrupt Service Routine
;------------------------------------------------------------------------------					
		bic.b 	#080h,&IFG2 ; IFG2 - interrupt flag down
		bis.b 	#006h,&P2OUT ; turn ON LED1 and LED2  => P2.1, P2.2
		jmp Mainloop			
;------------------------------------------------------------------------------		
				
ApagaLED2	bic.b 	#002h,&P2OUT ; turn OFF LED2 => P2.1
		//ACLK = 32768Hz // 32768Hz:256 = 128Hz (Q7 - BTCNT1)
		//Freq ACLK = 128Hz, Tempo desejado = 0.5s || f=1/t || 128/0.5 = 64
		mov.b 	#025h,&BTCTL ; (25h)00100101 - BTCL->(BTSEL 7 | BTHOLD 6 | BTDIV 5 |BTFRQ 4 e 3 |BTIP 2,1 e 0)			
		bis.b 	#BTIE,&IE2 ; Enable BT interrupt
		bis.w 	#LPM3+GIE,SR ; Enter LPM3, enable interrupts (SR - Status Register)(GIE - General Interrupt Enable)				
		nop
		
ApagaLED1	bic.b 	#004h,&P2OUT ; turn OFF LED1 => P2.2
		//ACLK = 32768Hz // 32768Hz:256 = 128Hz (Q7 - BTCNT1)
		//Freq ACLK = 128Hz, Tempo desejado = 0.5s || f=1/t || 128/0.5 = 64
		mov.b 	#025h,&BTCTL ; (25h)00100101 - BTCL->(BTSEL 7 | BTHOLD 6 | BTDIV 5 |BTFRQ 4 e 3 |BTIP 2,1 e 0)			
		bis.b 	#BTIE,&IE2 ; Enable BT interrupt
		bis.w 	#LPM3+GIE,SR ; Enter LPM3, enable interrupts (SR - Status Register)(GIE - General Interrupt Enable)		ret
		nop		
				
;------------------------------------------------------------------------------
		COMMON INTVEC ; Interrupt Vectors
;------------------------------------------------------------------------------
		ORG RESET_VECTOR ; MSP430 RESET Vector (ORG - Origin)
		DW RESET ;		
		
		ORG BASICTIMER_VECTOR ; MSP430 Basic Timer Interrupt Vector
		DW Basic_Timer_ISR			
		
		ORG PORT1_VECTOR ; 
		DW Porta1_int	
		
		END