; Copyright (C) 2024-2026 Patrick Goncalves (sqpat17)

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
STANDARD_EMS_BOARD = 10
FANTASY_EMS = 11
RODNEY_EMS = 12

;COMPILE_CHIPSET = SCAMP_CHIPSET
COMPILE_CHIPSET = SCAT_CHIPSET
;COMPILE_CHIPSET = HT18_CHIPSET
;COMPILE_CHIPSET = HT12_CHIPSET
;COMPILE_CHIPSET = HEDAKA_CHIPSET
;COMPILE_CHIPSET = LOTECH_BOARD
;COMPILE_CHIPSET =  NEAT_CHIPSET
;COMPILE_CHIPSET =  INTEL_ABOVEBOARD
;COMPILE_CHIPSET =  SARC_RC2016A
;COMPILE_CHIPSET = STANDARD_EMS_BOARD
;COMPILE_CHIPSET = FANTASY_EMS
;COMPILE_CHIPSET = RODNEY_EMS

RET_OPCODE = 0C3h


COMPILE_386  = 3
COMPILE_286  = 2
COMPILE_186  = 1
COMPILE_8086 = 0

COMPISA = COMPILE_8086

IF COMPILE_CHIPSET EQ LOTECH_BOARD
	.8086
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
	.8086
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


.DATA



CONST_HANDLE_TABLE_LENGTH = 0FFh
PAGE_COUNT_4_MB = 256
OFFSET_1_MB = 64
OFFSET_2_MB = 128
; 80h represents 2 MB offset beyond EMS start point

FUNC_24_SOURCE_PAGE_FRAME_INDEX = 2
FUNC_24_DEST_PAGE_FRAME_INDEX = 3



IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE defs\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE defs\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE defs\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE defs\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE defs\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE defs\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE defs\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE defs\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE defs\neat.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE defs\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE defs\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE defs\standard.asm
ENDIF







.CODE


;00000h ; pointer to the next header.
dw 0FFFFh
dw 0FFFFh
dw 8000h

;dw 6200h
dw OFFSET EMS_DRIVER_INIT
;dw 6D00h
dw OFFSET EMS_DRIVER_CALL

;0000Ah
db 'EMMXXXX0'

ALIGN 2
;00048h
pointer_to_ems_init:
dw OFFSET DRIVER_INIT


; TODO: why cant this move to noneresident?

; 0004Ah
EMS_DRIVER_INIT:
public EMS_DRIVER_INIT
; store 32 bit pointer to request header
mov  word ptr cs:[request_header_pointer], bx        
mov  word ptr cs:[request_header_pointer+2], es        
retf 


EMS_DRIVER_CALL:
push  bx
push  ds

lds  bx, dword ptr cs:[request_header_pointer]

cmp  byte ptr ds:[bx + DOS_DRIVER_REQUEST_HEADER.drrh_command_code], 0
SELFMODIFY_prevent_double_init:
je   do_init
SELFMODIFY_prevent_double_init_AFTER:
cmp  byte ptr ds:[bx + DOS_DRIVER_REQUEST_HEADER.drrh_command_code], 10



jne  RETURN_UNRECOGNIZED_COMMAND

RETURN_SUCCESS:
mov  word ptr ds:[bx + DOS_DRIVER_REQUEST_HEADER.drrh_status], 0100h

pop  ds
pop  bx
retf

do_init:
pop  ds
pop  bx
PUSHA_MACRO

call  DRIVER_INIT

POPA_MACRO
retf

RETURN_UNRECOGNIZED_COMMAND:
mov  word ptr ds:[bx + DOS_DRIVER_REQUEST_HEADER.drrh_status], 08103h
pop  ds
pop  bx
retf
 


ALIGN 2 


IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE vars\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE vars\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE vars\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE vars\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE vars\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE vars\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE vars\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE vars\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE vars\neat.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE vars\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE vars\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE vars\standard.asm
ENDIF
 
; CHIPSET SPECIFIC END



ALIGN 2

;  32-bit pointer to arguments to driver
request_header_pointer dd 00000000h 










; EMS Function pointer table
; branches tested, couldnt get it smaller
_EMS_FUNCTION_POINTERTABLE:
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
dw  OFFSET EMS_FUNCTION_05001h
dw  OFFSET EMS_FUNCTION_051h
dw  OFFSET EMS_FUNCTION_052h
dw  OFFSET EMS_FUNCTION_053h
dw  OFFSET EMS_FUNCTION_054h
dw  OFFSET EMS_FUNCTION_055h
dw  OFFSET EMS_FUNCTION_056h
dw  OFFSET EMS_FUNCTION_057h
dw  OFFSET EMS_FUNCTION_058h


_current_call_subfunction_value:
db  0
ALIGN 2


func_44_no_emm_handle_found:
mov        ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
iret
ALIGN 2
 


MAIN_EMS_INTERRUPT_VECTOR:

; inline the main function(s) here.

cmp      ax, 05000h
jne      NOT_FUNC_50h

; CHIPSET SPECIFIC START

; DRIVER PHILOSOPHY
; most calls are remaps, and those are the most crucial to performance
; check for those first if/else type
; then jump to table to handle the rest.
; pagination functions are very chipset if/else implementations, most of the others are simple


EMS_FUNCTION_050h:

;          17 Map/Unmap Multiple Handle Pages
;             (Physical page number mode)                    5000h     
;             (Segment address mode)                         5001h     


IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE func17-0\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE func17-0\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE func17-0\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE func17-0\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE func17-0\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE func17-0\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE func17-0\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE func17-0\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE func17-0\neat.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE func17-0\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE func17-0\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE func17-0\standard.asm
ENDIF




