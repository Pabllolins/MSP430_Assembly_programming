;--------------------------------------------------------
;Programer: Pabllo Lins
;Date: 15/09/2021(dd/mm/yyyy)
;Code: 15_Exercicio_4b_Adaptado_LaunchPad
;PLACA: MSP-EXP430G2 LaunchPad - MCU: MSP430G2231

;Switch S1 (IN) => RST/SBWTDIO 	
;Switch S2 (IN) => P1.3  - (INCREMENTA PWM)
;Switch S4 (IN) => P1.4 - (DECREMENTA PWM)
;LED1 (OUT) => P1.0 Timer A
;LED2 (OUT) => P1.6  TA1 -> CCR1
;------------------------------------------------------------------------------	
;Active mode -> f(MCLK) = f(SMCLK) = 1,048576MHz // f(ACLK) = 32768 Hz
;Low-power mode (LPM3) -> f(MCLK) = f(SMCLK) = 0 MHz // f(ACLK) = 32768 Hz, SCG0 = 1,
;------------------------------------------------------------------------------
//Oscillator and System Clock = Main clock (MCLK) =  1,048576 MHz
//(SMCLK)/(ID) =  1,048576/1 = 1048576 Hz
//Duty cycle target = 1 ms = 0,001s = 1.(10^-3)s
//t=0,001s -> f=1/t -> f=1/0,001 -> f=1000Hz (1kHz)
//1048576Hz/x = 1000 Hz -> x = 1048576/1000 = 1048,576 (418h)
;-------------------------------------------------------------------------------
; TACCR0 (100%) = 1048 - Timer_A Capture/Compare Register0 = 418h
; TACCR0 (99%) = 1037 (99% do duty cycle) = 40Dh
; TACCR0 (1%) = 10 (1% do duty cycle) = Ah
;-------------------------------------------------------------------------------

#include <msp430G2231.h>
;-------------------------------------------------------------------------------
		RSEG CSTACK ; Define stack segment (RSEG - Register Segment)
;-------------------------------------------------------------------------------
		RSEG CODE ; Assemble to Flash memory
;-----------------------------------------------------------------------------
RESET 		mov.w 	#SFE(CSTACK),SP ; Initialize stackpointer
StopWDT 	mov.w 	#WDTPW+WDTHOLD,&WDTCTL ; Stop WDT	
		
SetupChaves	bic.b 	#018h,&P1SEL ; (18h)00011000 - Port P1 - pin 3 and pin 4 selection
		bic.b 	#018h,&P1DIR ; (18h)00011000 - Port P1 - pin 3 and pin 4 as input (clear putting 0 to be input)				
		bis.b 	#018h,&P1REN ; (18h)00011000 - Port P1 - pin 3 and pin 4 resistor enable
		bis.b 	#018h,&P1IE ; (18h)00011000 - Port P1 - pin 3 and pin 4 interrupt enable

SetupLEDs	bis.b 	#041h,&P1DIR ; (F7h)0100 0001 - Port P1.0(LED1) and P1.6(LED2) as output
		bic.b 	#001h,&P1OUT ; (01h)0000 0001 - P1.0(LED1) OFF
		bis.b 	#040h,&P1SEL ; P1.6(LED2 ) TA1/2 otions	

SetupCCR0	mov.w 	#00000h,TACCTL0 //Capture/Compare Control Register 1 (00010h)0000 000 0000 0000 -> Capture/compare control 1
			//15-14 -> CM = 00 -> Capture mode. - FEATURE NOT USED
			//13-12 -> CCIS = 00  -> Capture/compare input select. - FEATURE NOT USED
			//11 -> SCS = 0  -> Synchronize capture source. - FEATURE NOT USED
			//10 -> SCCI = 0  -> Synchronized capture/compare input - FEATURE NOT USED
			//9 - Unused = 0
			//8 -> CAP = 0  -> Capture mode
			//7-5 -> OUTMOD1 = 000  -> Output mode 
			//4 -> CCIE = 0  -> Capture/compare interrupt Enable
			//3 -> CCI = 0  -> Capture/compare input. The compare mode is selected when CAP = 0. The compare mode is used to generate PWM output
			//2 -> OUT = 0 -> Output high 
			//1 -> COV = 0  -> Capture overflow.- FEATURE NOT USED
			//0 -> CCIFG = 0 -> Capture/compare interrupt flag
		bis.w 	#00418h, &TACCR0 ;Timer_A Capture/Compare Register 0 (1048)		

