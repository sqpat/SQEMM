; Copyright (C) 2024-2026 Patrick Goncalves (sqpat17)

; BUILD FLAGS - 
; select COMPILE_VERSION (min, small, max)
; select COMPILE_CHIPSET (one of the many below values)

; this top level file will incldue the files that make up that version of the chipset for compilation

SCAMP_CHIPSET = 1
SCAT_CHIPSET = 2
HT18_CHIPSET = 3
HT12_CHIPSET = 4
HEDAKA_CHIPSET = 5
LOTECH_BOARD = 6
NEAT_CHIPSET = 7
INTEL_ABOVEBOARD = 8
SARC_RC2016A = 9
STANDARD_EMS_BOARD = 10
FANTASY_EMS = 11
RODNEY_EMS = 12

DRIVER_VERSION_MIN   = 1  ; around 600-700 bytes, main functions implemented, single handle
DRIVER_VERSION_SMALL = 2  ; around 2-3 kb, full 3,2 implementation
DRIVER_VERSION_MAX  = 3   ; several KB full 4.0 implementation.


COMPILE_386  = 3
COMPILE_286  = 2
COMPILE_186  = 1
COMPILE_8086 = 0



COMPILE_VERSION = DRIVER_VERSION_MAX
COMPILE_CHIPSET = SCAT_CHIPSET

RET_OPCODE = 0C3h

MAX_HANDLE_COUNT = 128  ; TODO whats the right number?

HANDLE_INFO STRUC 
    handle_num_pages   dw ?  ; 0
    handle_first_page  dw ?  ; 0
HANDLE_INFO ENDS  ; 04h

PAGE_INFO STRUC 
; i think we dont need an owner?
    ; page_info_page_owner   dw ?  ; 0
    page_info_next_page    dw ?  ; 0
PAGE_INFO ENDS  ; 04h



IF COMPILE_CHIPSET EQ LOTECH_BOARD
	.8086
   COMPISA = COMPILE_8086
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
	.8086
   COMPISA = COMPILE_8086
ELSE
	.286
  COMPISA = COMPILE_186
ENDIF


PUSHA_MACRO MACRO

  IF COMPISA GE COMPILE_186
    pusha
  ELSE
    push  ax	
    push  cx
    push  dx
    push  bx
    push  si
    push  di
  ENDIF
ENDM


POPA_MACRO MACRO

  IF COMPISA GE COMPILE_186
    popa
  ELSE
    pop   di
    pop   si
    pop   bx
    pop   dx
    pop   cx
    pop   ax	
  ENDIF
ENDM


; optimized for speed
SHIFT_MACRO MACRO instruction, register, count


IF COMPISA GE COMPILE_386
	&instruction &register, &count

ELSEIF COMPISA GE COMPILE_186
	IF COUNT GE 4
		&instruction &register, &count
	ELSE
		REPT &count
			&instruction &register, 1
		ENDM
	ENDIF
ELSE
	REPT &count
		&instruction &register, 1
	ENDM
ENDIF

ENDM

MOVSW_MACRO MACRO
   shr        cx, 1
   rep        movsw
   jnc        $+1
   movsb
ENDM

.MODEL  tiny


DOS_DRIVER_REQUEST_HEADER STRUC 

    ; cmd struct 8 bytes
    drrh_length_of_record  db ?      ; 0    
    drrh_unit_code         db ?      ; 1
    drrh_command_code      db ?      ; 2
    drrh_status            dw ?      ; 3
    drrh_reserved          dd ?      ; 5
    drrh_link              dd ?      ; 9
DOS_DRIVER_REQUEST_HEADER ENDS       ; 0Dh



PAGE_COUNT_4_MB = 256
OFFSET_1_MB = 64
OFFSET_2_MB = 128


FUNC_24_SOURCE_PAGE_FRAME_INDEX = 2
FUNC_24_DEST_PAGE_FRAME_INDEX = 3


IF COMPILE_VERSION EQ DRIVER_VERSION_MIN
   INCLUDE sqemmmin.asm
ELSEIF COMPILE_VERSION EQ DRIVER_VERSION_SMALL
   INCLUDE sqemmsml.asm
ELSEIF COMPILE_VERSION EQ DRIVER_VERSION_MAX
   INCLUDE sqemmmax.asm
ENDIF   






END