NOT_FUNC_50h:
  cmp      ah, 044h
  jne      NOT_FUNC_44h





  ; page one function



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

EMS_FUNCTION_044h:

IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE func05\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE func05\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE func05\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE func05\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE func05\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE func05\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE func05\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE func05\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE func05\neat.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE func05\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE func05\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE func05\standard.asm
ENDIF


  
func_17_page_too_high:
func_05_page_too_high:
mov        ah, 08Bh
iret

; reserved, dont implement
EMS_FUNCTION_049h:
EMS_FUNCTION_04Ah:

; Do not implement OS level 4.0 functions for single application driver.
EMS_FUNCTION_052h:
EMS_FUNCTION_053h:
EMS_FUNCTION_054h:

EMS_FUNCTION_059h:

EMS_FUNCTION_05Ah:
EMS_FUNCTION_05Bh:
EMS_FUNCTION_05Ch:

EMS_FUNCTION_05Dh:
; These functions will remain unimplemented for this version of the driver. fall thru

;          1  Get Status                                     40h      

EMS_FUNCTION_040h:
xchg       ax, bx
; ah is already 0 because bh was 0 from jump table lookup
iret


NOT_FUNC_44h:

; CHIPSET SPECIFIC END

; no pushes, etc done yet!


; don't support oob function types
mov        byte ptr cs:[_current_call_subfunction_value], al
mov        al, ah
cmp        al, 05dh
ja         bad_function

cmp        al, 059h
jae        EMS_FUNCTION_059h  ; not implementing

; don't support calls below 040h
sub        al, 040h
jb         bad_function

; subtract 040h - things are now 040h indexed..

cbw
xchg       ax, bx
shl        bx, 1          
jmp        word ptr cs:[bx + offset _EMS_FUNCTION_POINTERTABLE] ; NOTE: ax has bx value! must be restored.

; The function code passed to the memory manager is not defined.
bad_function:
; The function code passed to the memory manager is not defined.
mov        ah, 084h
iret

; MAIN EMS FUNCTIONS BELOW


;          2  Get Page Frame Segment Address                 41h       

EMS_FUNCTION_041h:
_RESIDENT_VARIABLE_page_frame_segment:
mov        ax, 0D000h  ; return in bx
xchg       ax, bx
; ah is already 0 because bh was 0 from jump table lookup
iret

;          3  Get Unallocated Page Count                     42h       

EMS_FUNCTION_042h:
;      FUNCTION 3    GET UNALLOCATED PAGE COUNT
_RESIDENT_VARIABLE_unallocated_page_count:
mov        dx, 01000h
_RESIDENT_VARIABLE_total_EMS_page_count:
mov        ax, 01000h  ; return in bx
xchg       ax, bx
; ah is already 0 because bh was 0 from jump table lookup
iret

;          4  Allocate Pages                                 43h      
;           BX = num_of_pages_to_alloc

EMS_FUNCTION_043h:

; ax has bx value..

test       ax, ax
jz         func_43_alloc_pages_0_error

cmp        ax, word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count+1]
ja         func_43_allocated_too_many_pages
cmp        ax, word ptr cs:[_RESIDENT_VARIABLE_total_EMS_page_count+1]
ja         func_43_allocated_too_many_pages_above_total

dec        word ptr cs:[_RESIDENT_VARIABLE_handle_count+1]

js         func_43_no_handles_Left

ALLOCATE_SUCCESS:
sub        word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count+1], ax
xchg       ax, bx
cwd        ; dx = 0
inc        dx ;  handle always 1.
iret



func_43_no_handles_Left:
inc        word ptr cs:[_RESIDENT_VARIABLE_handle_count+1]

xchg       ax, bx
cwd        ; dx = 0
mov        ah, 085h  ; All EMM handles are being used.
iret
func_43_allocated_too_many_pages_above_total:
func_51_allocated_too_many_pages_above_total:
xchg       ax, bx
cwd        ; dx = 0
mov        ah, 087h  ; There aren't enough expanded memory pages present in the system to satisfy your program's request.
iret
func_43_alloc_pages_0_error:
xchg       ax, bx
cwd        ; dx = 0
mov        ah, 089h  ; Your program attempted to allocate zero pages.
iret
func_43_allocated_too_many_pages:
xchg       ax, bx
cwd        ; dx = 0
mov        ah, 087h  ; There aren't enough expanded memory pages present in the system to satisfy your program's request.
iret







;         6  Deallocate Pages                               45h       

EMS_FUNCTION_045h:
xchg       ax, bx  ; put bx back
cmp        dx, 1
jne        func_45_no_emm_handle_found

GOOD_EMM_HANDLE:
mov        ax, word ptr cs:[_RESIDENT_VARIABLE_total_EMS_page_count+1]

mov        word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count+1], ax
inc        word ptr cs:[_RESIDENT_VARIABLE_handle_count+1]  ; handle freed, increment handle count

xor        ax, ax
iret

func_45_no_emm_handle_found:
func_4C_no_emm_handle_found:
func_51_no_emm_handle_found:
mov        ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
iret

;          7  Get Version                                    46h       

EMS_FUNCTION_046h:
; Get Version, return 4.0
xchg       ax, bx
mov        al, 040h ; ah already 0
iret 




;          12 Get Handle Count                               4Bh       

EMS_FUNCTION_04Bh:
xchg       ax, bx
_RESIDENT_VARIABLE_handle_count:
mov        bx, 01000h
iret


;          13 Get Handle Pages                               4Ch       

EMS_FUNCTION_04Ch:
xchg       ax, bx
cmp        dx, 1
jne        func_4C_no_emm_handle_found

