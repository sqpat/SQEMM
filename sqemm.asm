; BUILD FLAGS - uncomment one


SCAMP_CHIPSET = 1
SCAT_CHIPSET = 2
HT18_CHIPSET = 3
HT12_CHIPSET = 4
HEDAKA_CHIPSET = 5
LOTECH_BOARD = 6
NEAT_CHIPSET = 7
INTEL_ABOVEBOARD = 8
SARC_RC2016A = 9

;COMPILE_CHIPSET = SCAMP_CHIPSET
;COMPILE_CHIPSET = SCAT_CHIPSET
;COMPILE_CHIPSET = HT18_CHIPSET
;COMPILE_CHIPSET = HT12_CHIPSET
;COMPILE_CHIPSET = HEDAKA_CHIPSET
;COMPILE_CHIPSET = LOTECH_BOARD
;COMPILE_CHIPSET =  NEAT_CHIPSET
;COMPILE_CHIPSET =  INTEL_ABOVEBOARD
COMPILE_CHIPSET =  SARC_RC2016A


IF COMPILE_CHIPSET EQ LOTECH_BOARD
ELIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
	.8086
ELSE
	.286
ENDIF

	.MODEL  tiny
	
.DATA



CONST_HANDLE_TABLE_LENGTH = 0FFh
CONST_PAGE_COUNT = 256
; 80h represents 2 MB offset beyond EMS start point
SCAMP_PAGE_OFFSET_AMT = 68h
SCAMP_PAGE_SELECT_REGISTER = 0E8h
SCAMP_PAGE_SET_REGISTER = 0EAh
SCAMP_PAGE_FRAME_COUNT = 36

; 18h for D000. 1Ch for E000 if we were to use that.
SCAT_PAGE_REGISTER_OFFSET = 018h
SCAT_CHIPSET_CONFIG_REGISTER_SELECT = 022h
SCAT_CHIPSET_CONFIG_REGISTER_READWRITE = 023h
SCAT_EMS_CONFIG_REGISTER = 04Fh
SCAT_PAGE_SELECT_REGISTER = 020Ah
SCAT_PAGE_SET_REGISTER = 0208h
SCAT_PAGE_FRAME_COUNT = 32

; 8000 is to mark bit 15 for free "ems enabled"
; 0080 is [currently hardcoded] 2 MB offset for beginning of EMS pagination,
SCAT_PAGE_OFFSET_AMT = 08080h
SCAT_CHIPSET_UNMAP_VALUE = 03FFh

; 1Ch for D000. 18h for C000 if we were to use that.
HT18_PAGE_REGISTER_OFFSET = 01Ch
HT18_EMS_CONFIG_REGISTER = 00h
HT18_CHIPSET_CONFIG_REGISTER_SELECT = 1EDh
HT18_CHIPSET_CONFIG_REGISTER_READWRITE = 1EFh
; todo correct?
HT18_PAGE_OFFSET_AMT = 0280h
HT18_PAGE_SELECT_REGISTER = 01EEh
HT18_PAGE_SET_REGISTER = 01ECh
HT18_PAGE_FRAME_COUNT = 32
HT18_CHIPSET_UNMAP_VALUE = 0000h


HEDAKA_PAGE_REGISTER_0 = 00208h
HEDAKA_PAGE_REGISTER_1 = 04208h
HEDAKA_PAGE_REGISTER_2 = 08208h
HEDAKA_PAGE_REGISTER_3 = 0C208h
; A8 puts us right after 9c00... 
; chipset doesnt seem to allow for more than 2MB EMS addressable INCLUDING conventional memory (?)
HEDAKA_PAGE_OFFSET_AMT = 0B8h
HEDAKA_PAGE_FRAME_COUNT = 4
; no real unmap support?
HEDAKA_CHIPSET_UNMAP_VALUE = 7Fh
HEDAKA_CONST_PAGE_COUNT = 72



HT12_PAGE_REGISTER_0 = 020h
HT12_PAGE_REGISTER_1 = 021h
HT12_PAGE_REGISTER_2 = 022h
HT12_PAGE_REGISTER_3 = 023h
HT12_EMS_CONFIG_REGISTER = 019h
HT12_CHIPSET_CONFIG_REGISTER_SELECT = 1EDh
HT12_CHIPSET_CONFIG_REGISTER_READWRITE = 1EFh
HT12_PAGE_OFFSET_AMT = 48h
HT12_PAGE_SELECT_REGISTER = 01EDh
HT12_PAGE_SET_REGISTER = 01EFh
HT12_PAGE_FRAME_COUNT = 4

LOTECH_PAGE_REGISTER_0 = 0260h
LOTECH_PAGE_REGISTER_1 = 0261h
LOTECH_PAGE_REGISTER_2 = 0262h
LOTECH_PAGE_REGISTER_3 = 0263h
LOTECH_CHIPSET_UNMAP_VALUE = 0FFh
LOTECH_PAGE_FRAME_COUNT = 4
LOTECH_CONST_PAGE_COUNT = 128

NEAT_CHIPSET_CONFIG_REGISTER_SELECT = 022h
NEAT_CHIPSET_CONFIG_REGISTER_READWRITE = 023h
NEAT_PAGE_REGISTER_0 = 00208h
NEAT_PAGE_REGISTER_1 = 04208h
NEAT_PAGE_REGISTER_2 = 08208h
NEAT_PAGE_REGISTER_3 = 0C208h
NEAT_PAGE_OFFSET_AMT = 080h
NEAT_PAGE_FRAME_COUNT = 4
; no real unmap support?
NEAT_CHIPSET_UNMAP_VALUE = 7Fh
NEAT_CONST_PAGE_COUNT = 128


; this is for 250 settings..
INTEL_AB_PAGE_REGISTER_0 = 00257h
INTEL_AB_PAGE_REGISTER_1 = 04257h
INTEL_AB_PAGE_REGISTER_2 = 08257h
INTEL_AB_PAGE_REGISTER_3 = 0C257h
INTEL_AB_PAGE_OFFSET_AMT = 080h
INTEL_AB_CHIPSET_UNMAP_VALUE = 00h
INTEL_AB_PAGE_FRAME_COUNT = 4
INTEL_AB_CONST_PAGE_COUNT = 128



SARC_RC2016_CHIPSET_INDEX_PORT = 022h
SARC_RC2016_CHIPSET_VALUE_PORT = 023h

SARC_RC2016_PAGE_REGISTER_0 = 088h
SARC_RC2016_PAGE_REGISTER_1 = 08Ah
SARC_RC2016_PAGE_REGISTER_2 = 08Ch
SARC_RC2016_PAGE_REGISTER_3 = 08Eh

; sets pages d000, d400, d800, dc00 to 
SARC_RC2016_BASE_PAGE_REGISTER_0 = 0c4h

SARC_RC2016_PAGE_OFFSET_AMT = 020h
SARC_RC2016_CHIPSET_UNMAP_VALUE = 00h
SARC_RC2016_PAGE_FRAME_COUNT = 4
SARC_RC2016_CONST_PAGE_COUNT = 128

.CODE


;00000h
dw 0FFFFh
dw 0FFFFh
dw 8000h

;dw 6200h
dw OFFSET EMS_DRIVER_INIT
;dw 6D00h
dw OFFSET EMS_DRIVER_CALL

;0000Ah
db 'EMMXXXX0 DTK VL82C311 Expended Memory Manager V 1.03  06/29/92'

;00048h
pointer_to_ems_init dw OFFSET DRIVER_INIT

;0004Ah various pointers to various possible entry points - most go to "unrecognized command"
dw OFFSET RETURN_UNRECOGNIZED_COMMAND 
dw OFFSET RETURN_UNRECOGNIZED_COMMAND 
dw OFFSET RETURN_UNRECOGNIZED_COMMAND 
dw OFFSET RETURN_UNRECOGNIZED_COMMAND 
dw OFFSET RETURN_UNRECOGNIZED_COMMAND 
;00054h Seems to be the pointer used in ems_driver_call?
dw OFFSET RETURN_UNRECOGNIZED_COMMAND 
dw OFFSET RETURN_UNRECOGNIZED_COMMAND 
dw OFFSET RETURN_UNRECOGNIZED_COMMAND 
dw OFFSET RETURN_UNRECOGNIZED_COMMAND 
dw OFFSET RETURN_SUCCESS 
dw OFFSET RETURN_UNRECOGNIZED_COMMAND 
dw OFFSET RETURN_UNRECOGNIZED_COMMAND


; 00062h
EMS_DRIVER_INIT:
; store 32 bit pointer to reques theader
mov  word ptr cs:[request_header_pointer], bx        
mov  word ptr cs:[request_header_pointer+2], es        
retf 

; todo clean this up
EMS_DRIVER_CALL:
push dx
push cx
push bx
push ax
push si
push di
push ds
push es
push bp
push cs
pop  ds 
mov  bx, ds:word ptr [request_header_pointer]
mov  es, ds:word ptr [request_header_pointer+2]
mov  ax, word ptr es:[bx + 2]
mov  ah, 0
cmp  al, 0ch
jb   CHECK_SOMETHING_IN_PARAMS ; not sure what we're checking or doing here exactly...
mov  al, 0ch
CHECK_SOMETHING_IN_PARAMS:
shl  ax, 1
mov  si, OFFSET pointer_to_ems_init
add  si, ax
call word ptr [si]
pop  bp
pop  es
pop  ds
pop  di
pop  si
pop  ax
pop  bx
pop  cx
pop  dx
retf
;0009Fh
RETURN_SUCCESS:
mov  word ptr [bx + 3], 0100h
ret  
;000a5h

