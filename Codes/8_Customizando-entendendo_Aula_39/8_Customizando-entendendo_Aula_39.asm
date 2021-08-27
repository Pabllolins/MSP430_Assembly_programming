;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 26/08/2021(dd/mm/yyyy)
;Code: 8_Customizando-entendendo_Aula_39
;MCU: MSP430FG4618

;MSP430FG4618F/2013 Experimenter Board	(SIMULATOR)	
;-------------------------------------------------------------------------------
#include <msp430xG46x.h>

;------------------------------------------------------------------------------
		COMMON INTVEC ; Interrupt Vectors //(COMMON) Begins a common segment.
		ORG RESET_VECTOR ; (ORG - Origin) MSP430 RESET Vector 
		DW Simbora ; (Declara Word) da origem anterior (2ª Obrigação) Declara o vetor de reset
		ORG BASICTIMER_VECTOR ; MSP430 Basic Timer Interrupt Vector
		DW Rotina_Interrupcao_do_Basic_Time
;------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
		RSEG CSTACK ; (RSEG - Register Segment) Define stack segment 
;-------------------------------------------------------------------------------
		RSEG CODE ; (RSEG - Register Segment) Informa ao compilador que abaixo é código a ser gravado/Assemble to Flash memory
;-----------------------------------------------------------------------------
Simbora 	mov.w #SFE(CSTACK),SP ; (1ª Obrigação) Initialize stackpointer

StopWDT 	mov.w #WDTPW+WDTHOLD,&WDTCTL ; Stop WDT (3ª Obrigação) Manipular o Watch dog time

SetupFLL 	bis.b #XCAP14PF,&FLL_CTL0 ; Configure load caps

		bis.b #BIT1,&P5DIR ; Set P5.1 as Output
SetupBT 	mov.b #BTDIV+BT_fCLK2_DIV16, & BTCTL ; ACLK/(256*16)

		bis.b #BTIE,&IE2 ; (BTIE - Basic Time Interrupt Enable) (IE2 - Interrupt enable 2) //Habilita a interrupução do periferico

Mainloop 	bis.w #LPM3+GIE,SR ; Enter LPM3, enable interrupts - (LPM3 - Low Power Mode 3)(GIE - General Interrupt Enable)(SR - Status Register)
		nop ; Required for Debugger
;------------------------------------------------------------------------------
Rotina_Interrupcao_do_Basic_Time ;// Basic Timer Interrupt Service Routine
;------------------------------------------------------------------------------
		xor.b #BIT1,&P5OUT ; Toggle P5.1 (LED)
		reti //Retorno de interrupção
		
		
		
		END