mov        bx, word ptr cs:[_RESIDENT_VARIABLE_total_EMS_page_count+1]
sub        bx, word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count+1]
iret






;          18 Reallocate Pages                               51h       
; DX = handle
;BX = reallocation_count                     
EMS_FUNCTION_051h:
xchg       ax, bx  ; on failure dont change bx
cmp        dx, 1
jne        func_51_no_emm_handle_found
mov        ax, word ptr cs:[_RESIDENT_VARIABLE_total_EMS_page_count+1]
sub        ax, bx
jb         func_51_allocated_too_many_pages_above_total
xchg       ax, bx
xor        ax, ax  ; ah = 0
iret





;      22 Alter Page Map & Jump
;             (Physical page number mode)                    5500h     
;             Alter Page Map & Jump
;             (Segment address mode)                         5501h     

EMS_FUNCTION_055h:
; TODO NOT DONE, should be done
xchg       ax, bx
iret
 

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
; TODO NOT DONE, should be done
xchg       ax, bx
iret


; REFER TO EMS 4.0 documentation, this is a doozy!
;          24 Move Memory Region                             5700h     

;move_source_dest_struct      STRUC
;             region_length             DD  ?
;             source_memory_type        DB  ?
;             source_handle             DW  ?
;             source_initial_offset     DW  ?
;             source_initial_seg_page   DW  ?
;             dest_memory_type          DB  ?
;             dest_handle               DW  ?
;             dest_initial_offset       DW  ?
;             dest_initial_seg_page     DW  ?
;          move_source_dest_struct      ENDS
ALIGN 2
_RESIDENT_VARIABLE_FUNC_24_source_original_page:
dw 0
_RESIDENT_VARIABLE_FUNC_24_dest_original_page:
dw 0
_RESIDENT_VARIABLE_FUNC_24_source_current_page:
dw 0
_RESIDENT_VARIABLE_FUNC_24_dest_current_page:
dw 0

; The function code passed to the memory manager is not defined.
func_24_bad_subfunction:
mov        ah, 08Fh  ;  The subfunction parameter is invalid.
iret
func_24_bad_handle:
mov        ah, 083h   ; The manager couldn't find either the source or destination EMM handles.
jmp        func_24_error
func_24_unowned_memory:
; TODO catch
mov        ah, 08Ah   ; One or more of the logical pages is out of the range of logical pages allocated to the source/destination handle.
jmp        func_24_error
func_24_region_overlap:
; TODO catch
mov        ah, 094h   ; The conventional memory region and expanded memory region overlap.
jmp        func_24_error
func_24_too_large:
mov        ah, 096h   ; Region length exceeds 1M Byte limit.
jmp        func_24_error
func_24_wraparound:
; TODO catch
mov        ah, 0A2h   ; An attempt was made to wrap around the 1M-byte address space of conventional memory during the move.
jmp        func_24_error
func_24_overlap:
; TODO catch
mov        ah, 097h   ; The source and destination expanded memory regions have the same handle and overlap.
jmp        func_24_error
func_24_invalid_memtype:
mov        ah, 098h
func_24_error:
mov        es, ax
POPA_MACRO
mov        ax, es ; param
pop        ds
pop        es
iret

EMS_FUNCTION_057h:
xchg       ax, bx
cmp        byte ptr cs:[_current_call_subfunction_value], 1
ja         func_24_bad_subfunction
push       es
push       ds
PUSHA_MACRO


do_func_24_00:

lodsw
xchg       ax, cx 
lodsw
cmp        ax, 010h  ; 0x100000 = 1 MB
ja         func_24_too_large
jb         func_24_size_ok
test       cx, cx
jne        func_24_too_large
func_24_size_ok:
xchg       ax, bp ; length to bp:cx

lodsb    ; extended or expanded
cmp        al, 1
ja         func_24_invalid_memtype
xchg       ax, bx ; bl gets this byte.
lodsw      
call       check_valid_handle 
jc         func_24_bad_handle
lodsw      ; initial offset
xchg       ax, si
lodsw      ; initial page
xchg       ax, dx


lodsb    ; extended or expanded
cmp        al, 1
ja         func_24_invalid_memtype
mov        bh, al
lodsw      
call       check_valid_handle 
jc         func_24_bad_handle
lodsw      ; dest offset
xchg       ax, di
lodsw      ; dest page


; dx, ax have source, dest segs
; si, di have source, dest offsets
; bp:cx is length
; bl, bh have source, dest mem types.

; todo: check params for accuracy BEFORE state push pop.
call       func_24_do_bounds_checks

call       func_24_set_up_segments

mov        dx, cx

; ds and es are now set up.
; bl/bh continue to maintain memory type bits.
; bp:dx now main 32 bit copy size..

; TODO: conventional bounds checks!

cmp   byte ptr cs:[_current_call_subfunction_value], 1
je    do_func_24_01    


; MAIN COPY LOOP: 
func_24_copy_more_memory:

   call       func_24_prep_copy_pointers ; does all the loop/copy setup
   mov        ax, cx  ; copy len
   MOVSW_MACRO

   call       func_24_check_repage ; does all the logical page repaging


   sub        dx, ax
   sbb        bp, cx ; known 0   

   mov        ax, dx
   or         ax, bp
   jnz        func_24_copy_more_memory

func_24_done:

call   func_24_clean_up_segments ; restore pagination if necessary

POPA_MACRO
pop    ds
pop    es
xor    ax, ax ; success
iret



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
do_func_24_01:

; MAIN EXCHANGE LOOP: 
func_24_exchange_more_memory:

   call       func_24_prep_copy_pointers ; does all the loop/exchange setup
   push       cx ; store len
   func_24_exchange_more_bytes:
   lodsb
   xchg       al, byte ptr es:[di]
   lock mov        byte ptr ds:[si-1], al
   inc        di
   loop       func_24_exchange_more_bytes
   pop        ax ; get length

   call       func_24_check_repage ; does all the logical page repaging



   sub        dx, ax
   sbb        bp, cx ; known 0   

   mov        ax, dx
   or         ax, bp
   jnz        func_24_copy_more_memory

jmp  func_24_done


; carry flag means bad handle
check_valid_handle:
 cmp       ax, 1
 jne       ret_bad_handle
 cmp       word ptr cs: [_RESIDENT_VARIABLE_handle_count+1], ax  ; known 1
 jae       ret_bad_handle  ; the one handle is unalloced..
 clc
 ret
 ret_bad_handle:
 stc
 ret

; ds:si and es:di get normalized such that si/di are is 000n
; bl/bh still carry copy types

func_24_prep_copy_pointers:
   ; ax/dx free

 test  bl, 1
 jne   func_24_skip_ds_si_noramlize
 mov   dx, ds
 mov   ax, si
 and   si, 0FFF0h
 SHIFT_MACRO shr ax 4
 sub   dx, ax
 mov   ds, dx

 func_24_skip_ds_si_noramlize:
 test  bh, 1
 jne   func_24_skip_es_di_noramlize
 mov   dx, es
 mov   ax, di
 and   di, 0FFF0h
 SHIFT_MACRO shr ax 4
 sub   dx, ax
 mov   es, dx
 func_24_skip_es_di_noramlize:


 ; segments/offsets were normalized if conventional.
 ; now calculate copy length for this iter.
 ;
 test  bx, bx
 jz    func_24_use_conventional_max
 mov   cx, 16384
 cmp   bx, 0100h  
 je    func_24_use_di_value
 ja    func_24_use_min_of_both
 func_24_use_si_value:
 sub   cx, si
 jmp   func_24_bounds_check
 func_24_use_di_value:
 sub   cx, di
 jmp   func_24_bounds_check
 func_24_use_min_of_both:
 mov   ax, cx
 sub   cx, si
 sub   ax, di
 cmp   cx, ax
 jbe   func_24_bounds_check
 xchg  ax, cx
 jmp   func_24_bounds_check


func_24_use_conventional_max:
 mov   cx, dx
 cmp   cx, 32768
 ja    func_24_cap_conventional_size
 mov   cx, 32768
func_24_cap_conventional_size:

func_24_bounds_check:
 cmp        cx, dx   ; is length smaller than bp:dx?
 jbe        func_24_ax_smaller_do_copy
 test       bp, bp
 jne        func_24_ax_smaller_do_copy
 mov        cx, dx
 func_24_ax_smaller_do_copy:

 ret

; ax gets MAX(16384-si, 16384-di)
func_24_prep_extended_copy_length:
 push  dx
 mov   ax, 16384
 mov   dx, ax
 sub   ax, si
 sub   dx, di
 cmp   ax, dx
 jbe   keep_this_ax
 xchg  ax, dx
 keep_this_ax:
 pop   dx
 ret

 test  bl, 1
 jne   skip_ds_si_noramlize
 mov   dx, ds
 mov   ax, si
 and   si, 0FFF0h
 SHIFT_MACRO shr ax 4
 sub   dx, ax
 mov   ds, dx

 skip_ds_si_noramlize:
 test  bh, 1
 jne   skip_es_di_noramlize
 mov   dx, es
 mov   ax, di
 and   di, 0FFF0h
 SHIFT_MACRO shr ax 4
 sub   dx, ax
 mov   es, dx

 skip_es_di_noramlize:
 pop   ax

 ret


; set up ds:es according to bl/bh memory types. prep extended pages if necessary
func_24_set_up_segments:
 test  bl, 1
 jne   func_24_prep_source_logical
 mov   ds, dx

 test  bh, 1
 jne   func_24_prep_dest_logical
 func_24_use_dest_conventional:
 mov   es, ax

 ret

func_24_prep_source_logical:
 push  ax   ; AAAA save ax (dest segment)
 mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_current_page], dx
 mov   ax, FUNC_24_SOURCE_PAGE_FRAME_INDEX
 call  UTIL_get_page
 mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_original_page], ax
 mov   ax, FUNC_24_SOURCE_PAGE_FRAME_INDEX
 call  UTIL_set_page
 mov   ds, word ptr cs:[mappable_phys_page_struct_page_frame+(4 * FUNC_24_SOURCE_PAGE_FRAME_INDEX)] ; page 3 segment
 pop   ax   ; AAAA restore ax (dest segment)
 test  bh, 1
 je    func_24_use_dest_conventional
 
func_24_prep_dest_logical:
 mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_current_page], ax
 push  ax
 mov   ax, FUNC_24_DEST_PAGE_FRAME_INDEX
 call  UTIL_get_page
 mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_original_page], ax
 pop   dx
 mov   ax, FUNC_24_DEST_PAGE_FRAME_INDEX
 call  UTIL_set_page
 mov   es, word ptr cs:[mappable_phys_page_struct_page_frame+(4 * FUNC_24_DEST_PAGE_FRAME_INDEX)] ; page 3 segment
 ret

func_24_clean_up_segments:
  test  bl, 1
  je    func_24_skip_source_cleanup
  mov   dx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_original_page]
  mov   ax, FUNC_24_SOURCE_PAGE_FRAME_INDEX
  call  UTIL_set_page
 func_24_skip_source_cleanup:
  test  bh, 1
  je    func_24_skip_dest_cleanup
  mov   dx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_original_page]
  mov   ax, FUNC_24_DEST_PAGE_FRAME_INDEX
  call  UTIL_set_page

 func_24_skip_dest_cleanup:
  ret