RETURN_UNRECOGNIZED_COMMAND:
mov  word ptr [bx + 3], 08103h
ret  
 


 

; Two-word pairs. first word is page frame (04000h, 04400h... etc) up to f000.  
;                 second word its physical ems index port
; 144 bytes long 
; i think a clone of the above struct in practice except pre-formatted for return in function 5800h (2nd arg a word, ordered lowest segment first)

; CHIPSET SPECIFIC START

mappable_phys_page_struct:

IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 

  ; you can hardcode the chipset's mappable page list here for call 5800

  dw 04000h, 000Ch, 04400h, 000Dh, 04800h, 000Eh, 04C00h, 000Fh
  dw 05000h, 0010h, 05400h, 0011h, 05800h, 0012h, 05C00h, 0013h
  dw 06000h, 0014h, 06400h, 0015h, 06800h, 0016h, 06C00h, 0017h
  dw 07000h, 0018h, 07400h, 0019h, 07800h, 001Ah, 07C00h, 001Bh
  dw 08000h, 001Ch, 08400h, 001Dh, 08800h, 001Eh, 08C00h, 001Fh
  dw 09000h, 0020h, 09400h, 0021h, 09800h, 0022h, 09C00h, 0023h
  dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h
  dw 0E000h, 0004h, 0E400h, 0005h, 0E800h, 0006h, 0EC00h, 0007h
  dw 0C000h, 0008h, 0C400h, 0009h, 0C800h, 000Ah, 0CC00h, 000Bh 

ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET

  dw 04000h, 0000h, 04400h, 0001h, 04800h, 0002h, 04C00h, 0003h
  dw 05000h, 0004h, 05400h, 0005h, 05800h, 0006h, 05C00h, 0007h
  dw 06000h, 0008h, 06400h, 0009h, 06800h, 000Ah, 06C00h, 000Bh
  dw 07000h, 000Ch, 07400h, 000Eh, 07800h, 000Eh, 07C00h, 000Fh
  dw 08000h, 0010h, 08400h, 0011h, 08800h, 0012h, 08C00h, 0013h
  dw 09000h, 0014h, 09400h, 0015h, 09800h, 0016h, 09C00h, 0017h
  dw 0D000h, 0018h, 0D400h, 0019h, 0D800h, 001Ah, 0DC00h, 001Bh
  dw 0E000h, 001Ch, 0E400h, 001Dh, 0E800h, 001Eh, 0EC00h, 001Fh
 
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET

  dw 04000h, 0000h, 04400h, 0001h, 04800h, 0002h, 04C00h, 0003h
  dw 05000h, 0004h, 05400h, 0005h, 05800h, 0006h, 05C00h, 0007h
  dw 06000h, 0008h, 06400h, 0009h, 06800h, 000Ah, 06C00h, 000Bh
  dw 07000h, 000Ch, 07400h, 000Eh, 07800h, 000Eh, 07C00h, 000Fh
  dw 08000h, 0010h, 08400h, 0011h, 08800h, 0012h, 08C00h, 0013h
  dw 09000h, 0014h, 09400h, 0015h, 09800h, 0016h, 09C00h, 0017h
  dw 0C000h, 0018h, 0C400h, 0019h, 0C800h, 001Ah, 0CC00h, 001Bh
  dw 0D000h, 001Ch, 0D400h, 001Dh, 0D800h, 001Eh, 0DC00h, 001Fh

ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET

  dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h

ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET

  dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h

ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD

  dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h

ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET

  dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h

ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD

  dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h

ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A

  dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h

ENDIF
 
; CHIPSET SPECIFIC END





;  32-bit pointer to arguments to driver
request_header_pointer dd 00000000h 






; segment of pageframe
page_frame_segment dw 0000h 
; used to hold a jump addr. could maybe be combined with another temp
temporary_jump_addr dw 0000h
 
; number of ems handles..
handle_count dw 0000h

; stores total logical page count
total_page_count dw 0000h

; stores unallocated logical page count 
unallocated_page_count dw 0000h;

; number of (physically) addressable pages. eg usually 4 for 3.2 style hardware, 28+ for 4.0 style hardware
pageable_frame_count dw 0000h


; EMS Function pointer table
EMS_FUNCTION_POINTERS:
dw  OFFSET EMS_FUNCTION_040h
dw  OFFSET EMS_FUNCTION_041h
dw  OFFSET EMS_FUNCTION_042h
dw  OFFSET EMS_FUNCTION_043h
dw  OFFSET EMS_FUNCTION_044h
dw  OFFSET EMS_FUNCTION_045h
dw  OFFSET EMS_FUNCTION_046h
dw  OFFSET EMS_FUNCTION_047h
dw  OFFSET EMS_FUNCTION_048h
dw  OFFSET EMS_FUNCTION_049h
dw  OFFSET EMS_FUNCTION_04ah
dw  OFFSET EMS_FUNCTION_04bh
dw  OFFSET EMS_FUNCTION_04ch
dw  OFFSET EMS_FUNCTION_04dh
dw  OFFSET EMS_FUNCTION_04eh
dw  OFFSET EMS_FUNCTION_04fh
dw  OFFSET EMS_FUNCTION_050h
dw  OFFSET EMS_FUNCTION_051h
dw  OFFSET EMS_FUNCTION_052h
dw  OFFSET EMS_FUNCTION_053h
dw  OFFSET EMS_FUNCTION_054h
dw  OFFSET EMS_FUNCTION_055h
dw  OFFSET EMS_FUNCTION_056h
dw  OFFSET EMS_FUNCTION_057h
dw  OFFSET EMS_FUNCTION_058h
dw  OFFSET EMS_FUNCTION_059h
dw  OFFSET EMS_FUNCTION_05ah
dw  OFFSET EMS_FUNCTION_05bh
dw  OFFSET EMS_FUNCTION_05ch
dw  OFFSET EMS_FUNCTION_05dh



; BEEP function. unused?
;BEEP:
;push ax
;mov  ax, 0e07h
;int  010h
;pop  ax
;ret  

 
       
   

 
  


 


MAIN_EMS_INTERRUPT_VECTOR:

; inline the main function(s) here.

cmp      ah, 050h
jne      NOT_FUNC_50h

; CHIPSET SPECIFIC START

; implement the inlined function 50 and/or 44 for pagination
; namely, change the registers that are being written to,
; properly handle the 'unmap' case with bx = FFFF/-1, and
; otherwise offset registers if necessary. For example, in the
; case of SCAMP we must offset page registers by 50h or so to
; avoid them mapping to default conventional memory ranges.

EMS_FUNCTION_050h:


IF COMPILE_CHIPSET EQ SCAMP_CHIPSET

  push cx
  push bx
  push si


  ; physical page number mode
  DO_NEXT_PAGE_5000:
  ; next page in ax....
  lodsw
  mov        bx, ax
  lodsw
  ; read two words - bx and ax

  cmp   ax, 12
  ; default, lets assume backfill
  jb PAGEFRAME_REGISTER_5000

  out SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
 
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_with_add
  ; default is not the -1 case
  mov   ax, bx
  add   ax, SCAMP_PAGE_OFFSET_AMT   ; offset by default starting page
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 


  loop       DO_NEXT_PAGE_5000
  ; exits if we fall thru loop with no error
  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret


  PAGEFRAME_REGISTER_5000:
  
  add   ax, 4 ; need to add 4 for d000 case for scamp...  c000, e000  not supported
  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page
  mov   ax, bx
  add   ax, SCAMP_PAGE_OFFSET_AMT   ; offset by default starting page
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 

  loop       DO_NEXT_PAGE_5000

  ; exits if we fall thru loop with no error
  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret

  handle_default_page_with_add:
  add   ax, 4
  
  handle_default_page:
  ; mapping to page -1
  out  SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  loop       DO_NEXT_PAGE_5000
  ; fall thru if done..

  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret

ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET

  push cx
  push bx
  push si
  push dx


  ; physical page number mode
  DO_NEXT_PAGE_5000:
  ; next page in ax....
  lodsw
  mov        bx, ax
  lodsw
  ; read two words - bx and ax

  mov   dx, SCAT_PAGE_SELECT_REGISTER
  
  out   dx, al   ; select EMS page
  mov   dx, SCAT_PAGE_SET_REGISTER
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page

  mov   ax, SCAT_PAGE_OFFSET_AMT   ; offset by default starting page
  add   ax, bx
  out   dx, ax   ; write 16 bit page num. 

  loop       DO_NEXT_PAGE_5000

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret

  handle_default_page:
  ; mapping to page -1
  mov   ax, SCAT_CHIPSET_UNMAP_VALUE
  out   dx, ax   ; write 16 bit page num. 
  loop       DO_NEXT_PAGE_5000


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret

ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET

  push cx
  push bx
  push si
  push dx


  ; physical page number mode
  DO_NEXT_PAGE_5000:
  ; next page in ax....
  lodsw
  mov        bx, ax
  lodsw
  ; read two words - bx and ax

  mov   dx, HT18_PAGE_SELECT_REGISTER
  
  out   dx, al   ; select EMS page
  mov   dx, HT18_PAGE_SET_REGISTER
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page

  mov   ax, HT18_PAGE_OFFSET_AMT   ; offset by default starting page
  add   ax, bx
  out   dx, ax   ; write 16 bit page num. 

  loop       DO_NEXT_PAGE_5000

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret

  handle_default_page:
  ; mapping to page -1
  mov   ax, HT18_CHIPSET_UNMAP_VALUE
  out   dx, ax   ; write 16 bit page num. 
  loop       DO_NEXT_PAGE_5000


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret

ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET

  push cx
  push si
  push dx
  push bx


  ; physical page number mode
  DO_NEXT_PAGE_5000:

  ; preselect the register for the page on/off 

  mov dx, HT12_CHIPSET_CONFIG_REGISTER_SELECT
  mov ax, HT12_EMS_CONFIG_REGISTER
  out dx, al
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  in  al, dx   ; read in the port. we are going to AND the page on...

  mov bl, al   ; store value in bl..

  ; lets load next argument.
  lodsw

  push cx
  mov        cl, al


  ; read two words - dx and ax

  
  mov dl, 1
  sal dl, cl ; turn on the bit for this page

  lodsw

  
  ; bl has previous config register  contents  
  ; cl has page number
  ; dl is ready to be ored etc
  
  
  cmp   ax, 0FFFFh   ; -1 check
  je    handle_default_page

  xchg ax, bx
  or  al, dl  ; page is turned on
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  out dx, al  ; page has been turned on (in case it was off)

  mov ax, cx
  add al, HT12_PAGE_REGISTER_0  ; add by page 0 offset
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_SELECT
  out dx, al    ; select page

  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  mov ax, bx
  add al, HT12_PAGE_OFFSET_AMT
  out dx, al ; write page

  pop cx

  loop       DO_NEXT_PAGE_5000

  ; exit fall thru
  xor ax, ax
  pop bx
  pop dx
  pop si
  pop cx
  iret

  handle_default_page:
  ; mapping to page -1

  
  mov al, bl  
  not dl
  and al, dl  ; page is turned off
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  out dx, al  ; page has been turned on (in case it was off)

  pop cx

  loop       DO_NEXT_PAGE_5000


  ; exit fall thru
  xor ax, ax
  pop bx
  pop dx
  pop si
  pop cx
  iret


ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET

  push cx
  push si
  push dx


  ; physical page number mode
  DO_NEXT_PAGE_5000:
  ; next page in ax....
  lodsw
  mov        dx, ax
  lodsw
  ; read two words - bx and ax

  ror   ax, 2
  ; 0-4 becomes 0208, 4208, 8208, c208
  add   ax, HEDAKA_PAGE_REGISTER_0

  xchg  dx, ax

  cmp   ax, 0FFFFh   ; -1 check
  je    handle_default_page

  add    ax, HEDAKA_PAGE_OFFSET_AMT   ; turn on EMS ON bit and add conventional offset
  out   dx, al   ; write 8 bit page num. 

  loop       DO_NEXT_PAGE_5000

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret

  handle_default_page:
  ; mapping to page -1
  mov   ax, HEDAKA_CHIPSET_UNMAP_VALUE
  out   dx, al   ; write 8 bit page num. 
  loop       DO_NEXT_PAGE_5000


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD

  push cx
  push si
  push dx


  ; physical page number mode
  DO_NEXT_PAGE_5000:
  ; next page in ax....

  lodsw
  add  ax,  LOTECH_PAGE_REGISTER_0
  mov  dx, ax
  lodsw

  out   dx, al   ; write 8 bit page num. 

  loop       DO_NEXT_PAGE_5000


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret



ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET

  push cx
  push si
  push dx


  ; physical page number mode
  DO_NEXT_PAGE_5000:
  ; next page in ax....
  lodsw
  mov        dx, ax
  lodsw
  ; read two words - bx and ax

  ror   ax, 2
  ; 0-4 becomes 0208, 4208, 8208, c208
  add   ax, NEAT_PAGE_REGISTER_0

  xchg  dx, ax

  cmp   ax, 0FFFFh   ; -1 check
  je    handle_default_page

  add   ax, NEAT_PAGE_OFFSET_AMT   ; turn on EMS ON bit
  out   dx, al   ; write 8 bit page num. 

  loop       DO_NEXT_PAGE_5000

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret

  handle_default_page:
  ; mapping to page -1
  mov   ax, NEAT_CHIPSET_UNMAP_VALUE
  out   dx, al   ; write 8 bit page num. 
  loop       DO_NEXT_PAGE_5000


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret

ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD

  push cx
  push si
  push dx

  ; physical page number mode
  DO_NEXT_PAGE_5000:
  ; next page in ax....

  lodsw
  mov  dx, ax
  lodsw


  cmp dx, 0FFFFh
  je    handle_default_page

  mov ah, al
  sal al, 1
  add al, SARC_RC2016_PAGE_REGISTER_0

  out  SARC_RC2016_CHIPSET_INDEX_PORT, al

  
  mov al, ah 

  add  al, 0C4h ; pages 0-4 map to d000-dc000

  mov ah, dl
  and ah, 03h
  sal ah, 4
  add al, ah

  out  SARC_RC2016_CHIPSET_VALUE_PORT, al

  and al, 03h  ; restore page number
  sal al, 1
  add al, SARC_RC2016_PAGE_REGISTER_0 + 1

  out SARC_RC2016_CHIPSET_INDEX_PORT, al
  mov ax, dx
  sar ax, 2
  add ax, SARC_RC2016_PAGE_OFFSET_AMT
  out SARC_RC2016_CHIPSET_VALUE_PORT, al
 

  loop       DO_NEXT_PAGE_5000


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret


  handle_default_page:
  ; mapping to page -1
  ; dx is scratch, ax is page

  mov dx, ax
  add dx, SARC_RC2016_PAGE_REGISTER_0
  add dx, ax
  xchg dx, ax
  ; select page register
  out  SARC_RC2016_CHIPSET_INDEX_PORT, al
  inc  ax     ; dx has next register
  xchg dx, ax
  mov   al, 0h
  out  SARC_RC2016_CHIPSET_VALUE_PORT, al
  xchg dx, ax
  out  SARC_RC2016_CHIPSET_INDEX_PORT, al
  xor ax, ax
  out  SARC_RC2016_CHIPSET_VALUE_PORT, al


  loop       DO_NEXT_PAGE_5000

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret

ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A


  push cx
  push si
  push dx

  ; physical page number mode
  DO_NEXT_PAGE_5000:
  ; next page in ax....

  lodsw
  ror  ax, 2
  add  ax, INTEL_AB_PAGE_REGISTER_0
  mov  dx, ax
  lodsw

  cmp   ax, 0FFFFh   ; -1 check
  je    handle_default_page

  add   ax, INTEL_AB_PAGE_OFFSET_AMT
  out   dx, al   ; write 8 bit page num. 

  loop       DO_NEXT_PAGE_5000


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret


  handle_default_page:
  ; mapping to page -1
  mov   ax, INTEL_AB_CHIPSET_UNMAP_VALUE
  out   dx, al   ; write 8 bit page num. 
  loop       DO_NEXT_PAGE_5000


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret

ENDIF


NOT_FUNC_50h:
  cmp      ah, 044h
  jne      NOT_FUNC_44h

  ; page one function


EMS_FUNCTION_044h:

IF COMPILE_CHIPSET EQ SCAMP_CHIPSET

  xor        ah, ah
  cmp        ax, word ptr cs:[pageable_frame_count]
  jb         ENOUGH_PAGES
  jmp        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        RETURN_RESULT_83
  
  ; al and bx are still the args

  ; dumb hack. internally c000 - ec00 are pages 0-11 in order.
  ; but if you want d000 to be page frame, outwardly we must expose it as 0-4.
  ; so we are assuming 0-4 and adding by 4 to get the real internal offset
  ; and assume 4-12 not used.

  cmp   ax, 12
  jae   NOT_CONVENTIONAL_REGISTER
  add   ax, 4 ; need to add 4 for d000 case for scamp...  we do this branch knowing it may need to undone eventually
  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h
  mov   ax, bx  
  add   ax, SCAMP_PAGE_OFFSET_AMT   ; offset by default starting page
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  xor   ax, ax
  iret

  NOT_CONVENTIONAL_REGISTER:


  ; write ems port... select chipset register
  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h_with_add
  mov   ax, bx 
  add   ax, SCAMP_PAGE_OFFSET_AMT   ; offset by default starting page
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 


  RETURN_RESULT_00:

  xor   ax, ax
  iret
  handle_default_page_44h_with_add:
  add   ax, 4

  handle_default_page_44h:
  ; mapping to page -1
  ; add four to get the default page value for the page 
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  xor   ax, ax
  iret




  PAGE_OVERFLOW_3:
  PAGE_UNDERFLOW_3:

  mov        ah, 080h
  iret

  ; The memory manager couldn't find the EMM handle your program specified.
  RETURN_RESULT_83:
  mov        ah, 083h
  iret

  RETURN_RESULT_8A:
  mov        ah, 08Ah
  iret

  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret

ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET

  ; note: scat maps 0-4 not to the page frame but rather to 4000-4c00
  ; which is unfortunate. its not really backward compatible with 0-3 = page frame 3.2 style programming...
  ; for now in sqemm, call 44h (a 3.2 call) will map 0-4 to the page frame and ignore backfill register addresses.

  xor        ah, ah
  cmp        ax, word ptr cs:[pageable_frame_count]
  jb         ENOUGH_PAGES
  jmp        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        RETURN_RESULT_83
  
  ; al and bx are still the args

  push dx  
 
  mov   dx, SCAT_PAGE_SELECT_REGISTER
  add   al, SCAT_PAGE_REGISTER_OFFSET ; convert 0-4 to 18-1c
  out   dx, al   ; select EMS page
  mov   dx, SCAT_PAGE_SET_REGISTER
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h
  
  mov   ax, SCAT_PAGE_OFFSET_AMT   ; offset by default starting page
  add   ax, bx
  out   dx, ax   ; write 16 bit page num. 
  
  pop   dx
  xor   ax, ax
  iret


  handle_default_page_44h:
  ; mapping to page -1
  mov   ax, SCAT_CHIPSET_UNMAP_VALUE ; "turn off ems for this page" value
  out   dx, ax   ; write 16 bit page num. 
  
  pop   dx
  xor   ax, ax
  iret

  PAGE_OVERFLOW_3:
  PAGE_UNDERFLOW_3:

  mov        ah, 080h
  iret

  ; The memory manager couldn't find the EMM handle your program specified.
  RETURN_RESULT_83:
  mov        ah, 083h
  iret

  RETURN_RESULT_8A:
  mov        ah, 08Ah
  iret

  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret


ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET

  ; note: ht18 like scat maps 0-4 not to the page frame but rather to 4000-4c00
  ; which is unfortunate. its not really backward compatible with 0-3 = page frame 3.2 style programming...
  ; for now in sqemm, call 44h (a 3.2 call) will map 0-4 to the page frame and ignore backfill register addresses.

  xor        ah, ah
  cmp        ax, word ptr cs:[pageable_frame_count]
  jb         ENOUGH_PAGES
  jmp        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        RETURN_RESULT_83
  
  ; al and bx are still the args

  push dx  
 
  mov   dx, HT18_PAGE_SELECT_REGISTER
  add   al, HT18_PAGE_REGISTER_OFFSET ; convert 0-4 to 1c-1f
  out   dx, al   ; select EMS page
  mov   dx, HT18_PAGE_SET_REGISTER
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h
  
  mov   ax, HT18_PAGE_OFFSET_AMT   ; offset by default starting page
  add   ax, bx
  out   dx, ax   ; write 16 bit page num. 
  
  pop   dx
  xor   ax, ax
  iret


  handle_default_page_44h:
  ; mapping to page -1
  mov   ax, HT18_CHIPSET_UNMAP_VALUE ; "turn off ems for this page" value
  out   dx, ax   ; write 16 bit page num. 
  
  pop   dx
  xor   ax, ax
  iret

  PAGE_OVERFLOW_3:
  PAGE_UNDERFLOW_3:

  mov        ah, 080h
  iret

  ; The memory manager couldn't find the EMM handle your program specified.
  RETURN_RESULT_83:
  mov        ah, 083h
  iret

  RETURN_RESULT_8A:
  mov        ah, 08Ah
  iret

  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret

ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET

  xor        ah, ah
  cmp        ax, word ptr cs:[pageable_frame_count]
  jb         ENOUGH_PAGES
  jmp        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        RETURN_RESULT_83
  
  ; al and bx are still the args

  push cx
  push dx


  mov cx, ax  ; page number

  mov dx, HT12_CHIPSET_CONFIG_REGISTER_SELECT
  mov ax, HT12_EMS_CONFIG_REGISTER
  out dx, al
  
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  in  al, dx   ; read in the port. we are going to AND the page on...
  mov dl, 1
  sal dl, cl ; get the bit for the page

  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h

  or  al, dl  ; page is turned on
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  out dx, al  ; page has been turned on (in case it was off)

  mov ax, cx
  add al, HT12_PAGE_REGISTER_0  ; add by page 0 offset
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_SELECT
  out dx, al    ; select page

  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  mov ax, bx
  add al, HT12_PAGE_OFFSET_AMT
  out dx, al ; write page

  pop dx
  pop cx
  xor ax, ax
  iret


  handle_default_page_44h:
  ; mapping to page -1
  ; if we turn off the page then we must update the page bit...


  ; turn off the page
  not dx
  and al, dl   ; turn off page bit
  mov dx, HT12_CHIPSET_CONFIG_REGISTER_READWRITE
  out dx, al  ; page is now turned off

  pop dx
  pop cx
  xor ax, ax
  iret

  PAGE_OVERFLOW_3:
  PAGE_UNDERFLOW_3:

  mov        ah, 080h
  iret

  ; The memory manager couldn't find the EMM handle your program specified.
  RETURN_RESULT_83:
  mov        ah, 083h
  iret

  RETURN_RESULT_8A:
  mov        ah, 08Ah
  iret

  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret

ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET

  ; page frame's pages are 208, 4208, 8208, c208. Technicaly x209 works too.

  xor        ah, ah
  cmp        ax, word ptr cs:[pageable_frame_count]
  jb         ENOUGH_PAGES
  jmp        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        RETURN_RESULT_83
  
  ; al and bx are still the args

  push dx  
 
  ror ax, 2
  add ax, HEDAKA_PAGE_REGISTER_0

  ; 0-4 becomes 0208h, 4208h, 8208h, c208h
  mov dx, ax

  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h

  mov ax, bx
  add    ax, HEDAKA_PAGE_OFFSET_AMT   ; turn on EMS ON bit and add conventional offset
  out   dx, al   ; write 16 bit page num. 

  pop   dx
  xor   ax, ax
  iret


  handle_default_page_44h:
  ; mapping to page -1
  mov   ax, HEDAKA_CHIPSET_UNMAP_VALUE ; "turn off ems for this page" value
  out   dx, al   ; write 16 bit page num. 
  
  pop   dx
  ;xor   ax, ax   ; already 0 above
  iret

  PAGE_OVERFLOW_3:
  PAGE_UNDERFLOW_3:

  mov        ah, 080h
  iret

  ; The memory manager couldn't find the EMM handle your program specified.
  RETURN_RESULT_83:
  mov        ah, 083h
  iret

  RETURN_RESULT_8A:
  mov        ah, 08Ah
  iret

  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD


  ; page frame's pages are 260h, 261h, 262h, 263h

  xor        ah, ah
  cmp        ax, word ptr cs:[pageable_frame_count]
  jb         ENOUGH_PAGES
  jmp        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        RETURN_RESULT_83
  
  ; al and bx are still the args

  push dx  
 
  add ax, LOTECH_PAGE_REGISTER_0
  mov dx, ax
  mov ax, bx

  ; since FF works as an unmap, lets just write that.

  out   dx, al   ; write 16 bit page num. 
  
  pop   dx
  xor   ax, ax  
  iret

  PAGE_OVERFLOW_3:
  PAGE_UNDERFLOW_3:

  mov        ah, 080h
  iret

  ; The memory manager couldn't find the EMM handle your program specified.
  RETURN_RESULT_83:
  mov        ah, 083h
  iret

  RETURN_RESULT_8A:
  mov        ah, 08Ah
  iret

  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret
  
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET

  ; page frame's pages are 208, 4208, 8208, c208. 

  xor        ah, ah
  cmp        ax, word ptr cs:[pageable_frame_count]
  jb         ENOUGH_PAGES
  jmp        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        RETURN_RESULT_83
  
  ; al and bx are still the args

  push dx  
 
  ror ax, 2
  add ax, NEAT_PAGE_REGISTER_0

  ; 0-4 becomes 0208h, 4208h, 8208h, c208h
  mov dx, ax

  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h

  mov   ax, bx
  add   ax, NEAT_PAGE_OFFSET_AMT   ; turn on EMS ON bit
  out   dx, al   ; write 8 bit page num. 

  pop   dx
  xor   ax, ax
  iret

  handle_default_page_44h:
  ; mapping to page -1
  mov   ax, NEAT_CHIPSET_UNMAP_VALUE ; "turn off ems for this page" value
  out   dx, al   ; write 8 bit page num. 
  
  pop   dx
  xor   ax, ax  
  iret

  PAGE_OVERFLOW_3:
  PAGE_UNDERFLOW_3:

  mov        ah, 080h
  iret

  ; The memory manager couldn't find the EMM handle your program specified.
  RETURN_RESULT_83:
  mov        ah, 083h
  iret

  RETURN_RESULT_8A:
  mov        ah, 08Ah
  iret

  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret

ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD


  ; page frame's pages are 260h, 261h, 262h, 263h

  xor        ah, ah
  cmp        ax, word ptr cs:[pageable_frame_count]
  jb         ENOUGH_PAGES
  jmp        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        RETURN_RESULT_83
  
  ; al and bx are still the args

  push dx  
 
  ror  ax, 2
  add  ax, INTEL_AB_PAGE_REGISTER_0
  mov  dx, ax


  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h

  mov   ax, bx
  add   ax, INTEL_AB_PAGE_OFFSET_AMT
  out   dx, al   ; write 16 bit page num. 
  
  pop   dx
  xor   ax, ax  
  iret

  handle_default_page_44h:
  ; mapping to page -1
  mov   ax, INTEL_AB_CHIPSET_UNMAP_VALUE ; "turn off ems for this page" value
  out   dx, al   ; write 8 bit page num. 
  
  pop   dx
  xor   ax, ax  
  iret

  PAGE_OVERFLOW_3:
  PAGE_UNDERFLOW_3:

  mov        ah, 080h
  iret

  ; The memory manager couldn't find the EMM handle your program specified.
  RETURN_RESULT_83:
  mov        ah, 083h
  iret

  RETURN_RESULT_8A:
  mov        ah, 08Ah
  iret

  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret

ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A

  xor        ah, ah
  cmp        ax, word ptr cs:[pageable_frame_count]
  jb         ENOUGH_PAGES
  jmp        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        RETURN_RESULT_83
  
  
  ; al and bx are still the args

  ; 88h + 2*ax
  mov  ah, SARC_RC2016_PAGE_REGISTER_0
  add  ah, al
  add  ah, al

  xchg ah, al
 

  out  SARC_RC2016_CHIPSET_INDEX_PORT, al
  inc  al     
  xchg ah, al  

  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h


  add  al, 0C4h ; pages 0-4 map to d000-dc000


  ; ah is now the next port to write to.
  ; al contains bits 0-3 (d000  page frame target)
  ;    and bits 6-7 (conventional mapping)
  ;    needs bits 4-5 (bits 1-2 of bx)

  mov ah, bl
  and ah, 03h
  sal ah, 4
  add al, ah

  out  SARC_RC2016_CHIPSET_VALUE_PORT, al
  and al, 03

  sal al, 1
  add al, SARC_RC2016_PAGE_REGISTER_0 + 1
  out  SARC_RC2016_CHIPSET_INDEX_PORT, al
  mov ax, bx
  sar ax, 2
  add al, SARC_RC2016_PAGE_OFFSET_AMT
  out SARC_RC2016_CHIPSET_VALUE_PORT, al

  xor   ax, ax  
  iret

  handle_default_page_44h:
  ; mapping to page -1

  mov   al, 00h
  out  SARC_RC2016_CHIPSET_VALUE_PORT, al
  xchg ah, al


  out  SARC_RC2016_CHIPSET_INDEX_PORT, al
  
  xor   ax, ax

  out  SARC_RC2016_CHIPSET_VALUE_PORT, al

  iret

  PAGE_OVERFLOW_3:
  PAGE_UNDERFLOW_3:

  mov        ah, 080h
  iret

  ; The memory manager couldn't find the EMM handle your program specified.
  RETURN_RESULT_83:
  mov        ah, 083h
  iret

  RETURN_RESULT_8A:
  mov        ah, 08Ah
  iret

  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret


ENDIF


NOT_FUNC_44h:

; CHIPSET SPECIFIC END


push       cx
push       si
push       di
push       bp
push       ds
push       es
cld        

; don't support OS function types
cmp        ah, 05dh
ja         RETURN_RESULT_84

; don't support 'GET STATUS' call
cmp        ah, 040h
jb         RETURN_RESULT_84

; subtract 040h - things are now 040h indexed..

sub        ah, 040h
push       bx
mov        bl, ah
xor        bh, bh
shl        bx, 1          ; get word offset of AH - 040h
mov        bx, word ptr cs:[bx + offset EMS_FUNCTION_POINTERS]
mov        word ptr cs:[temporary_jump_addr], bx
pop        bx
jmp        word ptr cs:[temporary_jump_addr]

; The function code passed to the memory manager is not defined.
RETURN_RESULT_84:
jmp        RETURNINTERRUPTRESULT_84

; MAIN EMS FUNCTIONS BELOW

;          1  Get Status                                     40h      

EMS_FUNCTION_040h:
jmp        RETURNINTERRUPTRESULT0

;          2  Get Page Frame Segment Address                 41h       

EMS_FUNCTION_041h:
mov        bx, word ptr cs:[page_frame_segment]
jmp        RETURNINTERRUPTRESULT0

;          3  Get Unallocated Page Count                     42h       

EMS_FUNCTION_042h:
;      FUNCTION 3    GET UNALLOCATED PAGE COUNT
mov        dx, word ptr cs:[unallocated_page_count]
mov        bx, word ptr cs:[total_page_count]
jmp        RETURNINTERRUPTRESULT0

;          4  Allocate Pages                                 43h      
;           BX = num_of_pages_to_alloc

EMS_FUNCTION_043h:
push       cs
pop        ds
push       bx
cmp        bx, 0
je         ARG_BX_IS_0

cmp        bx, word ptr [unallocated_page_count]
ja         ARG_BX_ABOVE_PAGE_COUNT
cmp        bx, word ptr [total_page_count]
ja         ARG_BX_ABOVE_TOTAL_PAGE_COUNT

cmp        word ptr [handle_count], 0
je         NO_HANDLES_LEFT

jmp         FOUND_PAGES_FOR_ALLOCATION

NO_HANDLES_LEFT:
mov        dx, 0
pop        bx
jmp        RETURNINTERRUPTRESULT_85
ARG_BX_ABOVE_TOTAL_PAGE_COUNT:
mov        dx, 0
pop        bx
jmp        RETURNINTERRUPTRESULT_88
ARG_BX_IS_0:
mov        dx, 0
pop        bx
jmp        RETURNINTERRUPTRESULT_89
ARG_BX_ABOVE_PAGE_COUNT:
mov        dx, 1
pop        bx
jmp        RETURNINTERRUPTRESULT_87

FOUND_PAGES_FOR_ALLOCATION:

ALLOCATE_SUCCESS:
sub word ptr [unallocated_page_count], bx

dec word ptr [handle_count]
pop        bx
mov        dx, 0001h   ; force handle 1.

jmp        RETURNINTERRUPTRESULT0

;          5  Map/Unmap Handle Page                          44h      


;          AL = physical_page_number
;                     Contains the number of the physical page into which the
;                     logical page number is to be mapped.  Physical pages are
;                     numbered zero relative.
;          BX = logical_page_number
;                     Contains the number of the logical page to be mapped at the
;                     physical page within the page frame.  Logical pages are
;                     numbered zero relative.  The logical page must be in the
;                     range zero through (number of pages allocated to the EMM
;                     handle - 1).  However, if BX contains logical page number
;                     FFFFh, the physical page specified in AL will be unmapped
;                     (be made inaccessible for reading or writing).
;          DX = emm_handle


; INLINED UP ABOVE

;         6  Deallocate Pages                               45h       

EMS_FUNCTION_045h:
push       cs
pop        ds
push       bx
push       dx


cmp dx, 1
jne  NO_EMM_HANDLE_FOUND

GOOD_EMM_HANDLE:
mov        dx, word ptr [total_page_count]

add        word ptr [unallocated_page_count], dx
inc        word ptr [handle_count]  ; handle freed, increment handle count

pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0

pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_80
NO_EMM_HANDLE_FOUND:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_83
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_86

;          7  Get Version                                    46h       

EMS_FUNCTION_046h:
; Get Version, return 4.0
mov        al, 040h
jmp        RETURNINTERRUPTRESULT0

;          8  Save Page Map                                  47h       

EMS_FUNCTION_047h:
 

;          9  Restore Page Map                               48h       

EMS_FUNCTION_048h:


;          10 Reserved                                       49h       


EMS_FUNCTION_049h:
jmp        RETURNINTERRUPTRESULT0

;          11 Reserved                                       4Ah       

EMS_FUNCTION_04Ah:
jmp        RETURNINTERRUPTRESULT0

;          12 Get Handle Count                               4Bh       

EMS_FUNCTION_04Bh:
;mov        bx, CONST_HANDLE_TABLE_LENGTH
sub        bx, word ptr cs:[handle_count]
jmp        RETURNINTERRUPTRESULT0

;          13 Get Handle Pages                               4Ch       

EMS_FUNCTION_04Ch:


;          14 Get All Handle Pages                           4Dh       
; we write all handles and their page counts to es:di
EMS_FUNCTION_04Dh:



;          15 Get Page Map                                   4E00h    
;             Set Page Map                                   4E01h     
;             Get & Set Page Map                             4E02h     
;             Get Size of Page Map Save Array                4E03h     

EMS_FUNCTION_04Eh:
 

; 16 Get Partial Page Map                           4F00h     
;             Set Partial Page Map                           4F01h     
;             Get Size of Partial Page Map Save Array        4F02h     
EMS_FUNCTION_04Fh:
 

;          17 Map/Unmap Multiple Handle Pages
;             (Physical page number mode)                    5000h     
;             (Segment address mode)                         5001h     

;EMS_FUNCTION_050h:



; note: not really implemented yet
EMS_FUNCTION_05001h:

DO_NEXT_PAGE_5001:
; next page in ax....
lodsw
mov        bx, ax
lodsw
; read two words - bx and ax

