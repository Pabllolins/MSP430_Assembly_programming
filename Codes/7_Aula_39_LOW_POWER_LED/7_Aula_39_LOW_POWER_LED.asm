;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 20/08/2021(dd/mm/yyyy)
;Code: 39 - PISCANDO UM LED COM BAIXO CONSUMO
;MCU: MSP430FG4618

;MSP430FG4618F/2013 Experimenter Board	(SIMULATOR)	
;-------------------------------------------------------------------------------


#include <msp430xG46x.h>
;-------------------------------------------------------------------------------
		RSEG CSTACK ; Define stack segment (RSEG - Register Segment)
;-------------------------------------------------------------------------------
		RSEG CODE ; Assemble to Flash memory
;-----------------------------------------------------------------------------
RESET 		mov.w #SFE(CSTACK),SP ; Initialize stackpointer
StopWDT 	mov.w #WDTPW+WDTHOLD,&WDTCTL ; Stop WDT
SetupFLL 	bis.b #XCAP14PF,&FLL_CTL0 ; Configure load caps
		bis.b #BIT1,&P5DIR ; Set P5.1 as Output
SetupBT 	mov.b #BTDIV+BT_fCLK2_DIV16, & BTCTL ; ACLK/(256*16)
		bis.b #BTIE,&IE2 ; Enable BT interrupt
Mainloop 	bis.w #LPM3+GIE,SR ; Enter LPM3, enable interrupts (SR - Status Register)(GIE - General Interrupt Enable)
		nop ; Required for Debugger
;------------------------------------------------------------------------------
Basic_Timer_ISR ;// Basic Timer Interrupt Service Routine
;------------------------------------------------------------------------------
		xor.b #BIT1,&P5OUT ; Toggle P5.1 (LED)
		reti
;------------------------------------------------------------------------------
		COMMON INTVEC ; Interrupt Vectors
;------------------------------------------------------------------------------
		ORG RESET_VECTOR ; MSP430 RESET Vector (ORG - Origin)
		DW RESET ;
		ORG BASICTIMER_VECTOR ; MSP430 Basic Timer Interrupt Vector
		DW Basic_Timer_ISR
		END