func_24_do_bounds_checks:
 ;TODO this

  test       bl, 1
  jne        func_24_skip_si_check
  cmp        si, 16384
  jae        func_24_offset_too_high
 func_24_skip_si_check:

  test       bh, 1
  jne        func_24_skip_di_check
  cmp        di, 16384
  jae        func_24_offset_too_high
 func_24_skip_di_check:
  ret

func_24_check_repage:
  test    bl, 1
  je      func_24_dont_repage_source
  cmp     si, 16384
  jbe     func_24_dont_repage_source
  push    dx
  push    ax
  inc     word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_current_page]
  mov     dx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_current_page]
  mov     ax, FUNC_24_SOURCE_PAGE_FRAME_INDEX
  call    UTIL_set_page
  pop     ax
  pop     dx
  xor     si, si
 func_24_dont_repage_source:
  test    bh, 1
  je      func_24_dont_repage_dest
  cmp     di, 16384
  jbe     func_24_dont_repage_dest
  push    dx
  push    ax
  inc     word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_current_page]
  mov     dx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_current_page]
  mov     ax, FUNC_24_DEST_PAGE_FRAME_INDEX
  call    UTIL_set_page
  pop     ax
  pop     dx
  xor     di, di
 func_24_dont_repage_dest:
  ret

func_24_offset_too_high:
  mov    ah, 095h   ; The offset within the logical page exceeds the length of the logical page.
  jmp    func_24_error


;          25 Get Mappable Physical Address Array            5800h     
;             Get Mappable Physical Address Array Entries    5801h     

;    mappable_phys_page_struct   STRUC
;             phys_page_segment        DW ?
;             phys_page_number         DW ?
;          mappable_phys_page_struct   ENDS

EMS_FUNCTION_058h:
xchg       ax, bx
cmp        byte ptr cs:[_current_call_subfunction_value], 1
jae        func_58_not_5801
EMS_FUNCTION_05800h:
push       ds
push       si
push       cs
pop        ds
mov        si, OFFSET mappable_phys_page_struct
_RESIDENT_VARIABLE_pageable_frame_count_2:
mov        cx, 01000h
rep        movsw
_RESIDENT_VARIABLE_pageable_frame_count_4:
mov        cx, 01000h
_RESIDENT_VARIABLE_pageable_frame_count_5:
sub        di, 01000h

; ah 0 from original xchg ah
pop        si
pop        ds
iret
func_58_not_5801:
ja         func_58_invalid_subfunction
EMS_FUNCTION_05801h:
_RESIDENT_VARIABLE_pageable_frame_count_3:
mov        cx, 01000h
; ah already 0.
iret
func_58_invalid_subfunction:
mov        ah, 08fh
iret



;          14 Get All Handle Pages                           4Dh       
; we write all handles and their page counts to es:di
EMS_FUNCTION_04Dh:
mov        ax, word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count+1]
xor        al, 1  ; 0 or 1 unallocated -> 1 or 1 allocated
xchg       ax, bx ; ah zero, bx gets  total_open_emm_handles
mov        ax, word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count+1]
mov        word ptr es:[di+2], ax ; pages_alloc_to_handle
jnz        wrote_all_handle_pages ; no handles allocated

neg        ax
add        ax, word ptr cs:[_RESIDENT_VARIABLE_total_EMS_page_count+1]
mov        word ptr es:[di+6], ax ; total pages - unallocated = allocated
mov        word ptr es:[di+4], 1

wrote_all_handle_pages:
xor        ax, ax
mov        word ptr es:[di], 0 ; emm_handle

inc bx ; (including the operating system handle [0]).  The number cannot be zero because the operating system handle is always active and

iret



;          8  Save Page Map                                  47h       

EMS_FUNCTION_047h:

IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE func08\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE func08\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE func08\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE func08\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE func08\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE func08\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE func08\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE func08\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE func08\neat.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE func08\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE func08\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE func08\standard.asm
ENDIF

 

;          9  Restore Page Map                               48h       

EMS_FUNCTION_048h:

IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE func09\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE func09\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE func09\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE func09\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE func09\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE func09\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE func09\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE func09\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE func09\neat.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE func09\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE func09\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE func09\standard.asm
ENDIF


;          15 Get Page Map                                   4E00h    
;             Set Page Map                                   4E01h     
;             Get & Set Page Map                             4E02h     
;             Get Size of Page Map Save Array                4E03h     
EMS_FUNCTION_04Eh:

IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE func15\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE func15\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE func15\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE func15\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE func15\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE func15\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE func15\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE func15\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE func15\neat.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE func15\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE func15\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE func15\standard.asm
ENDIF

; 16 Get Partial Page Map                           4F00h     
;             Set Partial Page Map                           4F01h     
;             Get Size of Partial Page Map Save Array        4F02h     
EMS_FUNCTION_04Fh:

IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE func16\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE func16\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE func16\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE func16\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE func16\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE func16\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE func16\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE func16\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE func16\neat.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE func16\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE func16\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE func16\standard.asm
ENDIF 



; didnt handle the subfuncton
EMS_FUNCTION_05001h:


IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE func17-1\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE func17-1\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE func17-1\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE func17-1\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE func17-1\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE func17-1\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE func17-1\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE func17-1\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE func17-1\neat.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE func17-1\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE func17-1\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE func17-1\standard.asm
ENDIF




; cross platform utility function for getting the (application facing) page index for a segment.

