;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 09/09/2021(dd/mm/yyyy)
;Code: 14_Exercicio_4a_Adaptado_LaunchPad
;MCU: MSP430G2231 - MSP-EXP430G2 LaunchPad - Board Default set	
;Switch S1 (IN) => RST/SBWTDIO 	
;Switch S2 (IN) => P1.3 
;LED1 (OUT) => P1.0 Timer
;LED2 (OUT) => P1.6  TA1 -> CCR1
;------------------------------------------------------------------------------	

//• Auxiliary clock (ACLK), sourced from a 32768-Hz watch crystal or a high-frequency crystal
//• Main clock (MCLK), the system clock used by the CPU
//• Submain clock (SMCLK), the subsystem clock used by the peripheral modules

;Active mode -> f(MCLK) = f(SMCLK) = 1,048576MHz // f(ACLK) = 32768 Hz
;Low-power mode (LPM3) -> f(MCLK) = f(SMCLK) = 0 MHz // f(ACLK) = 32768 Hz, SCG0 = 1,
    
//(ACLK) = 32768 Hz -> 32768 Hz /8(ID) = 4096Hz
//TAR (Timer_A register) 16 bits = 2^16 = 65536 (Register event)
//TAR (Timer_A register) 4096Hz/65536  -> 0.0625Hz 
//TAR time to interrupt interval -> (f=1/t) -> 0.0625Hz=1/t -> t=1/0.0625Hz -> t=16s 

//(SMCLK) =  1,048576 MHz  -> 1,048576/8(ID) = 131072 Hz
//TAR (Timer_A register) 16 bits = 2^16 = 65536 (Register event)
//TAR (Timer_A register) 131072Hz/65536  -> 2Hz 
//TAR time to interrupt interval -> (f=1/t) -> 2Hz=1/t -> t=1/2Hz -> t=0.5s 

//Quando queremos gerar PWM, temos que deixar amarrado o CCR0 o indice para o limite.
//Logo, é necessário utilizar o MC em Up mode: "the timer counts up to TACCR0"
;-------------------------------------------------------------------------------	

;-------------------------------------------------------------------------------
#include <msp430G2231.h>
;-------------------------------------------------------------------------------
		RSEG CSTACK ; Define stack segment (RSEG - Register Segment)
;-------------------------------------------------------------------------------
		RSEG CODE ; Assemble to Flash memory
;-----------------------------------------------------------------------------
RESET 		mov.w 	#SFE(CSTACK),SP ; Initialize stackpointer
StopWDT 	mov.w 	#WDTPW+WDTHOLD,&WDTCTL ; Stop WDT	
		
		bis.b 	#041h,&P1DIR ; (F7h)0100 0001 - Port P1.0 and P1.6 as output
SetupLEDs	bic.b 	#001h,&P1OUT ; (01h)0000 0001 - P1.0(LED1) OFF
		bis.b 	#040h,&P1SEL ; P1.6(LED2 ) TA1/2 otions	

SetupCCR0	mov.w 	#00010h,TACCTL0 //Capture/Compare Control Register 1 (00010h)0000 000 0001 0000 -> Capture/compare control 1
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
		bis.w 	#0FFFFh, &TACCR0 //Timer_A Capture/Compare Register 0 (65534)		

SetupCCR1	mov.w 	#000E0h,TACCTL1 //Capture/Compare Control Register 1 (000E0h)0000 0000 1101 0000 -> Capture/compare control 1
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
		bis.w 	#7FFFh, &TACCR1 //Timer_A Capture/Compare Register 1 com 50% do ciclo de trabalho			

SetupTA		bis.w 	#002D2h, &TACTL; (002D2h)0000 0010 1101 0010 -> Timer_A control
			//15-10 - Unused = = 0000000
			//9-8 - TASSELx = 10 -> 
			//7-6 - IDx = 11 -> (Div8) = (1,048576MHz) = 131072Hz
			//5-4 - MCx = 01 -> Up mode: the timer counts up to TACCR0.
			//3 - Unused = 0
			//2 - TACLR = 0 -> Timer_A clear(automatic resets)
			//1 - TAIE = 1 -> (Timer_A interrupt enable. This bit enables the TAIFG interrupt request.)
			//1 - TAIFG = 0			
			
Mainloop 	bis.w 	#LPM0+GIE,SR ; Enter LPM3, enable interrupts (SR - Status Register)(GIE - General Interrupt Enable)
		nop	
;------------------------------------------------------------------------------
TM_A0_Vector ;// Timer A CC0 - Interrupt routine
;------------------------------------------------------------------------------				
		bis.b 	#001h,&P1OUT ; Toggle P1.0
Wait		mov.w 	#50,R15 ; Delay to R15
L1		dec 	R15 ; Decrement R15
		jnz 	L1 ; Delay over?bis.b 	#001h,&P1OUT ; Toggle P1.0 and	
		bic.b 	#001h,&P1OUT ; Toggle P1.0 and						
		reti	
		
;------------------------------------------------------------------------------
TM_A1_Vector ;// Timer A CC1, TA - Interrupt routine
;------------------------------------------------------------------------------
		//xor.b 	#040h,&P1OUT ; Toggle P1.6 and
		;bis.b 	#040h,&P1OUT ; Toggle P1.6 and		
		//bic.b 	#040h,&P1OUT ; Toggle P1.6 and					
		reti
		
;------------------------------------------------------------------------------
		COMMON INTVEC ; Interrupt Vectors
;------------------------------------------------------------------------------
		ORG RESET_VECTOR ; MSP430 RESET Vector (ORG - Origin)
		DW RESET ;
				
		ORG TIMERA1_VECTOR ;Timer A CC1, TA (0xFFF0) 
		DW TM_A1_Vector	
	
		ORG TIMERA0_VECTOR ;Timer A CC0 (0xFFF2u) 
		DW TM_A0_Vector			
		END
		
		
	