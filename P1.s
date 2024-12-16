/*
 * File:   %<%NAME%>%.%<%EXTENSION%>%
 * Author: %<%USER%>%
 *
 * Created on %<%DATE%>%, %<%TIME%>%
 */

    .include "p33fj32mc202.inc"

    ; _____________________Configuration Bits_____________________________
    ;User program memory is not write-protected
    #pragma config __FGS, GWRP_OFF & GSS_OFF & GCP_OFF
    
    ;Internal Fast RC (FRC)
    ;Start-up device with user-selected oscillator source
    #pragma config __FOSCSEL, FNOSC_FRC & IESO_ON
    
    ;Both Clock Switching and Fail-Safe Clock Monitor are disabled
    ;XT mode is a medium-gain, medium-frequency mode that is used to work with crystal
    ;frequencies of 3.5-10 MHz
  ; #pragma config __FOSC, FCKSM_CSDCMD & POSCMD_XT
    
    ;Watchdog timer enabled/disabled by user software
    #pragma config __FWDT, FWDTEN_OFF
    
    ;POR Timer Value
    #pragma config __FPOR, FPWRT_PWR128
   
    ; Communicate on PGC1/EMUC1 and PGD1/EMUD1
    ; JTAG is Disabled
    #pragma config __FICD, ICS_PGD1 & JTAGEN_OFF

;..............................................................................
;Program Specific Constants (literals used in code)
;..............................................................................

    .equ SAMPLES, 64         ;Number of samples



;..............................................................................
;Global Declarations:
;..............................................................................

    .global _wreg_init       ;Provide global scope to _wreg_init routine
                                 ;In order to call this routine from a C file,
                                 ;place "wreg_init" in an "extern" declaration
                                 ;in the C file.

    .global __reset          ;The label for the first line of code.

;..............................................................................
;Constants stored in Program space
;..............................................................................

    .section .myconstbuffer, code
    .palign 2                ;Align next word stored in Program space to an
                                 ;address that is a multiple of 2
ps_coeff:
    .hword   0x0002, 0x0003, 0x0005, 0x000A




;..............................................................................
;Uninitialized variables in X-space in data memory
;..............................................................................

    .section .xbss, bss, xmemory
x_input: .space 2*SAMPLES        ;Allocating space (in bytes) to variable.



;..............................................................................
;Uninitialized variables in Y-space in data memory
;..............................................................................

    .section .ybss, bss, ymemory
y_input:  .space 2*SAMPLES




;..............................................................................
;Uninitialized variables in Near data memory (Lower 8Kb of RAM)
;..............................................................................

    .section .nbss, bss, near
var1:     .space 2               ;Example of allocating 1 word of space for
                                 ;variable "var1".




;..............................................................................
;Code Section in Program Memory
;..............................................................................

.text                             ;Start of Code section
__reset:
    MOV #__SP_init, W15       ;Initalize the Stack Pointer
    MOV #__SPLIM_init, W0     ;Initialize the Stack Pointer Limit Register
    MOV W0, SPLIM
    NOP                       ;Add NOP to follow SPLIM initialization

    CALL _wreg_init           ;Call _wreg_init subroutine
                                  ;Optionally use RCALL instead of CALL

				  
;SELECTOR
MOV #0x05, w0
;OPERACIONES			  
MOV #0X01, w5        ; Suma
MOV #0X02, w6        ; Resta
MOV #0X03, w7        ; Complemento A
MOV #0X04, w8        ; Complemento B
MOV #0X05, w9        ; División A/B
MOV #0X06, w10       ; División D/C
MOV #0X07, w11       ; Rotación sin acarreo B
MOV #0X08, w12       ; Desplazamiento a la derecha de D

;ABCD
MOV #101, w1        ; A
MOV #9, w2	    ; B
MOV #0X03, w3       ; C
MOV #0X06, w4       ; D

;carry
MOV #0X0, w13
MOV #0X0, w14

;Resultado
MOV #0X0, w15


CPSNE w0, w5        ; Compara w0 con w5 (suma)
	BRA SUMA
CPSNE w0, w6        ; Compara w0 con w6 (resta)
	BRA RESTA			  
CPSNE w0, w7        ; Compara w0 con w7 (complemento de A)
	BRA COMPA
CPSNE w0, w8        ; Compara w0 con w8 (complemento de B)
	BRA COMPB
CPSNE w0, w9        ; Compara w0 con w9 (división A/B)
	BRA DIVAB
CPSNE w0, w10       ; Compara w0 con w10 (división D/C)
	BRA DIVDC	  
CPSNE w0, w11       ; Compara w0 con w11 (rotación sin acarreo B)
	BRA ROTB
CPSNE w0, w12       ; Compara w0 con w12 (desplazamiento a la derecha de D)
	BRA SHIFTR

; Inicio de las rutinas de operación

SUMA:			  
    ADD	w1, w2, w13        ; Suma A + B
    ADD	w3, w4, w14        ; Suma C + D
    ADD	w13,w14, w15       ; Suma total: (A + B) + (C + D)
    RETURN

RESTA:
    SUB	w2,w3,w15          ; Resta B - C
    RETURN

COMPA:
    COM	w1, w14           ; Complemento de A
    RETURN
	
COMPB:
    COM	w2, w14        ; Complemento de B
    RETURN

DIVAB:
    repeat #17
    DIV.U w1, w2           ; División A / B
    RETURN

DIVDC:
    repeat #17
    DIV.U w4, w3           ; División D / C
    RETURN
	
ROTB:
    RLNC	w2, w15           ; Rotar B sin acarreo
    RETURN

SHIFTR:
	LSR	w4, w14           ; Desplazamiento a la derecha de D
    RETURN

;SETM    AD1PCFGL  ;PORTB AS DIGITAL
;CLR	TRISB
SETM	W10

	
done:	    ;INFINITE LOOP
    
    COM	    W10,    W10
    
    BRA     done              ;Place holder for last line of executed code



;..............................................................................
;Subroutine: Initialization of W registers to 0x0000
;..............................................................................

_wreg_init:
    CLR W0
    MOV W0, W14
    REPEAT #12
    MOV W0, [++W14]
    CLR W14
    RETURN




;--------End of All Code Sections ---------------------------------------------

.end                               ;End of program code in this file