util_get_register_for_segment:
   push  si
   push  cx
   mov   si, OFFSET mappable_phys_page_struct

   check_next_segment_in_list:
   cmp   ax, word ptr cs:[si]
   je    found_page_in_list
   add   si, 4
   loop  check_next_segment_in_list

   ; fail... undefined behavior? or just store FFFF in there?

   found_page_in_list:
   mov   ax, word ptr cs:[si+2]
   pop   cx
   pop   si
   ret






IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE util\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE util\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE util\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE util\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE util\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE util\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE util\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE util\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE util\neat.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE util\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE util\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE util\standard.asm
ENDIF






;db 'SQEMM END'


;;; END RESIDENT EMS DRIVER SECTION
;;; END RESIDENT EMS DRIVER SECTION
;;; END RESIDENT EMS DRIVER SECTION


;;; BEGIN INIT CODE. This section is not resident after initialization
;;; BEGIN INIT CODE. This section is not resident after initialization
;;; BEGIN INIT CODE. This section is not resident after initialization
;;; BEGIN INIT CODE. This section is not resident after initialization






end_of_driver_label:
public end_of_driver_label


string_resident_driver_size                 db            "EMS Driver Resident Memory Usage: "
string_resident_driver_size_EDIT_OFFSET     db            "      Bytes, Entrypoint:  "
string_resident_driver_location_EDIT_OFFSET db            "0000:0000",'$'

string_driver_exists db 0Dh, 0Ah, 'EMS Driver already loaded (chaining not supported).',0Dh, 0Ah, '$'
string_driver_successfully_installed db 0Dh, 0Ah, 'SQEMM successfully initialized.', 0Ah, 0Dh, '$'
string_driver_failed_installing db 0Dh, 0Ah, ' Driver not installed.', 0Ah,  '$'
string_bad_page_frame_param db 0Dh, 0Ah,  'Bad Page Frame Param in Driver Parameters! SQEMM was not loaded.', 0Dh, 0Ah,'$'
string_bad_page_count_param db 0Dh, 0Ah,  'Bad Page Count Param in Driver Parameters! SQEMM was not loaded.', 0Dh, 0Ah,'$'
string_bad_page_offset_param db 0Dh, 0Ah, 'Bad Page Offset Param in Driver Parameters! SQEMM was not loaded.', 0Dh, 0Ah,'$'

string_parsed_parameter                     db            " (User Parameter)", 0Dh, 0Ah,'$'
string_unparsed_parameter                   db            " (Default Parameter)", 0Dh, 0Ah,'$'

string_good_port_param                      db            "Using Port:  "
string_good_port_param_EDIT_OFFSET          db            "0208",'$'
string_good_page_frame_param                db            "Page Frame:  "
string_good_page_frame_param_EDIT_OFFSET    db            "D000",'$'
string_good_page_count_param                db            "Page Count:  "
string_good_page_count_param_EDIT_OFFSET    db            "0256",'$'
string_good_page_offset_param               db            "Page Offset: "
string_good_page_offset_param_EDIT_OFFSET   db            "0128",'$'




IF COMPILE_CHIPSET EQ SCAMP_CHIPSET
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for VLSI SCAMP', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for Fantasy Card', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for Rodneys 286 Chipset', 0Dh, 0Ah,'$'
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
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
  string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for Standard EMS Boards', 0Dh, 0Ah,'$'
ENDIF

_INIT_PARAM_command_line_length:
dw 0
_INIT_PARAM_last_parsed_param:


DRIVER_INIT:
push       cs
pop        ds
; selfmodify to disable double init.
mov        byte ptr ds:[SELFMODIFY_prevent_double_init+1], OFFSET RETURN_UNRECOGNIZED_COMMAND - SELFMODIFY_prevent_double_init_AFTER     ; overwrite pointer to this init function with pointer to "failed to install" (03fa5h)
mov        dx, OFFSET string_main_header

mov        ah, 9  ; PRINT_STRING
int        021h

; get interrupt vector. check it's header/string
mov        ax, 03567h
int        021h
mov        di, 0Ah
mov        si, di
mov        cx, 8
rep        cmpsb
 
jne        EMS_INTERRUPT_FREE
; an ems driver is already installed

mov        dx, OFFSET string_driver_exists

DRIVER_NOT_INSTALLED:
mov        ah, 9  ; PRINT_STRING
int        021h

lds        bx, [request_header_pointer]
mov        word ptr ds:[bx + 3], 0810ch
mov        word ptr ds:[bx + 0eh], OFFSET end_of_driver_label
mov        word ptr ds:[bx + 010h], cs
;mov        word ptr ds:[bx + 017h], 00
ret

EMS_INTERRUPT_FREE:

;call  trigger_debugger

call  process_command_line
mov   ah, "Q" ; quiet mode?
call  parse_driver_params

jnc   quiet_mode_off


mov   byte ptr ds:[print_driver_param], RET_OPCODE

quiet_mode_off:




IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE init\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE init\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE init\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE init\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE init\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE init\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE init\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE init\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE init\neat.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE init\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE init\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE init\standard.asm
ENDIF


mov        al, byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1]
cbw
mov        word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_3+1], ax
mov        word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_4+1], ax
shl        ax, 1
mov        word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_5+2], ax
mov        word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_2+1], ax

; set page table to page frame.

mov        ax, word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1]
mov        word ptr ds:[mappable_phys_page_struct_page_frame+0], ax
add        ax, 0400h
mov        word ptr ds:[mappable_phys_page_struct_page_frame+4], ax
add        ax, 0400h
mov        word ptr ds:[mappable_phys_page_struct_page_frame+8], ax
add        ax, 0400h
mov        word ptr ds:[mappable_phys_page_struct_page_frame+12], ax

