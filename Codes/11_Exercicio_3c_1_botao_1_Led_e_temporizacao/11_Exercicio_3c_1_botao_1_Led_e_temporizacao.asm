;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 01/09/2021(dd/mm/yyyy)
;Code: Exercicio_3c_1_botao_1_Led_e_temporizacao
;MCU: MSP430FG4618

;MSP430FG4618F/2013 Experimenter Board	(SIMULATOR)
;Switch S1 => P1.0 (IN)
;Switch S2 => P1.1 (IN)
;LED1 => P2.2 (OUT)	
;LED2 => P2.1 (OUT)	
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
		
		bic.b 	#002h,&P1SEL ; (01h)00000010 - Port P1 - pin 1 selection
		bic.b 	#002h,&P1DIR ; (01h)00000010 - Port P1 - pin 1 as input (Set->Output, Clear->Input)					
		bis.b 	#002h,&P1IE ; (01h)00000010 - Port P1 - pin 1 interrupt enable
		
		bis.b 	#004h,&P2DIR ; (02h)00000100 - LED1 => P2.2 as output (Set->Output, Clear->Input)		
ApagaLED1	bic.b 	#004h,&P1OUT ; (02h)00000100 - LED1 => is OFF

Mainloop 	bis.w 	#LPM3+GIE,SR ; Enter LPM3, enable interrupts (SR - Status Register)(GIE - General Interrupt Enable)
		nop ; Required for Debugger
;------------------------------------------------------------------------------
Basic_Timer_ISR ;// Basic Timer Interrupt Service Routine
;------------------------------------------------------------------------------
		bic.b 	#080h,&IFG2 ; IFG2 - interrupt flag down
		bic.b 	#004h,&P2OUT ; turn OFF LED1 => P2.2
		jmp Mainloop		
;------------------------------------------------------------------------------	
Porta1_int  ;Port1 Interrupt Service Routine
;------------------------------------------------------------------------------			
		bic.b 	#002h,&P1IFG ; Port P1 -  pin 1 - interrupt flag down		
		bis.b 	#004h,&P2OUT ; turn ON LED1 => P2.2

		//ACLK = 32768Hz // 32768Hz:256 = 128Hz (Q7 - BTCNT1)
		//Freq ACLK = 128Hz, Tempo desejado = 0.5s || f=1/t || 128/0.5 = 64
SetupBT		mov.b 	#025h,&BTCTL ; (25h)00100101 - BTCL->(BTSEL 7 | BTHOLD 6 | BTDIV 5 |BTFRQ 4 e 3 |BTIP 2,1 e 0)			
		bis.b 	#BTIE,&IE2 ; Enable BT interrupt
		bis.b 	#008h,SR // Ativa o GIE novamente

		bis.w 	#LPM3+GIE,SR ; Enter LPM3, enable interrupts (SR - Status Register)(GIE - General Interrupt Enable)
		reti //Retorno de interrupção
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