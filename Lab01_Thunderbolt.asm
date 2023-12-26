  ORG 00H
  JMP MAIN
  ORG 0BH
  JMP TIMER0INT 
  ORG 23H
  JMP RECEIVE
  ORG 50H

  SQUARE_WAVE EQU P1.0  ; Sound wave

  SOUND_ON EQU R1   
  L_DELAY  EQU R2       ; How long is the delay for current note frequency
  NOTE     EQU R3
  SECOND   EQU R4       ; Stores 250, 250*4ms

MAIN:
  MOV   DPTR,#FREQUENCIES

  SETB  ES              ; Serial Port Interrupt
  CLR   TI
  CLR   RI
  SETB  EA
  SETB  PS              ; Priority

  MOV   TMOD,#00100000B ; Timer 1, Mode 2
  MOV   TL1,#0E6H       ; Baud rate=2400
  MOV   TH1,#0E6H
  ORL   PCON,#80H       ; SMOD=1, functions as UART Baud rate generator
  SETB  TR1             ; Timer Run

  ; 4 ms timer
  MOV 	TL0,#0	
  MOV 	TH0,#131
  SETB	TR0
   ; Interrupt enable register
  SETB  ET0   ; Timer Interrupt
  CLR   TF0

  CLR   SQUARE_WAVE

  CLR   SM0          
  SETB  SM1             ; Serial Port Mode 1
  CLR   SM2
  SETB  REN             ; Receive Enable
  
  ;DO: 191, RE: 170, MI: 152,
  ;FA: 143, SO: 128, LA: 114, SI: 101
LOOP:
  CJNE  SOUND_ON,#1,LOOP      ; No sound
  DJNZ  L_DELAY,CALL_DELAY
  MOV   A,NOTE
  MOVC  A,@A+DPTR
  MOV   L_DELAY,A
  CPL   SQUARE_WAVE
CALL_DELAY:
  CALL  DELAY10US
  JMP   LOOP
RECEIVE:
  JNB   RI,RX_END
  MOV   A,SBUF
  ; Note index: -49
  SUBB  A,#48
  MOV   NOTE,A
  MOV   SOUND_ON,#1
  MOV   SECOND,#250
  CLR   RI
RX_END:
  RETI
TIMER0INT:
  CJNE  SECOND,#0,DECREASE
  ; Ran out of time, Sound Off
  MOV   SOUND_ON,#0
  JMP   TIMER_END
DECREASE:
  DEC   SECOND
TIMER_END:
  CLR   TF0
  MOV 	TL0,#0	
  MOV 	TH0,#131
  RETI
DELAY10US:			;@11.0592MHz
	PUSH 30H
	MOV 30H,#19
NEXT:
	DJNZ 30H,NEXT
	POP 30H
	RET
;DO: 191, RE: 170, MI: 152,
;FA: 143, SO: 128, LA: 114, SI: 101
FREQUENCIES:
  ; DO, RE, MI...
  DB 191,170,152,143,128,114,101
END

//  ORG 00H
//  JMP MAIN
//  ORG 23H
//  JMP RECEIVE
//  ORG 50H
//
//  CHAR  EQU R0
//  READY EQU R1
//
//MAIN:
//  MOV   CHAR,#0
//  MOV   READY,#0
//
//  SETB  ES              ; Serial Port Interrupt
//  CLR   TI
//  CLR   RI
//  SETB  EA
//  SETB  PS              ; Priority
//
//  MOV   TMOD,#00100000B ; Timer 1, Mode 2
//  MOV   TL1,#0E6H       ; Baud rate=2400
//  MOV   TH1,#0E6H
//  ORL   PCON,#80H       ; SMOD=1
//  SETB  TR1             ; Timer Run
//
//  CLR   SM0
//  SETB  SM1             ; Serial Port Mode 1
//  CLR   SM2
//  SETB  REN             ; Receive Enable
//LOOP:
//  CJNE  READY,#1,LOOP
//  CLR   TI
//  MOV   SBUF,CHAR
//  MOV   READY,#0
//  JNB   TI,$
//  JMP   LOOP
//RECEIVE:
//  JNB   RI,RX_END
//  CLR   RI
//  MOV   A,SBUF
//  ADD   A,#32
//  MOV   CHAR,A
//  MOV   READY,#1
//RX_END:
//  RETI
//END

//DELAY1000MS:			;@11.0592MHz
//	NOP
//	NOP
//	NOP
//	PUSH 30H
//	PUSH 31H
//	PUSH 32H
//	MOV 30H,#34
//	MOV 31H,#159
//	MOV 32H,#56
//NEXT:
//	DJNZ 32H,NEXT
//	DJNZ 31H,NEXT
//	DJNZ 30H,NEXT
//	POP 32H
//	POP 31H
//	POP 30H
//	RET

//	ORG 	00H
//	JMP 	MAIN
//	ORG 	50H
//MAIN:
//	MOV 	TMOD,#0 		; Mode 0, Timer
//	MOV 	TL0,#0	
//	MOV 	TH0,#131
//	SETB	TR0
//	MOV 	A,#11000000B
//START:
//	MOV 	P0,A
//	MOV 	R4,#250
//DELAY1S:
//	ACALL DELAY
//	DJNZ	R4,DELAY1S
//	RR    A
//	SJMP  START
//;4 ms
//DELAY:
//	JNB  TF0,$ 	; Timer 1 overflow flag
//	CLR  TF0
//	MOV  TL0,#0
//	MOV  TH0,#131
//	RET 
//END