push       cs
pop        es
std
mov        ax, OFFSET end_of_driver_label
mov        bx, 10
mov        di, OFFSET string_resident_driver_size_EDIT_OFFSET + 3

print_next_size_digit:
  cwd
  div       bx
  xchg      ax, dx  ; get   remainder in ax
  add       al, '0' ; ASCIIfy
  stosb             ; print remainder from ax
  xchg      ax, dx  ; get   quotient back in ax
  test      ax, ax
  jnz       print_next_size_digit

cld

; hijack this to use do_print_driver_param_hex as function now
mov        byte ptr ds:[done_editing_string], RET_OPCODE

mov        ax, cs
mov        di, OFFSET string_resident_driver_location_EDIT_OFFSET

call       do_print_driver_param_hex
inc        di   ; skip colon
mov        ax, OFFSET MAIN_EMS_INTERRUPT_VECTOR
call       do_print_driver_param_hex

mov        dx, OFFSET string_resident_driver_size
mov        ah, 9  ; PRINT_STRING
int        021h





; one handle for now
mov        word ptr ds:[_RESIDENT_VARIABLE_handle_count+1], 01h

; set interrupt vector  067h
mov        dx, OFFSET MAIN_EMS_INTERRUPT_VECTOR
mov        ax, 02567h
int        021h

DRIVER_INSTALLED:

mov        dx, OFFSET string_driver_successfully_installed
mov        ah, 9  ; PRINT_STRING
int        021h

lds        bx, dword ptr ds:[request_header_pointer]
mov        word ptr es:[bx + 3], 0100h

; 0Eh: MS-DOS 5 set pointer to end of memory used by driver
; 10h: the segment for above
mov        word ptr ds:[bx + 0eh], OFFSET  end_of_driver_label
mov        word ptr ds:[bx + 010h], cs
;mov        word ptr ds:[bx + 017h], 00
ret



; idea was to capitalize, find end of command line
; turns out ms-dos pre-capitalizes it all? (what about other DOS?) consider removing. 
process_command_line:

push       ds
lds        si, dword ptr cs:[request_header_pointer]
lds        si, ds:[si + 012h]  ; todo whats this offset
xor        cx, cx

parse_next_character:
lodsb
cmp        al, 0Dh
je         done_processing_command_line
inc        cx

; capitalize character
cmp        al, 061h
jb         no_upper
cmp        al, 07Ah
ja         no_upper
sub        al, 020h
mov        byte ptr ds:[si-1], al
no_upper:

jmp        parse_next_character

done_processing_command_line:
mov        word ptr cs:[_INIT_PARAM_command_line_length], cx
pop        ds
ret


parse_driver_params:

; character to search for passed in ah
; search for "-X" where X is ah
; return pointer in es:di
; return found == true in carry flag.
push       cx

mov        cx, word ptr cs:[_INIT_PARAM_command_line_length] ; max param length
les        di, dword ptr cs:[request_header_pointer]
les        di, es:[di + 012h]  ; todo whats this offset

mov        al, "-"
mov        word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET string_unparsed_parameter ; default not found

search_for_next_param:
repne      scasb      
clc        ; return not found by default
jcxz       done_not_found
cmp        byte ptr es:[di], ah
jne        search_for_next_param
inc        di ; skip character
cmp        byte ptr es:[di], "="
jne        not_equals
inc        di
not_equals:
stc   ; carry on if found.
mov       word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET string_parsed_parameter
done_not_found:
pop        cx

ret

; pass in param in ah
; pass in default value on failure in dx.
; still returns carry on success

parse_driver_params_get_int:
push      dx
call      parse_driver_params
jnc       arg_parsed_fail
xor       ax, ax  ; zero ah
cwd               ; dx is running total
loop_next_char:
mov       al, byte ptr es:[di]
cmp       al, " "
je        arg_parsed_success
cmp       al, 0Dh ; end of line. do we also check for 0Ah? 
je        arg_parsed_success
sub       al, "0"
jb        arg_parsed_fail
cmp       al, 9
ja        arg_parsed_fail
push      ax     ; store value
mov       al, 10
mul       dx       ; shift running total one decimal digit over
xchg      ax, dx   ; result in dx
pop       ax     ; restore value
add       dx, ax ; add new digit
inc       di
jmp       loop_next_char

arg_parsed_fail:
clc
pop       ax
ret

arg_parsed_success:
stc
xchg      ax, dx
pop       dx  
ret

print_driver_param_4_char_int:
  mov      cx, 3
print_driver_param_int:
  clc

print_driver_param:

; ax = number to convert to edit offset
; ds:di = edit offset
; ds:dx = print offset (synergy with dos interrupt)
; carry flag on = print hex. off = print int.
; cx has number of digits for decimal print. hex always prints 4.
  push      bx
  push      ds
  pop       es  ; enable stosw
  jc        do_print_driver_param_hex

; put AX decimal value in es:di
  push      dx
  add       di, cx  ; cx has max digit count. iter backwards. 
  std               ; assume no dir flag coming in 
  
  mov       bx, 10

  do_next_digit:
  xor       dx, dx
  div       bx
  xchg      ax, dx  ; get   remainder in ax
  add       al, '0' ; ASCIIfy
  stosb             ; print remainder from ax
  xchg      ax, dx  ; get   quotient back in ax
  loop   do_next_digit
  clc
  pop       dx
  jmp   done_editing_string
do_print_driver_param_hex:

; thanks zero318 for original impl
; put AX hex value in es:di

  MOV  BX, AX
  AND  AX, 0F0Fh
  XOR  BX, AX
  SHIFT_MACRO SHR BX 4
  XCHG AL, BH
  CMP  AL, 10
  SBB  CL, CL
  CMP  AH, 10
  SBB  CH, CH
  AND  CX, (("0" XOR ("A" - 10)) AND 0FFh) OR (("0" XOR ("A" - 10)) SHL 8)
  XOR  CX, (("A" - 10) AND 0FFh) OR (("A" - 10) SHL 8)
  ADD  AX, CX
  STOSW
  CMP  BL, 10
  SBB  AL, AL
  CMP  BH, 10
  SBB  AH, AH
  AND  AX, (("0" XOR ("A" - 10)) AND 0FFh) OR (("0" XOR ("A" - 10)) SHL 8)
  XOR  AX, (("A" - 10) AND 0FFh) OR (("A" - 10) SHL 8)
  ADD  AX, BX
  STOSW
done_editing_string:
    
  mov        ah, 9  ; PRINT_STRING
  int        021h

  mov        dx, word ptr ds:[_INIT_PARAM_last_parsed_param]
  mov        ah, 9  ; PRINT_STRING
  int        021h
  pop        bx

  ret



;;; END GENERIC INIT CODE. This section is not resident after initialization
;;; END GENERIC INIT CODE. This section is not resident after initialization
;;; END GENERIC INIT CODE. This section is not resident after initialization
;;; END GENERIC INIT CODE. This section is not resident after initialization


;;; BEGIN CHIPSET SPECIFIC FUNCTION INIT DEFINITIONS. This section is not resident after initialization
;;; BEGIN CHIPSET SPECIFIC FUNCTION INIT DEFINITIONS. This section is not resident after initialization
;;; BEGIN CHIPSET SPECIFIC FUNCTION INIT DEFINITIONS. This section is not resident after initialization
;;; BEGIN CHIPSET SPECIFIC FUNCTION INIT DEFINITIONS. This section is not resident after initialization


IF COMPILE_CHIPSET EQ SCAT_CHIPSET
  scat_chipset_offset_lookup_table:
  dw  0,    64,  80,  96
  dw  128, 256, 384, 512
  dw  640, 768, 896,   0
  dw    0,   0,   0,   0


  ; 0000 No Boundary
  ; 0001 1MB
  ; 0010 1.25MB
  ; 0011 1.5MB
  ; 0100 2MB
  ; 0101 4MB
  ; 0110 6MB
  ; 0111 8MB
  ; 1000 10MB
  ; 1001 12MB
  ; 1010 14MB
  ; 1011 No Boundary
  ; 1100 No Boundary
  ; 1101 No Boundary
  ; 1110 No Boundary
  ; 1111 ???? (spec doesnt say)


  get_SCAT_chipset_bounds_value:

  mov   al, SCAT_EXTENDED_BOUNDARY_REGISTER   ; 
  out   SCAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in    al, SCAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and   ax, 15
  shl   ax, 1
  xchg  ax, bx
  mov   bx, word ptr ds:[scat_chipset_offset_lookup_table+bx]
  xchg  ax, bx


  ret

  scat_chipset_ems_plus_xms_table:

  dw   0,   0,   0,  24
  dw   0,  32,  64, 192
  dw  64, 192, 320, 448
  dw 576, 704, 832, 960


  ; 0000 0
  ; 0001 0
  ; 0010 0
  ; 0011 384kb
  ; 0100 0
  ; 0101 512kb
  ; 0110 1MB
  ; 0111 3MB
  ; 1000 1MB
  ; 1001 3MB
  ; 1010 5MB
  ; 1011 7MB
  ; 1100 9MB
  ; 1101 11MB
  ; 1110 13MB
  ; 1111 15MB

  get_SCAT_chipset_total_ems_xms_pages:

  mov   al, SCAT_DRAM_CONFIGURATION_REGISTER   ; 
  out   SCAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in    al, SCAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and   ax, 15
  shl   ax, 1
  xchg  ax, bx
  mov   bx, word ptr ds:[scat_chipset_ems_plus_xms_table+bx]
  xchg  ax, bx


  ret


  scat_chipset_total_memory_table:

  dw   0,  32,  40,  64
  dw  64,  96, 128, 256
  dw 128, 256, 384, 512
  dw 640, 768, 896, 1024


  ; 0000 0
  ; 0001 512k
  ; 0010 640k
  ; 0011 1MB
  ; 0100 1MB
  ; 0101 1.5MB
  ; 0110 2MB
  ; 0111 4MB
  ; 1000 2MB
  ; 1001 4MB
  ; 1010 6MB
  ; 1011 8MB
  ; 1100 10MB
  ; 1101 12MB
  ; 1110 14MB
  ; 1111 16MB

  get_SCAT_chipset_total_memory_pages:

  mov   al, SCAT_DRAM_CONFIGURATION_REGISTER   ; 
  out   SCAT_CHIPSET_CONFIG_REGISTER_SELECT, al
  in    al, SCAT_CHIPSET_CONFIG_REGISTER_READWRITE
  and   ax, 15
  shl   ax, 1
  xchg  ax, bx
  mov   bx, word ptr ds:[scat_chipset_total_memory_table+bx]
  xchg  ax, bx


  ret

ENDIF
IF COMPILE_CHIPSET EQ SCAMP_CHIPSET

  scamp_chipset_page_number_table:

  db 8, 9, 10, 11 ; c000
  db 0, 1,  2,  3 ; d000
  db 4, 5,  6,  7 ; e000
ENDIF

COMMENT @
trigger_debugger:
push       es
push       ax
mov        ax, 09000h
mov        es, ax
mov        word ptr es:[0000], ax
pop        ax
pop        es
ret
@



END