SetupCCR1	mov.w 	#000C0h,TACCTL1 ;Capture/Compare Control Register 1 (000C0h)0000 0000 1100 0000 -> Capture/compare control 1
			//15-14 -> CM = 00 -> Capture mode. - FEATURE NOT USED
			//13-12 -> CCIS = 00  -> Capture/compare input select. - FEATURE NOT USED
			//11 -> SCS = 0  -> Synchronize capture source. - FEATURE NOT USED
			//10 -> SCCI = 0  -> Synchronized capture/compare input - FEATURE NOT USED
			//9 - Unused = 0
			//8 -> CAP = 0  -> Capture mode
			//7-5 -> OUTMOD1 = 110  -> Output mode:
			;//4 -> CCIE = 1  -> Capture/compare interrupt Enable
			//4 -> CCIE = 0  -> Capture/compare interrupt Enable
			//3 -> CCI = 0  -> Capture/compare input. The compare mode is selected when CAP = 0. The compare mode is used to generate PWM output
			//2 -> OUT = 0 -> Output high 
			//1 -> COV = 0  -> Capture overflow.- FEATURE NOT USED
			//0 -> CCIFG = 0 -> Capture/compare interrupt flag
		bis.w 	#0020Ch, &TACCR1 //Timer_A Capture/Compare Register 1 com 50% do ciclo de trabalho(20Ch)			
		;bis.w 	#00400h, &TACCR1 //Testes perto do maximo
		;bis.w 	#000018h, &TACCR1 //Testes perto do minimo
		
		mov.w   #00000h, R12 //Registrador que guarda o ultimo 

SetupTA		bis.w 	#002D0h, &TACTL; (002D0h)0000 0010 1101 0000 -> Timer_A control
			//15-10 - Unused = = 0000000
			//9-8 - TASSELx = 10 -> 
			//7-6 - IDx = 11 -> (Div8) = (1,048576MHz) = 131072Hz
			//5-4 - MCx = 01 -> Up mode: the timer counts up to TACCR0.
			//3 - Unused = 0
			//2 - TACLR = 0 -> Timer_A clear(automatic resets)
			//1 - TAIE = 0 -> (Timer_A interrupt enable. This bit enables the TAIFG interrupt request.)
			//0 - TAIFG = 0		
			
Mainloop 	bis.w 	#LPM0+GIE,SR ; Enter LPM3, enable interrupts (SR - Status Register)(GIE - General Interrupt Enable)
		nop	
;------------------------------------------------------------------------------	
Porta1_int //Label
;------------------------------------------------------------------------------	
		dint //desabilita todas interrupções
		bit.b 	#010h,&P1IFG //testa a flag de interrupçãp do P1.4(S4) 00010000b
		jnz 	Decrementa1pct //Se o flag de interrupção do botão S4 estiver "1", vai para sub-rotina Decrementa1pct

		bit.b 	#008h,&P1IFG // testa a flag de interrupçãp do P1.3(S2) 00001000b	
		jnz 	Incrementa1pct //Se o flag de interrupção do botão S3 estiver "1", vai para sub-rotina Incrementa1pct			
;------------------------------------------------------------------------------						
Decrementa1pct //Label	
testaS4		bit.b 	#010h,&P1IN ; //testa o P1.4(S4) 00010000b
		jz 	testaS4; //Enquanto o botão estiver pressionado, ficará nesse laço "Debouncing"
		bic.b 	#010h,&P1IFG //Limpa a flag de interrupção P1.4(S4)
		cmp.w 	#0000Ah,&TACCR1 //Compara TACCR1 com o mínimo (1% do duty cycle) -> Ah = 10 
		jl 	Restaura_min //Se TACCR1 for menor vai para sub-rotina Restaura_min
Decrement	sub.w 	#0000Ah, &TACCR1 //Subtrai 1% do TACCR0
		mov.w   TACCR1, R12 //Move para o R12 o ultimo valor aceito em TACCR1		
		bic.w 	#00001h,&TACTL //Limpa a flag de interrupção do timerA
		reti //Retorno de interrupção		
;-------------------------------------------------------------------------------
Incrementa1pct 	//Label
testaS3		bit.b 	#008h,&P1IN // testa o P1.3(S2) 00001000b
		jz 	testaS3 //Enquanto o botão estiver pressionado, ficará nesse laço "Debouncing"
		bic.b 	#008h,&P1IFG //Limpa a flag de interrupção P1.3(S2)
		cmp.w 	#0040Dh,&TACCR1  //Compara TACCR1 com o maximo (99% do duty cycle) -> 040Dh = 1037 
		jge 	Restaura_max //Se TACCR1 for maior ou igual vai para sub-rotina Restaura_max						
Incremt		add.w 	#0000Ah, &TACCR1 //Adiciona 1% do TACCR0
		mov.w   TACCR1, R12 //Move para o R12 o ultimo valor aceito
		bic.w 	#00001h,&TACTL //Limpa a flag de interrupção do timerA
		reti //Retorno de interrupção
;-------------------------------------------------------------------------------		
Restaura_min	bis.w   R12, &TACCR1 //Põe em TACCR1 o ultimo valor aceito em R12
		bic.b 	#010h,&P1IFG //Limpa a flag de interrupção P1.4(S4)
		reti //Retorno de interrupção		
Restaura_max	bis.w   R12, &TACCR1 //Põe em TACCR1 o ultimo valor aceito em R12
		bic.b 	#008h,&P1IFG //Limpa a flag de interrupção P1.3(S2)
		reti //Retorno de interrupção						
;------------------------------------------------------------------------------
		COMMON INTVEC ; Interrupt Vectors
;------------------------------------------------------------------------------
		ORG RESET_VECTOR ; MSP430 RESET Vector (ORG - Origin)
		DW RESET ;	
		
		ORG PORT1_VECTOR ; 
		DW Porta1_int
		
		END
		
		
	