cmp ax, 12
jae NOT_CONVENTIONAL_REGISTER_5001
add ax, 4 ; need to add 4 for d000 case for scamp...  c000, e000  not supported
NOT_CONVENTIONAL_REGISTER_5001:
 
out        SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
xchg ax, ax  ; nop delays
xchg ax, ax
xchg ax, ax
mov  ax, bx

; ??? seems this must be on, not sure why actually...
mov  ah, 1    

out  SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 




loop       DO_NEXT_PAGE_5001
xor        ax, ax
pop        bx
jmp        RETURNINTERRUPTRESULT




; The memory manager couldn't find the EMM handle your program specified.
RETURN_RESULT_B_83:
mov        ah, 083h
jmp        RETURN_RESULT_B
nop        

RETURN_RESULT_B_8A:
mov        ah, 08ah
jmp        RETURN_RESULT_B
nop        

;unused
RETURN_RESULT_B_8B:
mov        ah, 08bh
jmp        RETURN_RESULT_B
nop        

RETURN_RESULT_B:
pop        di
pop        si
pop        dx
pop        cx
pop        bx
pop        ds
ret



;          18 Reallocate Pages                               51h       
; DX = handle
;BX = reallocation_count                     
EMS_FUNCTION_051h:



;          19 Get Handle Attribute                           5200h     
;             Set Handle Attribute                           5201h     
;             Get Handle Attribute Capability                5202h     

; it seems this is mostly unsupported.
EMS_FUNCTION_052h:


;          20 Get Handle Name                                5300h     
;             Set Handle Name                                5301h     

       
EMS_FUNCTION_053h:


;          21 Get Handle Directory                           5400h     
;             Search for Named Handle                        5401h     
;             Get Total Handles                              5402h     


EMS_FUNCTION_054h:


;      22 Alter Page Map & Jump
;             (Physical page number mode)                    5500h     
;             Alter Page Map & Jump
;             (Segment address mode)                         5501h     

EMS_FUNCTION_055h:
 

;   BX = total_handles
; The value returned represents the maximum number of handles
; which a program may request the memory manager to allocate
; memory to.  The value returned includes the operating
; system handle (handle value 0).


;          23 Alter Page Map & Call
;             (Physical page number mode)                    5600h     
;             Alter Page Map & Call
;             (Segment address mode)                         5601h     
;             Get Page Map Stack Space Size                  5602h     

EMS_FUNCTION_056h:


; REFER TO EMS 4.0 documentation, this is a doozy!
;          24 Move Memory Region                             5700h     
;             Exchange Memory Region                         5701h     
; xchg_source_dest_struct      STRUC
;             region_length             DD ?   0
;             source_memory_type        DB ?   4
;             source_handle             DW ?   5
;             source_initial_offset     DW ?   7
;             source_initial_seg_page   DW ?   9
;             dest_memory_type          DB ?   a
;             dest_handle               DW ?   b
;             dest_initial_offset       DW ?   d
;             dest_initial_seg_page     DW ?   f
;          xchg_source_dest_struct      ENDS
;          DS:SI = pointer to move_source_dest structure
;     FUNCTION 24   MOVE/EXCHANGE MEMORY REGION
EMS_FUNCTION_057h:

;          25 Get Mappable Physical Address Array            5800h     
;             Get Mappable Physical Address Array Entries    5801h     

;    mappable_phys_page_struct   STRUC
;             phys_page_segment        DW ?
;             phys_page_number         DW ?
;          mappable_phys_page_struct   ENDS

EMS_FUNCTION_058h:
add        sp, 0ch
cmp        al, 0
jne        NOT_05800h
EMS_FUNCTION_05800h:
push       ds
push       es
push       si
push       di
push       bx
push       cs
pop        ds
mov        si, OFFSET mappable_phys_page_struct
mov        cx, word ptr cs:[pageable_frame_count]
LOOP_05800h:
mov        ax, word ptr [si]
stosw
mov        ax, word ptr [si + 2]
stosw
add        si, 4
loop       LOOP_05800h
mov        cx, word ptr cs:[pageable_frame_count]
mov        ah, 0
pop        bx
pop        di
pop        si
pop        es
pop        ds
iret
NOT_05800h:
cmp        al, 1
jne        EXITINTERRUPTB_RESULT8F
EMS_FUNCTION_05801h:
mov        cx, word ptr cs:[pageable_frame_count]
mov        ax, 0
iret
EXITINTERRUPTB_RESULT8F:
mov        ah, 08fh
iret

;          26 Get Hardware Configuration Array               5900h     
;             Get Unallocated Raw Page Count                 5901h     

EMS_FUNCTION_059h:



;          27 Allocate Standard Pages                        5A00h     
;             Allocate Raw Pages                             5A01h     

EMS_FUNCTION_05ah:


;          28 Get Alternate Map Register Set                 5B00h     
;             Set Alternate Map Register Set                 5B01h     
;             Get Alternate Map Save Array Size              5B02h     
;             Allocate Alternate Map Register Set            5B03h     
;             Deallocate Alternate Map Register Set          5B04h     
;             Allocate DMA Register Set                      5B05h     
;             Enable DMA on Alternate Map Register Set       5B06h     
;             Disable DMA on Alternate Map Register Set      5B07h     
;             Deallocate DMA Register Set                    5B08h     



EMS_FUNCTION_05Bh:


;          29 Prepare Expanded Memory Hardware for Warmboot  5Ch       

EMS_FUNCTION_05Ch:


;          30 Enable OS/E Function Set                       5D00h     
;             Disable OS/E Function Set                      5D01h     
;             Return OS/E Access Key                         5D02h     


EMS_FUNCTION_05Dh:
iret

; JUMP TABLE FOR EMS RETURN VALUES

; The manager detected a malfunction in the memory manager software.
RETURNINTERRUPTRESULT_80:
mov        ah, 080h
jmp        RETURNINTERRUPTRESULT

; The memory manager couldn't find the EMM handle your program specified.
RETURNINTERRUPTRESULT_83:
mov        ah, 083h
jmp        RETURNINTERRUPTRESULT

; The function code passed to the memory manager is not defined.
RETURNINTERRUPTRESULT_84:
mov        ah, 084h
jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_85:
mov        ah, 085h
jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_86:
mov        ah, 086h
jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_87:
mov        ah, 087h
jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_88:
mov        ah, 088h
jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_89:
mov        ah, 089h
jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_8A:
mov        ah, 08ah
jmp        RETURNINTERRUPTRESULT

RETURNINTERRUPTRESULT_8B:
mov        ah, 08bh
jmp        RETURNINTERRUPTRESULT

;unused
; There is no room in the save area to store the state of the page mapping registers.  The state of the map registers has not been saved.
RETURNINTERRUPTRESULT_8C:
mov        ah, 08ch
jmp        RETURNINTERRUPTRESULT
nop        

; The save area already contains the page mapping register state for the EMM handle your program specified.
RETURNINTERRUPTRESULT_8D:
mov        ah, 08dh
jmp        RETURNINTERRUPTRESULT
nop        

; There is no page mapping register state in the save area for the specified EMM handle.  Your program didn't save the contents of the page mapping hardware, so Restore Page Map can't restore it.
RETURNINTERRUPTRESULT_8E:
mov        ah, 08eh
jmp        RETURNINTERRUPTRESULT
nop        

;The subfunction parameter is invalid.
RETURN_BAD_SUBFUNCTION_PARAMETER:
mov        ah, 08fh
jmp        RETURNINTERRUPTRESULT
nop        

; The attribute type is undefined.
RETURNINTERRUPTRESULT_90:
mov        ah, 090h
jmp        RETURNINTERRUPTRESULT
nop        

; This feature is not supported.
RETURNINTERRUPTRESULT_91:
mov        ah, 091h
jmp        RETURNINTERRUPTRESULT
nop        

; unused
; The source and destination expanded memory regions have the same handle and overlap.  This is valid for a move.  The move has been completed and the destination region has a
; full copy of the source region.  However, at least a portion of the source region has been overwritten by the move.  Note that the source and destination expanded memory
; regions with different handles will never physically overlap because the different handles specify totally different regions of expanded memory.
RETURNINTERRUPTRESULT_92:
mov        ah, 092h
jmp        RETURNINTERRUPTRESULT
nop        

; unused
; The length of the source or destination expanded memory region specified exceeds the length of the expanded memory region allocated either the source or destination handle.
; Insufficient pages are allocated to this handle to move a region of the size specified.  The program can recover from this condition by allocating additional pages to the
; destination or source handle and attempting to execute the function again.  However, if the application program allocated as much expanded memory as it thought it needed,
; this may be a program error and is not recoverable.
RETURNINTERRUPTRESULT_93:
mov        ah, 093h
jmp        RETURNINTERRUPTRESULT
nop        

; The conventional memory region and expanded memory region overlap.  This is invalid, the conventional memory region cannot overlap the expanded memory region.
RETURNINTERRUPTRESULT_94:
mov        ah, 094h
jmp        RETURNINTERRUPTRESULT
nop        

; The offset within the logical page exceeds the length of the logical page.  The initial source or destination offsets within an expanded memory region must be between 0000h and 3FFFh (16383 or (length of a logical page - 1)).
RETURNINTERRUPTRESULT_95:
mov        ah, 095h
jmp        RETURNINTERRUPTRESULT
nop        

