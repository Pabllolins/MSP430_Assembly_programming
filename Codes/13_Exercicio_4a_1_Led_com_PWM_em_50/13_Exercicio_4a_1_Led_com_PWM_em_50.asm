;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 07/09/2021(dd/mm/yyyy)
;Code: Exercício 4a: 1 Led com PWM em 50%

;MCU: MSP430FG4618F/2013 Experimenter Board(SIMULATOR)

;a) Botão S1 (IN) -> pino P1.0 -> TA0 -> CCR0
;b) Botão S2 (IN) -> pino P1.1 -> TA0 -> CCR0
;c) LED1 (OUT) -> pino P2.2 -> TB1 -> CCR1
;d) LED2 (OUT) -> pino P2.1 -> TB0 - CCR0 

//• Auxiliary clock (ACLK), sourced from a 32768-Hz watch crystal or a high-frequency crystal
//• Main clock (MCLK), the system clock used by the CPU
//• Submain clock (SMCLK), the subsystem clock used by the peripheral modules

;Active mode -> f(MCLK) = f(SMCLK) = 1,048 MHz // f(ACLK) = 32768 Hz
;Low-power mode (LPM3) -> f(MCLK) = f(SMCLK) = 0 MHz // f(ACLK) = 32768 Hz, SCG0 = 1,
;-------------------------------------------------------------------------------
#include <msp430xG46x.h>
;-------------------------------------------------------------------------------
		RSEG CSTACK ; Define stack segment (RSEG - Register Segment)
;-------------------------------------------------------------------------------
		RSEG CODE ; Assemble to Flash memory
;-----------------------------------------------------------------------------
RESET 		mov.w 	#SFE(CSTACK),SP ; Initialize stackpointer
StopWDT 	mov.w 	#WDTPW+WDTHOLD,&WDTCTL ; Stop WDT	
		
		bis.b 	#006h,&P2DIR ; (06h)0000 0110 - LED1=>P2.2 and LED2 => P2.1 as output
SetupLEDs	bic.b 	#004h,&P2OUT ; (LED1) (04h)0000 0100 - P2.2 TB1
		bis.b 	#020h,&P2SEL ; (LED2) (02h)0000 0010 - P2.1 TB0 	

Capt_Comp_Control_0	mov.w 	#00010h,TBCCTL0 //Capture/Compare Control Register 1 (00010h)0000 000 0001 0000 -> Capture/compare control 1
			//15-14 -> CM = 00 -> Capture mode. - FEATURE NOT USED
			//13-12 -> CCIS = 00  -> Capture/compare input select. - FEATURE NOT USED
			//11 -> SCS = 0  -> Synchronize capture source. - FEATURE NOT USED
			//10 -> SCCI = 0  -> Synchronized capture/compare input - FEATURE NOT USED
			//9 - Unused = 0
			//8 -> CAP = 0  -> Capture mode
			//7-5 -> OUTMOD1 = 000  -> Output mode 
			//4 -> CCIE = 1  -> Capture/compare interrupt Enable
			//3 -> CCI = 0  -> Capture/compare input. The compare mode is selected when CAP = 0. The compare mode is used to generate PWM output
			//2 -> OUT = 0 -> Output high 
			//1 -> COV = 0  -> Capture overflow.- FEATURE NOT USED
			//0 -> CCIFG = 0 -> Capture/compare interrupt flag
Capt_Comp_register0  	bis.w 	#0FFFFh, &TBCCR0 //Timer_B Capture/Compare Register 0 (65534)	
					
Capt_Comp_Control_1	mov.w 	#000E0h,TBCCTL1 //Capture/Compare Control Register 1 (000E0h)0000 0000 1101 0000 -> Capture/compare control 1
			//15-14 -> CM = 00 -> Capture mode. - FEATURE NOT USED
			//13-12 -> CCIS = 00  -> Capture/compare input select. - FEATURE NOT USED
			//11 -> SCS = 0  -> Synchronize capture source. - FEATURE NOT USED
			//10 -> SCCI = 0  -> Synchronized capture/compare input - FEATURE NOT USED
			//9 - Unused = 0
			//8 -> CAP = 0  -> Capture mode
			//7-5 -> OUTMOD1 = 110  -> Output mode:
			//4 -> CCIE = 1  -> Capture/compare interrupt Enable
			//3 -> CCI = 0  -> Capture/compare input. The compare mode is selected when CAP = 0. The compare mode is used to generate PWM output
			//2 -> OUT = 0 -> Output high 
			//1 -> COV = 0  -> Capture overflow.- FEATURE NOT USED
			//0 -> CCIFG = 0 -> Capture/compare interrupt flag
Capt_Comp_register1	bis.w 	#7FFFh, &TBCCR1 //Timer_B Capture/Compare Register 1 com 50% do ciclo de trabalho

Set_Timer_B_Ctrl	bis.w 	#002D2h, &TBCTL; (002D2h)0000 0010 1101 0010 -> Timer_A control
			//15-10 - Unused = = 0000000
			//9-8 - TASSELx = 10 -> 
			//7-6 - IDx = 11 -> (Div8) = (1,048576MHz) = 131072Hz
			//5-4 - MCx = 01 -> Up mode: the timer counts up to TACCR0.
			//3 - Unused = 0
			//2 - TACLR = 0 -> Timer_A clear(automatic resets)
			//1 - TAIE = 1 -> (Timer_A interrupt enable. This bit enables the TAIFG interrupt request.)
			//1 - TAIFG = 0	

Mainloop 	bis.w 	#LPM3+GIE,SR ; Enter LPM3, enable interrupts (SR - Status Register)(GIE - General Interrupt Enable)
		nop	

;------------------------------------------------------------------------------
TM_B0_Vector ;// Timer B CC0 - Interrupt routine
;------------------------------------------------------------------------------				
		bis.b 	#004h,&P2OUT ;(LED1) - P2.2 TB1 - Set
Wait		mov.w 	#50,R15 ; Delay to R15
L1		dec 	R15 ; Decrement R15
		jnz 	L1 ; (Delay)
		bic.b 	#004h,&P2OUT ;(LED1) - P2.2 TB1 - Clear 				
		reti	
		
;------------------------------------------------------------------------------
TM_B1_Vector ;// Timer B CC1-6, TB - Interrupt routine
;------------------------------------------------------------------------------				
		reti
		
;------------------------------------------------------------------------------
		COMMON INTVEC ; Interrupt Vectors
;------------------------------------------------------------------------------
		ORG RESET_VECTOR ; MSP430 RESET Vector (ORG - Origin)
		DW RESET ;
				
		ORG TIMERB1_VECTOR ; Int. Vector: Timer B CC1-6, TB
		DW TM_B1_Vector	
	
		ORG TIMERB0_VECTOR ; Int. Vector: Timer B CC0

		DW TM_B0_Vector			
		END