; Region length exceeds 1M byte.
RETURNINTERRUPTRESULT_96:
mov        ah, 096h
jmp        RETURNINTERRUPTRESULT
nop        

; The source and destination expanded memory regions have the same handle and overlap.  This is invalid, the source and destination expanded memory regions cannot have the same
; handle and overlap when they are being exchanged. Note that the source and destination expanded memory regions which have different handles will never physically overlap
; because the different handles specify totally different regions of expanded memory.
RETURNINTERRUPTRESULT_97:
mov        ah, 097h
jmp        RETURNINTERRUPTRESULT
nop        

; The memory source and destination types are undefined.
RETURNINTERRUPTRESULT_98:
mov        ah, 098h
jmp        RETURNINTERRUPTRESULT
nop        

; unused, nonexistant in spec
RETURNINTERRUPTRESULT_99:
mov        ah, 099h
jmp        RETURNINTERRUPTRESULT
nop        

; unused
; Alternate map register sets are supported, but the alternate map register set specified is not supported.
; Alternate DMA register sets are supported, but the alternate DMA register set specified is not supported.
RETURNINTERRUPTRESULT_9A:
mov        ah, 09ah
jmp        RETURNINTERRUPTRESULT
nop        

; unused
; Alternate map register sets are supported.  However, all alternate map register sets are currently allocated.
; Alternate DMA register sets are supported.  However, all alternate DMA register sets are currently allocated.
RETURNINTERRUPTRESULT_9B:
mov        ah, 09bh
jmp        RETURNINTERRUPTRESULT
nop        

; Alternate map register sets are not supported and the alternate map register set specified is not zero.
; Alternate DMA register sets are not supported and the alternate DMA register set specified is not zero.
RETURNINTERRUPTRESULT_9C:
mov        ah, 09ch
jmp        RETURNINTERRUPTRESULT
nop        

; unused
; Alternate map register sets are supported, but the alternate map register set specified is either not defined or not allocated.
; DMA register sets are supported, but the DMA register set specified is either not defined or not allocated.
RETURNINTERRUPTRESULT_9D:
mov        ah, 09dh
jmp        RETURNINTERRUPTRESULT
nop        

; unused
; Dedicated DMA channels are not supported.
RETURNINTERRUPTRESULT_9E:
mov        ah, 09eh
jmp        RETURNINTERRUPTRESULT
nop        

; unused
; Dedicated DMA channels are supported, but the DMA channel specified is not supported.
RETURNINTERRUPTRESULT_9f:
mov        ah, 09fh
jmp        RETURNINTERRUPTRESULT
nop        

; No corresponding handle could be found for the handle name specified.
RETURNINTERRUPTRESULT_A0:
mov        ah, 0a0h
jmp        RETURNINTERRUPTRESULT
nop        

; A handle found had no name (all ASCII nulls).
; A handle with this name already exists.  The specified handle was not assigned a name.
RETURNINTERRUPTRESULT_A1:
mov        ah, 0a1h
jmp        RETURNINTERRUPTRESULT
nop        

; An attempt was made to wrap around the 1M-byte address space of conventional memory during the move.  The combination of source/destination 
; starting address and length of the region to be moved exceeds 1M byte.  No data was moved.
; An attempt was made to wrap around the 1M-byte address space of conventional memory during the exchange.  The source starting address together 
; with the length of the region to be exchanged exceeds 1M byte.  No data was exchanged.
RETURNINTERRUPTRESULT_A2:
mov        ah, 0a2h
jmp        RETURNINTERRUPTRESULT
nop        

; The contents of the source array have been corrupted, or the pointer passed to the subfunction is invalid.
RETURNINTERRUPTRESULT_A3:
mov        ah, 0a3h
jmp        RETURNINTERRUPTRESULT
nop        

; The operating system has denied access to this function. The function cannot be used at this time.
RETURNINTERRUPTRESULT_A4:
mov        ah, 0a4h
jmp        RETURNINTERRUPTRESULT
nop        

RETURNINTERRUPTRESULT0:
mov        ah, 0
RETURNINTERRUPTRESULT:
pop        es
pop        ds
pop        bp
pop        di
pop        si
pop        cx
iret

;db 'SQEMM PROGRAM END'

end_of_driver_label:


string_driver_exists db 0Dh, 0Ah, 'EMS Driver already loaded (chaining not supported).',0Dh, 0Ah, '$'
string_driver_successfully_installed db 0Dh, 0Ah, 'SQEMM successfully initialized.', 0Ah, 0Dh, '$'
string_driver_failed_installing db 0Dh, 0Ah, ' Driver not installed.', 0Ah,  '$'
IF COMPILE_CHIPSET EQ SCAMP_CHIPSET
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for VLSI SCAMP', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for C&T SCAT', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for Headland HT-18, HT-21, HT-22, HT-25', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for Headland HT-12', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for HEDAKA/CITYGATE/PCCHIPS Chipsets', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for Lo-tech EMS Board', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for Chips NEAT', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for Intel Above Board', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for SARC RC2016A', 0Dh, 0Ah,'$'
ENDIF





DRIVER_INIT:
mov        ax, cs
mov        ds, ax
mov        word ptr [pointer_to_ems_init], OFFSET RETURN_UNRECOGNIZED_COMMAND     ; overwrite pointer to this init function with pointer to "failed to install" (03fa5h)
lea        dx, [string_main_header]

call       PRINT_STRING
; get interrupt vector. check it's header/string
mov        ax, 03567h
int        021h
mov        di, 0ah
mov        si, di
mov        cx, 8
rep cmpsb
 
jne        EMS_INTERRUPT_FREE
; an ems driver is already installed

lea        dx, [string_driver_exists]

jmp        DRIVER_NOT_INSTALLED_2

EMS_INTERRUPT_FREE:


; CHIPSET SPECIFIC START

IF COMPILE_CHIPSET EQ SCAMP_CHIPSET


  ; for porting to other chipsets, prepare chipset registers
  ; and driver variables here. In this case we set page frame
  ; to D000, set 36 mappable pages, we are only allowing a
  ; single handle, and set 256 mappable pages. we also prepare
  ; ems registers to initial values and enable EMS and backfill.


  ; hard coded to d000 for now
  mov        word ptr [page_frame_segment], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr [unallocated_page_count], CONST_PAGE_COUNT
  mov        word ptr [total_page_count], CONST_PAGE_COUNT
  mov        word ptr [pageable_frame_count], SCAMP_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr [handle_count], 01h


  ; enable d000 register and backfill

  mov        al, 0Bh
  out        0ECh, al
  xchg ax, ax
  xchg ax, ax
  xchg ax, ax
  xchg ax, ax
  ;mov        al, 0A0h   ; turn on ems 
  mov        al, 0E0h   ; turn on ems, backfill
  out        0EDh, al


  mov        al, 0Ch
  out        0ECh, al
  xchg ax, ax
  xchg ax, ax
  xchg ax, ax
  xchg ax, ax
  mov        al, 0F0h  ; turn on d000 as page frame
  out        0EDh, al

  ; set first four page registers for d000
  xor   cx, cx
  mov   cl, 3h  ; 24 registers, 0C to 23
  mov   ax, 4

  enablepageloop:
  out   SCAMP_PAGE_SELECT_REGISTER, al
  sub   ax, 4
  xchg  ax, ax
  xchg  ax, ax
  out   SCAMP_PAGE_SET_REGISTER, ax
  add   ax, 5         ; inc included..
  loop enablepageloop


  ; NOTE: If we enable backfill, we must initialize page registers for backfill region
  ;  4-28 to be 4-28

  mov   ax, 0Ch
  mov   cl, 18h  ; 24 registers, 0C to 23

  ; 0c maps to 10, 
  ; 0d maps to 11, 
  ; ...
  ; 23 maps to 27

  enablebackfillloop:
  out   SCAMP_PAGE_SELECT_REGISTER, al
  add   ax, 4
  xchg  ax, ax
  xchg  ax, ax
  out   SCAMP_PAGE_SET_REGISTER, ax
  sub   ax, 3       ; inc included..
  loop enablebackfillloop

  ; note: we must treat 'set page to default/-1' case as these values
  ; and we must offset every page set offset by 28h otherwise to avoid these defaults.

ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET

  ; enable writes to registers...
  mov al, SCAT_EMS_CONFIG_REGISTER
  out SCAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  mov al, 0C0h   ; enable EMS, and make registers writeable
  out SCAT_CHIPSET_CONFIG_REGISTER_READWRITE, al

  ; hard coded to d000 for now
  mov        word ptr [page_frame_segment], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr [unallocated_page_count], CONST_PAGE_COUNT
  mov        word ptr [total_page_count], CONST_PAGE_COUNT
  mov        word ptr [pageable_frame_count], SCAT_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr [handle_count], 01h

ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET

; enable writes to registers...
  mov al, HT18_EMS_CONFIG_REGISTER
  mov dx, HT18_CHIPSET_CONFIG_REGISTER_SELECT
  out dx, al
  mov dx, HT18_CHIPSET_CONFIG_REGISTER_READWRITE
  in al, dx
  or al, 02h                                        ; enable EMS flag on
  out dx, al

  ; hard coded to d000 for now
  mov        word ptr [page_frame_segment], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr [unallocated_page_count], CONST_PAGE_COUNT
  mov        word ptr [total_page_count], CONST_PAGE_COUNT
  mov        word ptr [pageable_frame_count], HT18_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr [handle_count], 01h

ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET

  ; initialization of registers
  mov   dx, HT12_PAGE_SELECT_REGISTER
  mov   al, HT12_EMS_CONFIG_REGISTER 
  out   dx, al   

  ; enable ems
  mov   dx, HT12_PAGE_SET_REGISTER
  mov   al, 0CFh  ; select all 4 pages on, D000 page frame, EMS ON
  out   dx, al   

  ; set default page 0
  mov   dx, HT12_PAGE_SELECT_REGISTER
  mov   al, HT12_PAGE_REGISTER_0
  out   dx, al   

  mov   dx, HT12_PAGE_SET_REGISTER
  mov   al, HT12_PAGE_OFFSET_AMT + 0
  out   dx, al   
  ; set default page 1
  mov   dx, HT12_PAGE_SELECT_REGISTER
  mov   al, HT12_PAGE_REGISTER_1
  out   dx, al   

  mov   dx, HT12_PAGE_SET_REGISTER
  mov   al, HT12_PAGE_OFFSET_AMT + 1
  out   dx, al   
  ; set default page 2
  mov   dx, HT12_PAGE_SELECT_REGISTER
  mov   al, HT12_PAGE_REGISTER_2
  out   dx, al   

  mov   dx, HT12_PAGE_SET_REGISTER
  mov   al, HT12_PAGE_OFFSET_AMT + 2
  out   dx, al   
  ; set default page 3
  mov   dx, HT12_PAGE_SELECT_REGISTER
  mov   al, HT12_PAGE_REGISTER_3
  out   dx, al   

  mov   dx, HT12_PAGE_SET_REGISTER
  mov   al, HT12_PAGE_OFFSET_AMT + 3
  out   dx, al   


  ; hard coded to d000 for now
  mov        word ptr [page_frame_segment], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr [unallocated_page_count], CONST_PAGE_COUNT
  mov        word ptr [total_page_count], CONST_PAGE_COUNT
  mov        word ptr [pageable_frame_count], HT12_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr [handle_count], 01h

ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET

; todo: enable ems if not set in bios? dont know registers 
; initialization of registers
  mov   dx, 0208h
  mov   ax, HEDAKA_PAGE_OFFSET_AMT
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 

  ; hard coded to d000 for now
  mov        word ptr [page_frame_segment], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr [unallocated_page_count], HEDAKA_CONST_PAGE_COUNT
  mov        word ptr [total_page_count], HEDAKA_CONST_PAGE_COUNT
  mov        word ptr [pageable_frame_count], HEDAKA_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr [handle_count], 01h

ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD

  mov   dx, LOTECH_PAGE_REGISTER_0
  mov   ax, 000h 
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 
  inc   dx
  inc   al
  out   dx, al   ; write 8 bit page num. 

  ; hard coded to d000 for now
  mov        word ptr [page_frame_segment], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr [unallocated_page_count], CONST_PAGE_COUNT
  mov        word ptr [total_page_count], CONST_PAGE_COUNT
  mov        word ptr [pageable_frame_count], LOTECH_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr [handle_count], 01h

ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET

; offset pages by 2 MB

mov al, 06Eh
out NEAT_CHIPSET_CONFIG_REGISTER_SELECT, al
mov al, 055h
out NEAT_CHIPSET_CONFIG_REGISTER_READWRITE, al

  mov   dx, 0208h
  mov   ax, NEAT_PAGE_OFFSET_AMT
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 

  ; page frame d000 for now
  mov        word ptr [page_frame_segment], 0D000h

  ; 256 pages hardcoded for now
  mov        word ptr [unallocated_page_count], NEAT_CONST_PAGE_COUNT
  mov        word ptr [total_page_count], NEAT_CONST_PAGE_COUNT
  mov        word ptr [pageable_frame_count], NEAT_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr [handle_count], 01h

ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD

  mov   dx, INTEL_AB_PAGE_REGISTER_0
  mov   ax, 80h 
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 
  add   dh, 040h
  inc   al
  out   dx, al   ; write 8 bit page num. 

  ; hard coded to d000 for now
  mov        word ptr [page_frame_segment], 0D000h

  ; 128 pages hardcoded for now
  mov        word ptr [unallocated_page_count], INTEL_AB_CONST_PAGE_COUNT
  mov        word ptr [total_page_count], INTEL_AB_CONST_PAGE_COUNT
  mov        word ptr [pageable_frame_count], INTEL_AB_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr [handle_count], 01h

ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A

  mov   ax, SARC_RC2016_PAGE_REGISTER_0
  out   SARC_RC2016_CHIPSET_INDEX_PORT, al  
  mov   ax, SARC_RC2016_BASE_PAGE_REGISTER_0
  out   SARC_RC2016_CHIPSET_VALUE_PORT, al  

  mov   ax, SARC_RC2016_PAGE_REGISTER_0 + 1
  out   SARC_RC2016_CHIPSET_INDEX_PORT, al  
  mov   ax, SARC_RC2016_PAGE_OFFSET_AMT
  out   SARC_RC2016_CHIPSET_VALUE_PORT, al  

  mov   ax, SARC_RC2016_PAGE_REGISTER_1
  out   SARC_RC2016_CHIPSET_INDEX_PORT, al  
  mov   ax, SARC_RC2016_BASE_PAGE_REGISTER_0+1
  out   SARC_RC2016_CHIPSET_VALUE_PORT, al  

  mov   ax, SARC_RC2016_PAGE_REGISTER_1 + 1
  out   SARC_RC2016_CHIPSET_INDEX_PORT, al  
  mov   ax, SARC_RC2016_PAGE_OFFSET_AMT
  out   SARC_RC2016_CHIPSET_VALUE_PORT, al  

  mov   ax, SARC_RC2016_PAGE_REGISTER_2
  out   SARC_RC2016_CHIPSET_INDEX_PORT, al  
  mov   ax, SARC_RC2016_BASE_PAGE_REGISTER_0+2
  out   SARC_RC2016_CHIPSET_VALUE_PORT, al  

  mov   ax, SARC_RC2016_PAGE_REGISTER_2 + 1
  out   SARC_RC2016_CHIPSET_INDEX_PORT, al  
  mov   ax, SARC_RC2016_PAGE_OFFSET_AMT
  out   SARC_RC2016_CHIPSET_VALUE_PORT, al  

  mov   ax, SARC_RC2016_PAGE_REGISTER_3
  out   SARC_RC2016_CHIPSET_INDEX_PORT, al  
  mov   ax, SARC_RC2016_BASE_PAGE_REGISTER_0+3
  out   SARC_RC2016_CHIPSET_VALUE_PORT, al  

  mov   ax, SARC_RC2016_PAGE_REGISTER_3 + 1
  out   SARC_RC2016_CHIPSET_INDEX_PORT, al  
  mov   ax, SARC_RC2016_PAGE_OFFSET_AMT
  out   SARC_RC2016_CHIPSET_VALUE_PORT, al  

  

  ; hard coded to d000 for now
  mov        word ptr [page_frame_segment], 0D000h

  ; 128 pages hardcoded for now
  mov        word ptr [unallocated_page_count], SARC_RC2016_CONST_PAGE_COUNT
  mov        word ptr [total_page_count], SARC_RC2016_CONST_PAGE_COUNT
  mov        word ptr [pageable_frame_count], SARC_RC2016_PAGE_FRAME_COUNT

  ; one handle for now
  mov        word ptr [handle_count], 01h

ENDIF

; CHIPSET SPECIFIC END




; set interrupt vector  067h

lea        dx, MAIN_EMS_INTERRUPT_VECTOR
mov        al, 067h
mov        ah, 025h
int        021h

DRIVER_INSTALLED:

lea        dx, [string_driver_successfully_installed]

call       PRINT_STRING
les        bx, [request_header_pointer]
mov        word ptr es:[bx + 3], 0100h

; 0Eh: MS-DOS 5 set pointer to end of memory used by driver
; 10h: the segment for above
mov        word ptr es:[bx + 0eh], offset  end_of_driver_label
mov        word ptr es:[bx + 010h], cs
;mov        word ptr es:[bx + 017h], 00
ret

; DRIVER NOT INSTALLED
; preloaded with string 'reason' for the print string
DRIVER_NOT_INSTALLED:
call       PRINT_STRING 

lea        dx, [string_driver_failed_installing]

; todo whats this
DRIVER_NOT_INSTALLED_2:
call       PRINT_STRING
les        bx, [request_header_pointer]
mov        word ptr es:[bx + 3], 0810ch
mov        word ptr es:[bx + 0eh], offset end_of_driver_label
mov        word ptr es:[bx + 010h], cs
;mov        word ptr es:[bx + 017h], 00
ret

; prints string ending in '$' in DS:DX
PRINT_STRING:
push       ds
push       ax
push       cs
pop        ds
mov        ah, 9
int        021h
pop        ax
pop        ds
ret



END