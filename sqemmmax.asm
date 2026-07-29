

IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE max/defs\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE max/defs\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE max/defs\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE max/defs\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE max/defs\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE max/defs\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE max/defs\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE max/defs\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE max/defs\neat.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_2MB_CHIPSET
   INCLUDE max/defs\neat2mb.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE max/defs\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE max/defs\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE max/defs\standard.asm
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
mov  word ptr cs:[_RESIDENT_VARIABLE_request_header_pointer], bx        
mov  word ptr cs:[_RESIDENT_VARIABLE_request_header_pointer+2], es        
retf 


EMS_DRIVER_CALL:
push  bx
push  ds

lds  bx, dword ptr cs:[_RESIDENT_VARIABLE_request_header_pointer]

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
   INCLUDE max/vars\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE max/vars\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE max/vars\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE max/vars\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE max/vars\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE max/vars\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE max/vars\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE max/vars\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE max/vars\neat.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_2MB_CHIPSET
   INCLUDE max/vars\neat2mb.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE max/vars\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE max/vars\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE max/vars\standard.asm
ENDIF

; for function 15/16 'push/pop' like operation.
mappable_phys_page_struct_END:
page_stack: 
LENGTH_OF_STACK = (OFFSET page_stack - mappable_phys_page_struct) SHR 1
REPT LENGTH_OF_STACK
  db 0
ENDM



ALIGN 2

_RESIDENT_VARIABLE_alternate_register_set_default:
 dw 0, 0

_RESIDENT_VARIABLE_current_alternate_register_set:
db -1

ALIGN 2

;  32-bit pointer to arguments to driver
_RESIDENT_VARIABLE_request_header_pointer dd 00000000h 
public _RESIDENT_VARIABLE_request_header_pointer









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
dw  OFFSET EMS_FUNCTION_059h
dw  OFFSET EMS_FUNCTION_05Ah
dw  OFFSET EMS_FUNCTION_05Bh
dw  OFFSET EMS_FUNCTION_05Ch
dw  OFFSET EMS_FUNCTION_05Dh


_current_call_subfunction_value:
dw  0


 
skip_func_5000h:
mov   ah, 0
iret
ALIGN 2

MAIN_EMS_INTERRUPT_VECTOR:

; inline the main function(s) here.

cmp      ax, 05000h
jne      NOT_FUNC_50h
jcxz     skip_func_5000h

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
   INCLUDE max/func17-0\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE max/func17-0\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE max/func17-0\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE max/func17-0\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE max/func17-0\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE max/func17-0\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE max/func17-0\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE max/func17-0\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE max/func17-0\neat.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_2MB_CHIPSET
   INCLUDE max/func17-0\neat2mb.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE max/func17-0\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE max/func17-0\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE max/func17-0\standard.asm
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



_RESIDENT_VARIABLE_pageable_frame_count_1:
  cmp        al, CHIPSET_PAGE_FRAME_COUNT
  jae        func_05_page_too_high

; get actual page bx for handle dx
push  bx
push  cx
mov   cx, bx
mov   bx, dx
SHIFT_MACRO shl bx 2  ;  SIZE HANDLE_INFO
cmp   word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_first_page], -1
je    func_05_handle_not_found
inc   cx
jz    func_05_skip_page_lookup
dec   cx
cmp   cx, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_num_pages]
ja    func_05_logical_page_too_high
mov   bx, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_first_page]

jcxz  func_05_done_looping
func_05_loop_next_page:
mov   bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
loop  func_05_loop_next_page
func_05_done_looping:
; bx is now ptr to the actual page...
sub   bx, OFFSET _RESIDENT_VARIABLE_page_list
shr   bx, 1  ; board physical page
; note: this number should be OFFSET BY THE CONVENTIONAL ETC offset!!

func_05_skip_page_lookup:

pop   cx


IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE max/func05\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE max/func05\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE max/func05\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE max/func05\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE max/func05\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE max/func05\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE max/func05\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE max/func05\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE max/func05\neat.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_2MB_CHIPSET
   INCLUDE max/func05\neat2mb.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE max/func05\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE max/func05\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE max/func05\standard.asm
ENDIF
func_05_handle_not_found:
pop        cx
pop        bx
mov        ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
iret

func_05_page_too_high:
mov        ah, 08Bh
iret
func_05_logical_page_too_high:
pop        cx
pop        bx
mov        ah, 08Bh
iret

  

; reserved, dont implement
EMS_FUNCTION_049h:
EMS_FUNCTION_04Ah:

EMS_FUNCTION_UNIMPLEMENTED:
; These functions will remain unimplemented for this version of the driver. fall thru

;          1  Get Status                                     40h      

EMS_FUNCTION_040h:
xchg       ax, bx
; ah is already 0 because bh was 0 from jump table lookup
pop        ax
xor        ah, ah
iret


NOT_FUNC_44h:

; CHIPSET SPECIFIC END

; no pushes, etc done yet!


; don't support oob function types
push       ax   ; gross, need to store al.
mov        byte ptr cs:[_current_call_subfunction_value], al
mov        al, ah
cmp        al, 05dh
ja         bad_function

; don't support calls below 040h
sub        al, 040h
jb         bad_function

; subtract 040h - things are now 040h indexed..

cbw
xchg       ax, bx
shl        bx, 1          
jmp        word ptr cs:[bx + offset _EMS_FUNCTION_POINTERTABLE] ; NOTE: ax has bx value! must be restored.


bad_function:
pop        ax
mov        ah, 084h ; The function code passed to the memory manager is not defined.
iret

; MAIN EMS FUNCTIONS BELOW

;          25 Get Mappable Physical Address Array            5800h     
;             Get Mappable Physical Address Array Entries    5801h     

;    mappable_phys_page_struct   STRUC
;             phys_page_segment        DW ?
;             phys_page_number         DW ?
;          mappable_phys_page_struct   ENDS

EMS_FUNCTION_058h:
xchg       ax, bx
pop        ax
cbw
cmp        al, 1
ja        func_25_invalid_subfunction
je        EMS_FUNCTION_05801h
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
EMS_FUNCTION_05801h:
_RESIDENT_VARIABLE_pageable_frame_count_3:
mov        cx, 01000h
; ah already 0.


iret

func_25_invalid_subfunction:
pop        ax
mov        ah, 08fh
iret

;   30 Enable OS/E Function Set                       5D00h     135
;             Disable OS/E Function Set               5D01h     138
;             Return OS/E Access Key                  5D02h     140

EMS_FUNCTION_05Dh:
xchg  ax, bx  ; ah 0
pop   ax  ; get subfunction in al
mov   ah, 0 ; default success

cmp   al, 2
ja    func_30_bad_subfunction
je    func_30_check_key


cmp   word ptr cs:[_RESIDENT_VARIABLE_access_key+0], DEFAULT_ACCESS_KEY_LOW
jne   func_30_check_key
cmp   word ptr cs:[_RESIDENT_VARIABLE_access_key+2], DEFAULT_ACCESS_KEY_HIGH
jne   func_30_check_key

func_30_generate_key:
mov   cx, 01234h  ; todo
mov   bx, 04321h  ; todo
mov   word ptr cs:[_RESIDENT_VARIABLE_access_key+0], bx
mov   word ptr cs:[_RESIDENT_VARIABLE_access_key+2], cx

func_30_check_key:
cmp   word ptr cs:[_RESIDENT_VARIABLE_access_key+0], bx
jne   func_3000_bad_access
cmp   word ptr cs:[_RESIDENT_VARIABLE_access_key+2], cx
jne   func_3000_bad_access
cmp   al, 2
je    do_func_30_02
mov   byte ptr cs:[_RESIDENT_VARIABLE_access_blocked], al ; 0 or 1 (or 2) based on subfunction.



iret
do_func_30_02:

mov   word ptr cs:[_RESIDENT_VARIABLE_access_key+0], DEFAULT_ACCESS_KEY_LOW
mov   word ptr cs:[_RESIDENT_VARIABLE_access_key+2], DEFAULT_ACCESS_KEY_HIGH

iret



func_30_return_key:
; return key if subfunction 0 or 1. (and also do whatever function 0/1 needed to be done)

mov   bx, word ptr cs:[_RESIDENT_VARIABLE_access_key+0]
mov   cx, word ptr cs:[_RESIDENT_VARIABLE_access_key+2]

; unsure if this is proper behavior...
mov   byte ptr cs:[_RESIDENT_VARIABLE_access_blocked], al ; 0 or 1 based on subfunction

iret

func_26_access_denied:
pop        ax
func_3000_bad_access:
func_3001_bad_access:
func_3002_bad_access:
mov   ah, 0A4h
iret

func_27_bad_subfunction:
xchg  ax, bx
func_26_bad_subfunction:
pop        ax
func_30_bad_subfunction:
func_19_bad_subfunction:
mov        ah, 08fh
iret


;           19 Get Handle Attribute                           5200h     62
;             Set Handle Attribute                           5201h     65
;             Get Handle Attribute Capability                5202h     67


EMS_FUNCTION_052h:
xchg       ax, bx
pop        ax

cmp        al, 2
jb         func_19_unsupported
ja         func_19_bad_subfunction
xor        ax, ax
iret

func_19_unsupported:
mov        ah, 091h ; This feature is not supported.
iret

;   27 Allocate Standard Pages                        5A00h     106
;      Allocate Raw Pages                             5A01h     109

EMS_FUNCTION_05Ah:

cmp  byte ptr cs:[_current_call_subfunction_value], 1
ja   func_27_bad_subfunction
jmp  allocate_pages_skip_zero_check 

;          2  Get Page Frame Segment Address                 41h       

EMS_FUNCTION_041h:
_RESIDENT_VARIABLE_page_frame_segment:
mov        ax, 0D000h  ; return in bx
xchg       ax, bx
; ah is already 0 because bh was 0 from jump table lookup
pop        ax
xor        ah, ah
iret

;          3  Get Unallocated Page Count                     42h       

EMS_FUNCTION_042h:
;      FUNCTION 3    GET UNALLOCATED PAGE COUNT
xchg       ax, bx ; zero ah
do_func_26_01:
mov        bx, word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count]
_RESIDENT_VARIABLE_total_EMS_page_count:
mov        dx, 01000h  ; return in dx
; ah is already 0 because bh was 0 from jump table lookup
pop        ax
xor        ah, ah
iret

;         26 Get Hardware Configuration Array               5900h     101
;            Get Unallocated Raw Page Count                 5901h     104

EMS_FUNCTION_059h:
xchg     ax, bx
cmp      byte ptr cs:[_RESIDENT_VARIABLE_access_blocked], ah  ; 0 
jne      func_26_access_denied

xor      ax, ax
cmp      byte ptr cs:[_current_call_subfunction_value], 1
ja       func_26_bad_subfunction
je       do_func_26_01
do_func_26_00:
mov      word ptr es:[di], 0400h   ; 16kb page size
mov      word ptr es:[di+2], MAX_CONTEXT_COUNT    ; 0 alternate mapping sets
mov      word ptr es:[di+4], LENGTH_OF_STACK
mov      word ptr es:[di+6], ax    ; 0 dma mapping sets
mov      word ptr es:[di+8], ax    ; 0 dma set behaivor
pop        ax
xor        ah, ah
iret

 



;          4  Allocate Pages                                 43h      
;           BX = num_of_pages_to_alloc

EMS_FUNCTION_043h:

; ax has bx value..

test       ax, ax
jz         func_04_alloc_pages_0_error
allocate_pages_skip_zero_check:

cmp        ax, word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count]
ja         func_04_allocated_too_many_pages
cmp        ax, word ptr cs:[_RESIDENT_VARIABLE_total_EMS_page_count+1]
ja         func_04_allocated_too_many_pages_above_total



call       COMMON_get_next_free_handle
test       dx, dx
js         func_04_no_handles_Left

inc        word ptr cs:[_RESIDENT_VARIABLE_handle_count]
mov        bx, dx
push       ax
SHIFT_MACRO shl bx 3
add        bx, OFFSET _RESIDENT_VARIABLE_handlename_list
xor        ax, ax
mov        word ptr cs:[bx], ax    ; zero handle name
mov        word ptr cs:[bx+2], ax 
mov        word ptr cs:[bx+4], ax
mov        word ptr cs:[bx+6], ax

; ax still has num pages to allocate..
pop        ax 
mov        bx, ax  ; restore bx

call       COMMON_allocate_pages




pop        ax
xor        ah, ah
iret



func_04_no_handles_Left:

xchg       ax, bx
cwd        ; dx = 0
pop        ax
mov        ah, 085h  ; All EMM handles are being used.
iret
func_04_allocated_too_many_pages_above_total:
xchg       ax, bx
cwd        ; dx = 0
pop        ax
mov        ah, 087h  ; There aren't enough expanded memory pages present in the system to satisfy your program's request.
iret
func_04_alloc_pages_0_error:
xchg       ax, bx

pop        ax
mov        ah, 089h  ; Your program attempted to allocate zero pages.
iret
func_04_allocated_too_many_pages:
xchg       ax, bx
cwd        ; dx = 0
pop        ax
mov        ah, 087h  ; There aren't enough expanded memory pages present in the system to satisfy your program's request.
iret







;         6  Deallocate Pages                               45h       

EMS_FUNCTION_045h:
public EMS_FUNCTION_045h
xchg       ax, bx  ; put bx back
test       dx, dx
je         func_06_no_emm_handle_found_skip_pop_bx ; zero handle illegal
push       bx
mov        bx, dx ; handle
SHIFT_MACRO shl bx 2
cmp        word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_num_pages], -1

je         func_06_no_emm_handle_found
shl        bx, 1
cmp        word ptr cs:[_RESIDENT_VARIABLE_handle_page_stack + bx], -1
jne        func_06_stack_exists
add        bx, OFFSET _RESIDENT_VARIABLE_handlename_list
xor        ax, ax
mov        word ptr cs:[bx], ax   ; zero handle name
mov        word ptr cs:[bx+2], ax
mov        word ptr cs:[bx+4], ax
mov        word ptr cs:[bx+6], ax

pop        bx

call       COMMON_deallocate_pages

dec        word ptr cs:[_RESIDENT_VARIABLE_handle_count]  ; handle freed, increment handle count

pop        ax
xor        ah, ah
iret

func_06_stack_exists:
pop        bx
pop        ax
mov        ah, 086h  ; The memory manager detected a save or restore  page mapping context error (Function 8 or 9).
iret

func_06_no_emm_handle_found:
pop        bx
func_06_no_emm_handle_found_skip_pop_bx:
pop        ax
mov        ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
iret

func_13_no_emm_handle_found:
xchg       ax, bx  ; restore bx

pop        ax
mov        ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
iret

;          7  Get Version                                    46h       

EMS_FUNCTION_046h:
; Get Version, return 4.0
xchg       ax, bx
pop        ax
mov        ax, 040h ; ah already 0
iret 




;          12 Get Handle Count                               4Bh       

EMS_FUNCTION_04Bh:
xchg       ax, bx ; ah 0
db  0BBh
_RESIDENT_VARIABLE_handle_count:
db  1, 0  ; mov        bx, 00001
pop        ax
xor        ah, ah
iret





;          13 Get Handle Pages                               4Ch       

EMS_FUNCTION_04Ch:

; ax has bx...
mov        bx, dx ; handle
SHIFT_MACRO shl bx 2
mov        bx, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_num_pages]
cmp        bx, -1
je         func_13_no_emm_handle_found
pop        ax
xor        ah, ah

iret







;          8  Save Page Map                                  47h       

EMS_FUNCTION_047h:


; consider a small fixed size to save these..

  xchg ax, bx ; restore bx

  test dx, dx
  jz   func_08_bad_handle
  mov  ax, dx
  call COMMON_check_valid_handle
  jc   func_08_bad_handle

  push  bx
  xchg ax, bx
  SHIFT_MACRO shl bx 3  ; 8 bytes per handle 
  add  bx, OFFSET _RESIDENT_VARIABLE_handle_page_stack


  xor  ax, ax ; page 0

  cmp  word ptr cs:[bx], -1  ; check one is enough.
  jne  func_08_already_exists

  call UTIL_get_page
  mov  word ptr cs:[bx], ax

  mov  ax, 1
  call UTIL_get_page
  mov  word ptr cs:[bx+2], ax

  mov  ax, 2
  call UTIL_get_page
  mov  word ptr cs:[bx+4], ax

  mov  ax, 3
  call UTIL_get_page
  mov  word ptr cs:[bx+6], ax

  pop  bx



pop        ax
xor        ah, ah
iret

func_08_already_exists:
pop   bx
pop        ax
mov   ah,  08Dh ; The save area already contains the page mapping register state for the EMM handle your program specified.
iret 

func_08_bad_handle:
func_09_bad_handle:
pop        ax
mov   ah, 083h
iret

func_09_doesnt_exist:
pop   si
pop        ax
mov   ah,  08Eh ;  There is no page mapping register state in the save area for the specified EMM handle. 
iret



;          9  Restore Page Map                               48h       

EMS_FUNCTION_048h:


; consider a small fixed size to save these..

  xchg ax, bx ; restore bx

  test dx, dx
  jz   func_09_bad_handle
  
  mov  ax, dx
  call COMMON_check_valid_handle
  jc   func_09_bad_handle

  push  si
  xchg  ax, si
  SHIFT_MACRO shl si 3  ; 8 bytes per handle 
  add  si, OFFSET _RESIDENT_VARIABLE_handle_page_stack




  lods word ptr cs:[si]
  inc  ax
  jz   func_09_doesnt_exist ; -1 check
  dec  ax
  
  push  dx

  xor  dx, dx
  mov  word ptr cs:[si-2], -1  ; mark this one zero and we're good.
  xchg ax, dx
  call UTIL_set_page

  mov  dx, 1
  lods word ptr cs:[si]
  xchg ax, dx
  call UTIL_set_page

  mov  dx, 2
  lods word ptr cs:[si]
  xchg ax, dx
  call UTIL_set_page

  mov  dx, 3
  lods word ptr cs:[si]
  xchg ax, dx
  call UTIL_set_page

  pop  dx
  pop  si

pop        ax
xor        ah, ah

iret



func_18_no_emm_handle_found_popbx:
mov     bx, cx
pop     cx
func_18_no_emm_handle_found:
pop        ax
mov     ah, 083h  ; The memory manager couldn't find the EMM handle your program specified.
iret


;          18 Reallocate Pages                               51h       
; DX = handle
;BX = reallocation_count                     
EMS_FUNCTION_051h:

xchg       ax, bx ; todo juggle less


test  dx, dx
jne   func_18_done_with_os_hanlde_stuff ; zero handle illegal
func_18_handle_os_handle:
mov   ax, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_num_pages]
cmp   bx, DEFAULT_CONVENTIONAL_PAGE_COUNT
jb    func_18_done_with_os_hanlde_stuff
mov   bx, DEFAULT_CONVENTIONAL_PAGE_COUNT  ; deallocating OS pages below minimum not allowed. (for now.)

func_18_done_with_os_hanlde_stuff:
push  cx
mov   cx, bx ; reallocation count
mov   bx, dx ; handle
SHIFT_MACRO shl bx 2

mov   ax, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_num_pages]
cmp   ax, -1
je    func_18_no_emm_handle_found_popbx
cmp   ax, cx
je    func_18_done_reallocating_equal_pages
jcxz  func_18_set_0_page_case
cmp   cx, word ptr cs:[_RESIDENT_VARIABLE_total_EMS_page_count+1]
ja    func_18_allocated_too_many_pages_above_total
add   ax, word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count]
cmp   cx, ax
ja    func_18_allocated_too_many_pages_above_available
mov   ax, cx
xchg  ax, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_num_pages]    ; new num pages.
add   word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count], ax
sub   word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count], cx
mov   ax, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_first_page]  ; bx is page 0.

; bx may be a bad pointer to start; 
push  cx  ; numpages to pop into bx
push  dx
xor   dx, dx  ; keep track of overallocation.

test  ax, ax
jne   loop_func_18_add_page
inc   dx
mov   ax, word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_head]  ; allocate from head.
mov   word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_first_page], ax
loop_func_18_add_page:
cmp   ax, -1
jne   func_18_loop_good_page
func_18_get_page_head_first:
mov   ax, word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_head]  ; allocate from head.
mov   word ptr cs:[bx + PAGE_INFO.page_info_next_page], ax
inc   dx  ; flag that we allocated new pages
func_18_loop_good_page:

xchg  ax, bx ; bx gets next page.
mov   ax, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
loop  loop_func_18_add_page

; we have reallocated. possble cleanup:
; 1. need to FF end of realloc'd list.
; AND
; 2a. allocs grew, need to rehead free alloc. (easy)
; OR
; 2b. allocs shrunk. need to free unalloced page chunk. (hard, need to find old end)

; 1:
dec   cx ; -1
mov  word ptr cs:[bx + PAGE_INFO.page_info_next_page], cx   ; last page points to -1. 
mov   bx, ax
; ax goes into here in either case for step 2a or 2b
xchg   ax, word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_head]  ; 2A is done

;1:
dec   dx
pop   dx
jz    func_18_clean_up_and_return_success
; 2b

func_18_add_pages_back_to_free:
; ax has new first page


loop_func_18_addback_page:

cmp   word ptr cs:[bx + PAGE_INFO.page_info_next_page], cx    ; -1 check
je    func_18_found_new_end_page
mov   bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
jmp  loop_func_18_addback_page
func_18_found_new_end_page:
mov   word ptr cs:[bx + PAGE_INFO.page_info_next_page], ax  ; old free head.




func_18_clean_up_and_return_success:

pop   bx ; numpages
func_18_clean_up_and_return_success_no_popbx:
pop   cx ; original cx

pop        ax
xor        ah, ah
iret

func_18_allocated_too_many_pages_above_total:
mov        ah, 087h  ; There aren't enough expanded memory pages present in the system to satisfy your program's request.
func_18_done_reallocating_equal_pages:
mov        bx, cx
pop        cx
pop        ax
xor        ah, ah
iret
func_18_allocated_too_many_pages_above_available:
mov        bx, cx
pop        cx
pop        ax
mov        ah, 088h  ; The number of unallocated pages is insufficient for the new allocation request. 
iret

func_18_set_0_page_case:

; todo remove all pages and set a null first page.
push  cx        ; zero to pop into numpages/bx later.

mov   word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_num_pages], cx  ; zero
add   word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count], ax ; was num pages...

mov   ax, cx ; known zero.
dec   cx ; -1

xchg  word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_first_page], ax; zero
mov   bx, ax
xchg  word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_head], ax

; ax has old free head.

jmp   func_18_add_pages_back_to_free




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
func_23_bad_handle:
pop   ax
mov   ah, 083h
iret 
func_23_error_bad_page:
POPA_MACRO
pop   ds
pop   ax
mov   ah, 08Ah
iret

func_23_bad_subfunction:
mov   ah, 08Fh  ;  The subfunction parameter is invalid.
iret

ALIGN 2

do_func_23_02:
mov   bx, 030h   ; probably ok... we use 32-34 bytes (decimal) at worst?
iret

EMS_FUNCTION_056h:
xchg  ax, bx ; restore bx
pop   ax  ; get subfunction back.

xor   ah, ah
cmp   al, 2 
ja    func_23_bad_subfunction
je    do_func_23_02
push  ax
xchg  ax, dx ; ax gets handle
call  COMMON_check_valid_handle
xchg  ax, dx ; handle back in dx
jc    func_23_bad_handle

; save registers.
push  ds

PUSHA_MACRO

xor   cx, cx
mov   cl, byte ptr ds:[si + 4]
jcxz  func_21_skip_first_remap
lds   si, dword ptr ds:[si + 5]
mov   ah, 050h
int   067h
func_21_skip_first_remap:
POPA_MACRO ; ax restored.

pop   ds


; push it all in case func wrecks it. CURRENTLY only AX ons tack.
push  es
push  di
push  bp
push  dx
push  cx
push  bx

push  ds
push  si

push  dx  ; handle
push  word ptr ds:[si + 10] ; todo what ; offset
push  word ptr ds:[si + 12] ; todo what ; segment
push  word ptr ds:[si + 9] ; todo what  ; count
push  ax
push  ax
xchg  ax, si
mov   si, sp
push  word ptr ss:[si+34] ; gross but ok. we need flags in the call target.
popf
xchg  ax, si
pop   ax
; mov   ah, 056h ; todo not sure if this gets 0 or 56.


call  dword ptr ds:[si]  


pop   ax
pop   cx  ; count
xor   ch, ch
pop   ds  ; segment
pop   si  ; offset
pop   dx  ; handle

jcxz  func_21_skip_old_repage

mov   ah, 050h
int   067h






func_21_skip_old_repage:

pop   si
pop   ds

pop   bx
pop   cx
pop   dx
pop   bp

pop   di

pop   es
pop   ax ; ah already zero

iret 


;      22 Alter Page Map & Jump
;             (Physical page number mode)                    5500h     
;             Alter Page Map & Jump
;             (Segment address mode)                         5501h     
func_22_bad_handle:
mov   ah, 083h
iret 

EMS_FUNCTION_055h:


xchg  ax, bx

pop   ax
; if al = 0, then func 22. if al = 1, then func 23.
cmp   al, 1
ja    func_22_bad_subfunction

xchg  ax, dx ; ax gets handle
call  COMMON_check_valid_handle
xchg  ax, dx ; ax gets handle
jc    func_22_bad_handle


push  ds
PUSHA_MACRO

xor   cx, cx
mov   cl, byte ptr ds:[si + 4]
lds   si, dword ptr ds:[si + 5]
mov   ah, 050h
int   067h
POPA_MACRO ; ax restored.
pop   ds
add   sp, 4
xor   ah, ah
popf  ; restore flags, sp reset.

jmp   dword ptr ds:[si]  ; far return will iret.


 


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
_RESIDENT_VARIABLE_FUNC_24_source_handle:
dw 0
_RESIDENT_VARIABLE_FUNC_24_dest_handle:
dw 0
_RESIDENT_VARIABLE_FUNC_24_overlap_detected_do_backwards:
db 0

; The function code passed to the memory manager is not defined.
func_24_bad_subfunction:
func_22_bad_subfunction:
mov        ah, 08Fh  ;  The subfunction parameter is invalid.
iret
func_24_bad_handle:

mov        ah, 083h   ; The manager couldn't find either the source or destination EMM handles.
jmp        func_24_error
func_24_unowned_memory:
; TODO catch

mov        ah, 08Ah   ; One or more of the logical pages is out of the range of logical pages allocated to the source/destination handle.
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
; gross

mov        al, byte ptr cs:[_current_call_subfunction_value]
iret

EMS_FUNCTION_057h:
xchg       ax, bx
pop        ax
cmp        al, 1
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
jb         func_24_skip_handle_check_source   ; not extended memory
call       COMMON_check_valid_handle 
jc         func_24_bad_handle
SHIFT_MACRO shl ax 2
mov        word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_handle], ax
func_24_skip_handle_check_source:
lodsw      ; initial offset
xchg       ax, di  ; goes into si later
lodsw      ; initial page
mov        word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_logical_page+1], ax
xchg       ax, dx


lodsb    ; extended or expanded
cmp        al, 1
ja         func_24_invalid_memtype
mov        bh, al
lodsw      
jb         func_24_skip_handle_check_dest   ; not extended memory
call       COMMON_check_valid_handle 
jc         func_24_bad_handle
SHIFT_MACRO shl ax 2
mov        word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_handle], ax
func_24_skip_handle_check_dest:
lodsw      ; dest offset
mov        si, word ptr ds:[si] ; dest page
xchg       ax, di
xchg       ax, si
mov        word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_logical_page+1], ax



; dx, ax have source, dest segs
; si, di have source, dest offsets
; bp:cx is length
; bl, bh have source, dest mem types.

; check params for accuracy BEFORE state push pop.
call       func_24_do_bounds_checks
call       func_24_set_up_segments
call       func_24_do_overlap_check
call       func_24_check_conventional_wraparound
mov        byte ptr cs:[_RESIDENT_VARIABLE_FUNC_24_overlap_detected+1], al
mov        dx, cx

; ds and es are now set up.
; bl/bh continue to maintain memory type bits.
; bp:dx now main 32 bit copy size..




cmp   byte ptr cs:[_current_call_subfunction_value], ah  ; 0
jne   do_func_24_01    


; MAIN COPY LOOP: 

test  al, al
jnz   func_24_copy_memory_backwards
func_24_copy_forward_after_all:
func_24_copy_more_memory:


   call       func_24_prep_copy_pointers ; does all the loop/copy setup
   ; note: bp:dx comes out of the above holding 32 bit count.
   ; cx comes out with the current copy amount.
   mov        ax, cx  ; copy len
   ;MOVSW_MACRO
   rep        movsb

   sub        dx, ax
   sbb        bp, cx ; known 0      

   mov        ax, dx
   or         ax, bp
   jz         func_24_done

   call       func_24_check_repage ; does all the logical page repaging

   jmp        func_24_copy_more_memory


func_24_done:

call   func_24_clean_up_segments ; restore pagination if necessary

POPA_MACRO ; ax restored
pop    ds
pop    es

_RESIDENT_VARIABLE_FUNC_24_overlap_detected:
mov    ah, 0  ; 0, 92h, 97h
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
   test al, al
   je   func_24_exchange_more_memory  ; no overlap detected
   mov  byte ptr cs:[_RESIDENT_VARIABLE_FUNC_24_overlap_detected+1], 097h
   jmp  func_24_done
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

   sub        dx, ax
   sbb        bp, cx ; known 0   





   mov        ax, dx
   or         ax, bp
   jz         func_24_done
   call       func_24_check_repage ; does all the logical page repaging


   jmp  func_24_exchange_more_memory

func_24_copy_memory_backwards:

; gross.
; source to end.

cmp  byte ptr cs:[_RESIDENT_VARIABLE_FUNC_24_overlap_detected_do_backwards], ah
je   func_24_copy_forward_after_all

test bl, bl
jnz  func_24_setup_source_segment_backwards

mov ax, ds
SHIFT_MACRO rol ax 4
mov cx, ax
and ax, 0Fh
and cx, 0FFF0h
add si, cx
adc ax, 0  
add si, dx
adc ax, bp
sub  si, 1
sbb  ax, 0

SHIFT_MACRO ror ax 4
mov ds, ax  ; ds:si modified.

jmp func_24_done_with_backwards_source_segment
func_24_setup_source_segment_backwards:

; figure out how many EMS pages.
xor  cx, cx
mov  ax, dx
dec  ax   ; sub 1 offset for backwards copy 
add  ax, si
adc  cx, bp
mov  si, ax
and  si, 16383
;cx:ax 
shl  ax, 1
rcl  cx, 1
shl  ax, 1
rcl  cx, 1

; cx has num ems pages to go forward...
jcxz skip_backwards_repage_source
push bx

mov  bx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_current_page]
func_24_loop_setup_last_page_first_source:
  mov   bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
  loop  func_24_loop_setup_last_page_first_source

mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_current_page], bx

xchg  bx, dx
sub   dx, OFFSET _RESIDENT_VARIABLE_page_list
shr   dx, 1

mov   ax, FUNC_24_SOURCE_PAGE_FRAME_INDEX
call  UTIL_set_page
mov   dx, bx

pop  bx
skip_backwards_repage_source:

func_24_done_with_backwards_source_segment:
test bh, bh
jnz  func_24_setup_dest_segment_backwards


mov ax, es
SHIFT_MACRO rol ax 4
mov cx, ax
and ax, 0Fh
and cx, 0FFF0h
add di, cx
adc ax, 0  
sub  di, 1
sbb  ax, 0

add di, dx
adc ax, bp
SHIFT_MACRO ror ax 4
mov es, ax  ; es:di modified.
jmp func_24_done_with_backwards_dest_segment
func_24_setup_dest_segment_backwards:

xor  cx, cx
mov  ax, dx
dec  ax   ; sub 1 offset for backwards copy 
add  ax, di
adc  cx, bp
mov  di, ax
and  di, 16383
;cx:ax 
shl  ax, 1
rcl  cx, 1
shl  ax, 1
rcl  cx, 1

; cx has num ems pages to go forward...
jcxz skip_backwards_repage_dest
push bx

mov  bx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_current_page]
func_24_loop_setup_last_page_first_dest:
  mov   bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
  loop  func_24_loop_setup_last_page_first_dest

mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_current_page], bx

xchg  bx, dx
sub   dx, OFFSET _RESIDENT_VARIABLE_page_list
shr   dx, 1

mov   ax, FUNC_24_DEST_PAGE_FRAME_INDEX
call  UTIL_set_page
mov   dx, bx

pop  bx
skip_backwards_repage_dest:

func_24_done_with_backwards_dest_segment:

std

func_24_copy_more_memory_backwards:


   call       func_24_prep_copy_pointers_backwards ; does all the loop/copy setup
   ; note: bp:dx comes out of the above holding 32 bit count.
   ; cx comes out with the current copy amount.
   mov        ax, cx  ; copy len
   rep        movsb

   sub        dx, ax
   sbb        bp, cx ; known 0      

   mov        ax, dx
   or         ax, bp
   jz         jump_to_func_24_done

   jmp        func_24_copy_more_memory_backwards

jump_to_func_24_done:
   jmp func_24_done

; ds:si and es:di get normalized such that si/di are is 000n
; bl/bh still carry copy types

func_24_prep_copy_pointers:   ; return copy amount in cx
   ; ax/cx free
   ; now bp:dx carries count...

 test  bl, bl
 jnz   func_24_skip_ds_si_noramlize
 mov   cx, ds
 mov   ax, si
 SHIFT_MACRO shr ax 4
 and   si, 0000Fh
 add   ax, cx
 mov   ds, ax

 func_24_skip_ds_si_noramlize:
 test  bh, bh
 jnz   func_24_skip_es_di_noramlize
 mov   cx, es
 mov   ax, di
 SHIFT_MACRO shr ax 4
 and   di, 0000Fh
 add   ax, cx
 mov   es, ax
 func_24_skip_es_di_noramlize:


 ; segments/offsets were normalized if conventional.
 ; now calculate copy length for this iter.
 ;
 ; bp:dx still count

 test  bx, bx
 jz    func_24_use_conventional_max
 
 mov   cx, 16384
 cmp   bx, 0100h  
 je    func_24_use_di_value    ; only dest is extended
 ja    func_24_use_min_of_both ; both are extended
 func_24_use_si_value:         ; only source is extended
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
 jb    func_24_skip_cap_conventional_size
func_24_do_max_after_all:
 mov   cx, 32768
func_24_skip_cap_conventional_size:
 jcxz  func_24_do_max_after_all   ; bp must be nonzero?

func_24_bounds_check:
 ; dx has original count.
 cmp        cx, dx   ; is length smaller than bp:dx?
 jbe        func_24_ax_smaller_do_copy
 test       bp, bp
 jne        func_24_ax_smaller_do_copy
 mov        cx, dx
 func_24_ax_smaller_do_copy:

 ret

func_24_prep_copy_pointers_backwards:   ; return copy amount in cx
   ; ax/cx free
   ; now bp:dx carries count...

 test  bl, bl
 jnz   func_24_skip_backwards_normalize_conventional_si
 ; we want ds:FFFx
 mov   ax, si
 or    ax, 0FFF0h ; create FFFn
 mov   cx, ax  ; copy
 sub   cx, si  ; get offset difference
 xchg  ax, si  ; si gets the new offset

 SHIFT_MACRO shr cx 4
 mov   ax, ds
 sub   ax, cx
 jnc   func_24_backwards_dssi_pointer_good
 neg   ax   ; ds underflowed, add back to si
 SHIFT_MACRO shl ax 4
 add   si, ax
 xor   ax, ax
 func_24_backwards_dssi_pointer_good:   
 mov   ds, ax  ; new ds:si set


func_24_skip_backwards_normalize_conventional_si:
 test  bh, bh
 jnz   func_24_skip_backwards_normalize_conventional_di
 
 ; and es:FFFx
 mov   ax, di
 or    ax, 0FFF0h ; create FFFn
 mov   cx, ax  ; copy
 sub   cx, di  ; get offset difference
 xchg  ax, di  ; di gets the new offset

 SHIFT_MACRO shr cx 4
 mov   ax, es
 sub   ax, cx

 jnc   func_24_backwards_esdi_pointer_good
 neg   ax   ; ds underflowed, add back to si
 SHIFT_MACRO shl ax 4
 add   di, ax
 xor   ax, ax
 func_24_backwards_esdi_pointer_good:   

 mov   es, ax  ; new es:di set


 func_24_skip_backwards_normalize_conventional_di:
 ; conventional adjustsments done. now check extened
 test  bl, bl
 jz    func_24_skip_backwards_normalize_exteneded_si
 inc   si
 jnz   func_24_skip_backwards_normalize_exteneded_si_dec_si
 
 ; backwards page
  mov   cx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_current_page]
  mov   si, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_handle]
  mov   si, word ptr cs:[_RESIDENT_VARIABLE_handle_list + si + HANDLE_INFO.handle_first_page]

  try_next_page_backwards_loop_source:
    cmp   cx, word ptr cs:[si + PAGE_INFO.page_info_next_page]
    je    found_page_backwards_source
    mov   si, word ptr cs:[si + PAGE_INFO.page_info_next_page]
    jmp   try_next_page_backwards_loop_source

  found_page_backwards_source:
  
  push  dx
  push  ax
  mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_current_page], si
  mov   dx, si
  sub   dx, OFFSET _RESIDENT_VARIABLE_page_list
  shr   dx, 1
  mov   ax, FUNC_24_SOURCE_PAGE_FRAME_INDEX
  call  UTIL_set_page
  pop   ax
  pop   dx
  mov   si, 16384 ; dec later, overshoot offset by 1

 func_24_skip_backwards_normalize_exteneded_si_dec_si:
 dec   si
 func_24_skip_backwards_normalize_exteneded_si:
 test  bh, bh
 jz    func_24_skip_backwards_normalize_exteneded_di
 inc   di
 jnz   func_24_skip_backwards_normalize_exteneded_di_dec_di

 ; backwards page
  mov   cx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_current_page]
  mov   di, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_handle]
  mov   di, word ptr cs:[_RESIDENT_VARIABLE_handle_list + di + HANDLE_INFO.handle_first_page]

  try_next_page_backwards_loop_dest:
    cmp   cx, word ptr cs:[di + PAGE_INFO.page_info_next_page]
    je    found_page_backwards_dest
    mov   di, word ptr cs:[di + PAGE_INFO.page_info_next_page]
    jmp   try_next_page_backwards_loop_dest

  found_page_backwards_dest:
  
  push  dx
  push  ax
  mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_current_page], di
  mov   dx, di
  sub   dx, OFFSET _RESIDENT_VARIABLE_page_list
  shr   dx, 1
  mov   ax, FUNC_24_DEST_PAGE_FRAME_INDEX
  call  UTIL_set_page
  pop   ax
  pop   dx

 mov    di, 16384 ; dec later, overshoot offset by 1

func_24_skip_backwards_normalize_exteneded_di_dec_di:
 dec    di
func_24_skip_backwards_normalize_exteneded_di:

; now ds:si and es:di are set. figure out cx.
 mov   cx, 0FFFEh

 cmp   cx, si
 jb    func_24_backwards_dont_cap_to_si
 mov   cx, si
 func_24_backwards_dont_cap_to_si:
 cmp   cx, di
 jb    func_24_backwards_dont_cap_to_di
 mov   cx, di
 func_24_backwards_dont_cap_to_di:

 inc cx ; plus one for backwards copy offset.



; compare to count
func_24_bounds_check_backwards:
 ; dx has original count.
 cmp        cx, dx   ; is length smaller than bp:dx?
 jbe        func_24_ax_smaller_do_copy_backwards
 test       bp, bp
 jne        func_24_ax_smaller_do_copy_backwards
 mov        cx, dx
 func_24_ax_smaller_do_copy_backwards:





 ret


; set up ds:es according to bl/bh memory types. prep extended pages if necessary
func_24_set_up_segments:
 test  bl, bl
 jnz   func_24_prep_source_logical
 mov   ds, dx

 test  bh, bh
 jnz   func_24_prep_dest_logical
 func_24_use_dest_conventional:
 mov   es, ax

 ret

func_24_prep_source_logical:
 push  ax   ; AAAA save ax

 ; look up logical page 
 push  bx
 mov   bx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_handle] ; preshifted 2
 mov   bx, word ptr cs:[_RESIDENT_VARIABLE_handle_list + BX + HANDLE_INFO.handle_first_page]
 
 mov   ax, dx   ; dx has logical page number. 
 dec   ax
 js    func_24_have_next_source_page

func_24_loop_get_next_source_page:
 mov   bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
 dec   ax
 jns   func_24_loop_get_next_source_page
func_24_have_next_source_page:

 mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_current_page], bx
 ; dx still has logical page number.
 mov   ax, FUNC_24_SOURCE_PAGE_FRAME_INDEX
 call  UTIL_get_page
 mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_original_page], ax
 xchg  bx, dx
 sub   dx, OFFSET _RESIDENT_VARIABLE_page_list
 shr   dx, 1
 mov   ax, FUNC_24_SOURCE_PAGE_FRAME_INDEX
 call  UTIL_set_page
 xchg  bx, dx

 pop   bx

 
 mov   ds, word ptr cs:[mappable_phys_page_struct_page_frame+(4 * FUNC_24_SOURCE_PAGE_FRAME_INDEX)] ; page 3 segment
 pop   ax   ; AAAA restore ax
 test  bh, 1
 je    func_24_use_dest_conventional
 
func_24_prep_dest_logical:

; look up logical page 
 push  bx
 mov   bx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_handle] ; preshifted 2
 mov   bx, word ptr cs:[_RESIDENT_VARIABLE_handle_list + BX + HANDLE_INFO.handle_first_page]
  
 mov   dx, ax   ; ax already has logical page number. backup in dx
 dec   ax
 js    func_24_have_next_dest_page
func_24_loop_get_next_dest_page:
 mov   bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
 dec   ax
 jns   func_24_loop_get_next_dest_page
func_24_have_next_dest_page:

 mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_current_page], bx
 
 mov   ax, FUNC_24_DEST_PAGE_FRAME_INDEX  ; dx has logical page number
 call  UTIL_get_page
 mov   word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_original_page], ax
 
 xchg   bx, dx
 sub    dx, OFFSET _RESIDENT_VARIABLE_page_list
 shr    dx, 1

 mov   ax, FUNC_24_DEST_PAGE_FRAME_INDEX   ; dx (still) has logical page number
 call  UTIL_set_page
 xchg  bx, dx

 pop   bx

 mov   es, word ptr cs:[mappable_phys_page_struct_page_frame+(4 * FUNC_24_DEST_PAGE_FRAME_INDEX)] ; page 3 segment
 ret

func_24_clean_up_segments:
  test  bl, bl
  jz    func_24_skip_source_cleanup
  mov   dx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_original_page]
  mov   ax, FUNC_24_SOURCE_PAGE_FRAME_INDEX
  call  UTIL_set_page
 func_24_skip_source_cleanup:
  test  bh, bh
  jz    func_24_skip_dest_cleanup
  mov   dx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_original_page]
  mov   ax, FUNC_24_DEST_PAGE_FRAME_INDEX
  call  UTIL_set_page

 func_24_skip_dest_cleanup:
  ret

func_24_do_bounds_checks:
  push    bp
  push    cx

  push    cx
  shl     cx, 1
  rcl     bp, 1
  shl     cx, 1
  rcl     bp, 1
  pop     cx
  and     cx, 16383
  ;bp    is num logical pages, cx is leftover.
   

  test   bl, bl
  jz     func_24_skip_si_check
  cmp    si, 16384
  jae    func_24_offset_too_high
  push   bp
  push   cx
  push   bx
  add    cx, si
  cmp    cx, 16384
  jb     func_24_source_dont_add_extra_page
  inc    bp
  func_24_source_dont_add_extra_page:
  add    bp, dx  ; source logical page numbero
  mov    bx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_handle] ; preshifted 2
  cmp    bp, word ptr cs:[_RESIDENT_VARIABLE_handle_list + BX + HANDLE_INFO.handle_num_pages]
  pop    bx
  pop    cx
  pop    bp
  ja     func_24_out_of_logical_range
 
func_24_skip_si_check:

  test   bh, bh
  jz     func_24_skip_di_check
  cmp    di, 16384
  jae    func_24_offset_too_high
  push   bx
  add    cx, di
  cmp    cx, 16384
  jb     func_24_dest_dont_add_extra_page
  inc    bp
  func_24_dest_dont_add_extra_page:
  add    bp, ax  ; dest logical page numbero
  mov    bx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_handle] ; preshifted 2
  cmp    bp, word ptr cs:[_RESIDENT_VARIABLE_handle_list + BX + HANDLE_INFO.handle_num_pages]
  pop    bx
  ja     func_24_out_of_logical_range

 func_24_skip_di_check:
  pop     cx
  pop     bp
  ret

func_24_offset_too_high:
  add    sp, 6 ; pop stack
  mov    ah, 095h   ; The offset within the logical page exceeds the length of the logical page.
  jmp    func_24_error
func_24_out_of_logical_range:
  pop    cx
  pop    bp
  mov    ah, 093h   ; The length of the source or destination expanded memory region specified exceeds the length of the expanded memory region allocated either the source or destination handle.
  add    sp, 2 ; pop return
  jmp    func_24_error

func_24_check_repage:
  
  test    bl, bl
  jz      func_24_dont_repage_source
  cmp     si, 16384
  jne     func_24_dont_repage_source

  push    dx
  push    ax
  push    bx
  mov     bx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_current_page]
  mov     bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
  mov     word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_current_page], bx
  mov     dx, bx
  sub     dx, OFFSET _RESIDENT_VARIABLE_page_list
  shr     dx, 1
  pop     bx
  mov     ax, FUNC_24_SOURCE_PAGE_FRAME_INDEX
  call    UTIL_set_page
  pop     ax
  pop     dx
  xor     si, si

 func_24_dont_repage_source:
  test    bh, bh
  jz      func_24_dont_repage_dest
  cmp     di, 16384
  jne     func_24_dont_repage_dest

  push    dx
  push    ax
  push    bx
  mov     bx, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_current_page]
  mov     bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
  mov     word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_current_page], bx
  mov     dx, bx
  sub     dx, OFFSET _RESIDENT_VARIABLE_page_list
  shr     dx, 1
  pop     bx
  mov     ax, FUNC_24_DEST_PAGE_FRAME_INDEX
  call    UTIL_set_page
  pop     ax
  pop     dx
  xor     di, di
 func_24_dont_repage_dest:
  ret


func_24_jmp_to_skip_conventional_overlap_check:
  jmp   func_24_skip_conventional_overlap_check
func_24_do_overlap_check:
  push   di
  push   si
  test   bx, bx
  jnz    func_24_jmp_to_skip_conventional_overlap_check

  mov    ax, ds
  SHIFT_MACRO  rol ax 4
  mov    dx, ax
  and    dx, 0FFF0h
  and    ax, 0Fh
  add    si, dx
  adc    ax, 0

  push   ax

  mov     ax, es
  SHIFT_MACRO  rol ax 4
  mov    dx, ax
  and    dx, 0FFF0h
  and    ax, 0Fh
  add    di, dx
  adc    ax, 0

  
func_24_compare_overlap:
  ; source dx:di
  ; dest ax:si

  pop   dx

    

; is DS:SI > ES:DI?
  ; dx:si
  cmp   dx, ax

  ja    func_24_check_backwards_overlap
  jb    func_24_check_forwards_overlap
  cmp   si, di
  ja    func_24_check_backwards_overlap

func_24_check_forwards_overlap:
  mov   byte ptr cs:[_RESIDENT_VARIABLE_FUNC_24_overlap_detected_do_backwards], 1

func_24_continue_overlap_check:
  add    si, cx
  adc    dx, bp
; does DS:SI + BP:CX overlap ES:DI?


  cmp   dx, ax

  ja    func_24_overlap_occurred
  jb    func_24_no_overlap
  cmp   si, di
  ja    func_24_overlap_occurred
  
func_24_no_overlap:

  xor   ax, ax
  pop   si
  pop   di
  ret

func_24_overlap_occurred:
  mov   ax, 092h
  pop   si
  pop   di
  ret



func_24_skip_conventional_overlap_check:
  cmp    bl, bh
  jne    func_24_no_overlap  ; extended/conventional cant overlap
  ; both extended!
  ; are handles the same?
  mov   ax, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_source_handle]
  cmp   ax, word ptr cs:[_RESIDENT_VARIABLE_FUNC_24_dest_handle]
  jne   func_24_no_overlap


; does (logical_source):SI + BP:CX overlap (logical_dest):DI?



  _RESIDENT_VARIABLE_FUNC_24_source_logical_page:
  mov   ax, 01000h
  cwd
  shr   ax, 1
  rcr   dx, 1
  shr   ax, 1
  rcr   dx, 1  ; 16384 * page
  or    si, dx ; plus offset



  push   ax
  _RESIDENT_VARIABLE_FUNC_24_dest_logical_page:
  mov   ax, 01000h
  cwd
  shr   ax, 1
  rcr   dx, 1
  shr   ax, 1
  rcr   dx, 1  ; 16384 * page
  or    di, dx ; plus offset

  jmp   func_24_compare_overlap
func_24_check_backwards_overlap:
  xchg  ax, dx
  xchg  di, si
  mov   byte ptr cs:[_RESIDENT_VARIABLE_FUNC_24_overlap_detected_do_backwards], 0
  jmp   func_24_continue_overlap_check

func_24_conventional_wraparound:
  pop   dx
  mov   ah, 0A2h   ; An attempt was made to wrap around the 1M-byte address space of conventional memory during the move.
  jmp   func_24_error

func_24_check_conventional_wraparound:

  test  bl, bl
  jne   func_24_skip_source_1M_check
  push  dx
  push  ax


  mov    ax, ds
  SHIFT_MACRO  rol ax 4
  mov    dx, ax
  and    dx, 0FFF0h
  and    ax, 0Fh
  add    dx, si
  adc    ax, 0

  
  add   dx, cx
  adc   ax, bp
  cmp   ax, 16
  pop   ax
  ja    func_24_conventional_wraparound
  jne   func_24_not_source_wraparound
  test  dx, dx
  jmp   func_24_conventional_wraparound
  func_24_not_source_wraparound:

  pop   dx


  func_24_skip_source_1M_check:
  test  bh, bh
  jne   func_24_skip_dest_1M_check
  push  dx
  push  ax

  mov    ax, es
  SHIFT_MACRO  rol ax 4
  mov    dx, ax
  and    dx, 0FFF0h
  and    ax, 0Fh
  add    dx, di
  adc    ax, 0

  add   dx, cx
  adc   ax, bp
  cmp   ax, 16
  pop   ax

  ja    func_24_conventional_wraparound
  jne   func_24_not_dest_wraparound
  jcxz  func_24_not_dest_wraparound
  jmp   func_24_conventional_wraparound
  func_24_not_dest_wraparound:
  pop   dx



  func_24_skip_dest_1M_check:

  func_24_skip_1M_check:
  ret




;          14 Get All Handle Pages                           4Dh       
; we write all handles and their page counts to es:di
EMS_FUNCTION_04Dh:
push  di
xor   ax, ax ; count
push  cx
mov   cx, MAX_HANDLE_COUNT

mov   bx, OFFSET _RESIDENT_VARIABLE_handle_list
  
  func_14_check_next_handle:
   cmp   word ptr cs:[bx], -1 ; 
   je    func_14_free_handle
   stosw ; handle number
   push  ax
   mov   ax, word ptr cs:[bx + HANDLE_INFO.handle_num_pages]
   stosw ; handle page count
   pop   ax ; restore ax
   func_14_free_handle:
   inc   ax
   add   bx, SIZE HANDLE_INFO
   loop  func_14_check_next_handle
xchg ax, cx  ; zero ah. return success
pop  cx  ; restore original cx
pop  di  ; restore original di
mov  bx, word ptr cs:[_RESIDENT_VARIABLE_handle_count]


pop        ax
xor        ah, ah

iret


;          15 Get Page Map                                   4E00h    
;             Set Page Map                                   4E01h     
;             Get & Set Page Map                             4E02h     
;             Get Size of Page Map Save Array                4E03h     
EMS_FUNCTION_04Eh:

; chipset needs to implement  FUNCTION_15_GET_PAGE_MAP and FUNCTION_15_SET_PAGE_MAP
  xchg ax, bx
  pop  ax
  cmp  al, 3 
  je   func_15_sub_03
  ja   func_15_bad_subfunction
  cbw  ; zero ah
  push  ax  
  push  bx  ; restore into bx 
  push  cx
  push  di
  push  si
  cmp  al, 1
  je   func_15_sub_01
  ja   func_15_sub_02

func_15_sub_00:
  call  FUNCTION_15_GET_PAGE_MAP


func_15_pop_and_return:
  pop   si
  pop   di
  pop   cx
  pop   bx 
  pop   ax ; ah already 0
  iret  
func_15_bad_subfunction:
  mov   ah, 08Fh
  iret

func_15_sub_01:
  call  FUNCTION_15_SAVE_PAGE_MAP
  jmp   func_15_pop_and_return

not_func_15_sub_00:
  cmp   byte ptr cs:[_current_call_subfunction_value], 3
  ja    func_15_bad_subfunction
  je    func_15_sub_03
  ; fall thru

func_15_sub_02:

 call FUNCTION_15_GET_PAGE_MAP
 call FUNCTION_15_SAVE_PAGE_MAP
 jmp func_15_pop_and_return
func_15_sub_03:
;          GET SIZE OF PAGE MAP SAVE ARRAY SUBFUNCTION
  mov  ax, LENGTH_OF_STACK
  iret  
 jmp func_15_pop_and_return


; todo externalize to util?

IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE max/func15\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE max/func15\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE max/func15\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE max/func15\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE max/func15\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE max/func15\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE max/func15\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE max/func15\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE max/func15\neat.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_2MB_CHIPSET
   INCLUDE max/func15\neat2mb.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE max/func15\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE max/func15\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE max/func15\standard.asm
ENDIF

; 16 Get Partial Page Map                           4F00h     
;             Set Partial Page Map                           4F01h     
;             Get Size of Partial Page Map Save Array        4F02h     
EMS_FUNCTION_04Fh:

IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE max/func16\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE max/func16\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE max/func16\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE max/func16\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE max/func16\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE max/func16\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE max/func16\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE max/func16\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE max/func16\neat.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_2MB_CHIPSET
   INCLUDE max/func16\neat2mb.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE max/func16\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE max/func16\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE max/func16\standard.asm
ENDIF 



; didnt handle the subfuncton
EMS_FUNCTION_05001h:


IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE max/func17-1\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE max/func17-1\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE max/func17-1\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE max/func17-1\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE max/func17-1\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE max/func17-1\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE max/func17-1\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE max/func17-1\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE max/func17-1\neat.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_2MB_CHIPSET
   INCLUDE max/func17-1\neat2mb.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE max/func17-1\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE max/func17-1\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE max/func17-1\standard.asm
ENDIF








IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE max/util\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE max/util\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE max/util\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE max/util\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE max/util\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE max/util\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE max/util\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE max/util\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE max/util\neat.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_2MB_CHIPSET
   INCLUDE max/util\neat2mb.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE max/util\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE max/util\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE max/util\standard.asm
ENDIF
; TODO: these


EMS_FUNCTION_05Ch:

xchg  ax, bx
; unmap everything to -1

call  UTIL_unmap_all_pages

pop   ax
xor   ah, ah
iret 

; NOTE: FUNC 28 ENTRY POINT IN HERE
; requires alternate register sets. Most chipsets do not support this
; todo: topcat, ht18, fantasy... others?
; scamp, scat: no


IF COMPILE_CHIPSET EQ SCAMP_CHIPSET 
   INCLUDE max/func28\default.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE max/func28\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE max/func28\default.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE max/func28\default.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE max/func28\default.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE max/func28\default.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE max/func28\default.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE max/func28\default.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE max/func28\default.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_2MB_CHIPSET
   INCLUDE max/func28\default.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE max/func28\default.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE max/func28\default.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE max/func28\default.asm
ENDIF







EMS_FUNCTION_053h:

;          20 Get Handle Name                                5300h     68
;             Set Handle Name                                5301h     70
xchg  ax, bx
pop   ax
cmp   al, 1
ja    func_20_bad_subfunction
; 5301 same shared start
func_5300:

push  ax 
push  si
mov   si, dx ; handle
SHIFT_MACRO shl si 2
mov   ax, word ptr cs:[_RESIDENT_VARIABLE_handle_list + si + HANDLE_INFO.handle_num_pages]
cmp   ax, -1
je    func_20_bad_handle
shl   si, 1
add   si, OFFSET _RESIDENT_VARIABLE_handlename_list
cmp   byte ptr cs:[_current_call_subfunction_value], 1
je    func_5301
push  di

movs  word ptr es:[di], cs:[si]
movs  word ptr es:[di], cs:[si]
movs  word ptr es:[di], cs:[si]
movs  word ptr es:[di], cs:[si]

pop   di
pop   si
pop   ax
xor   ah, ah
iret


func_5301:
xchg  ax, si  ; ax gets handlename offset 
pop   si  ; restore si


PUSHA_MACRO
xchg  ax, di   ; write to di if all is good.

lodsw
xchg  ax, dx
lodsw
xchg  ax, bp
lodsw
xchg  ax, bx
lodsw

; the string is dx:bp:bx:ax. search for a dupe

mov   si, OFFSET _RESIDENT_VARIABLE_handlename_list
mov   cx, MAX_HANDLE_COUNT
func_20_loop_check_for_dupe_name:
   cmp cs:[si+0], dx
   jne func_20_not_match
   cmp cs:[si+2], bp
   jne func_20_not_match
   cmp cs:[si+4], bx
   jne func_20_not_match
   cmp cs:[si+6], ax
   jne func_20_not_match
   func_20_duplicate_name:
   POPA_MACRO
   pop  ax
   mov  ah, 0A1h
   iret

func_20_bad_subfunction:
func_21_bad_subfunction:
   mov        ah, 08fh
   iret


   func_20_not_match:
   add  si, 8   ; handle_name length
   loop func_20_loop_check_for_dupe_name

mov   word ptr cs:[di], dx
mov   word ptr cs:[di+2], bp
mov   word ptr cs:[di+4], bx
mov   word ptr cs:[di+6], ax
POPA_MACRO
pop        ax
xor        ah, ah
iret

func_20_bad_handle:
pop   si
pop        ax
mov   ah, 083h   ; The manager couldn't find either the source or destination EMM handles.
iret

func_21_null_name:
POPA_MACRO
pop   es

mov   ah, 0A1h  ; A handle found had no name (all ASCII nulls).
iret


EMS_FUNCTION_054h:

;          21 Get Handle Directory                           5400h     72
;             Search for Named Handle                        5401h     74
;             Get Total Handles                              5402h     76

xchg ax, bx

pop  ax  ; take advantage of later pusha
xor  ah, ah
cmp  al, 1
jb   do_func_21_00
je   do_func_21_01
cmp  al, 2
jne  func_21_bad_subfunction
mov  bx, MAX_HANDLE_COUNT
iret
do_func_21_01:
; search for handle
push  es
PUSHA_MACRO

lodsw
xchg  ax, dx
lodsw
xchg  ax, bp
lodsw
xchg  ax, bx
lodsw

mov   si, ax
or    si, dx
or    si, bp
or    si, bx
jz    func_21_null_name

; the string is dx:bp:bx:ax. search for a dupe

mov   si, OFFSET _RESIDENT_VARIABLE_handlename_list
mov   cx, MAX_HANDLE_COUNT
func_21_loop_check_for_dupe_name:
   cmp cs:[si+0], dx
   jne func_21_not_match
   cmp cs:[si+2], bp
   jne func_21_not_match
   cmp cs:[si+4], bx
   jne func_21_not_match
   cmp cs:[si+6], ax
   jne func_21_not_match
   func_21_found_name:
   mov es, cx
   POPA_MACRO ; ax restored
   mov dx, es
   neg dx
   add dx, MAX_HANDLE_COUNT
   pop es


   ; ah is 0

   iret

   func_21_not_match:
   add  si, 8   ; handle_name length
   loop func_21_loop_check_for_dupe_name

POPA_MACRO ; ax restored
pop   es


mov   ah, 0A0h ; No corresponding handle could be found for the handle name specified.

iret

do_func_21_00:  

push  ds
PUSHA_MACRO
push  di
push  cs
pop   ds

mov   cx, MAX_HANDLE_COUNT
xor   ax, ax
cwd
dec   dx  ; dx = -1
mov   bx, OFFSET _RESIDENT_VARIABLE_handle_list
mov   si, OFFSET _RESIDENT_VARIABLE_handlename_list
mov   bp, 8

func_21_loop_next_handle:
  
  cmp  word ptr ds:[bx + HANDLE_INFO.handle_num_pages], dx
  je   func_21_inactive_handle_skip

  stosw ; copy handle number

  movsw ; copy name
  movsw
  movsw
  movsw
  sub  si, bp
  func_21_inactive_handle_skip:
  inc  ax
  add  bx, SIZE HANDLE_INFO
  add  si, bp
  loop func_21_loop_next_handle

xchg ax, di
pop  di       ; original di pointer.
sub  ax, di   ; array data length
mov  di, 10   ; 10 bytes per entry...
inc  dx  ; zero 
div  di

mov  ds, ax ; ugh store result here.

POPA_MACRO ; ax restored.
mov ax, ds
pop   ds

; ah 0

iret

; cross platform utility function for getting the (application facing) page index for a segment.

COMMON_util_get_register_for_segment:
   push  si
   push  cx
   mov   si, OFFSET mappable_phys_page_struct
   mov   cx, PAGE_FRAME_COUNT
   check_next_segment_in_list:
   cmp   ax, word ptr cs:[si]
   je    found_page_in_list
   add   si, 4
   loop  check_next_segment_in_list

   ; fail... undefined behavior? or just store FFFF in there?
   dec   cx     ; cx = -1
   xchg  ax, cx ; ax = -1
   jmp   return_bad_register
   found_page_in_list:
   mov   ax, word ptr cs:[si+2]
   return_bad_register:
   pop   cx
   pop   si
   ret

   
COMMON_util_get_physical_register_for_segment:
   push  si
   push  cx
   mov   si, OFFSET chipset_page_lookup
   mov   cx, CHIPSET_PAGE_FRAME_COUNT
   ; todo scasd?
   check_next_segment_in_physical_list:
      lods  byte ptr cs:[si]
      cmp   ah, al
      je    found_page_in_physical_list
      loop  check_next_segment_in_physical_list

   ; fail... undefined behavior? or just store FFFF in there?
   dec   cx     ; cx = -1
   xchg  ax, cx ; ax = -1
   jmp   return_bad_register
   found_page_in_physical_list:
   xchg  ax, si
   sub   ax,  (OFFSET chipset_page_lookup) + 1

   pop   cx
   pop   si
   ret

   




; carry flag means bad handle
COMMON_check_valid_handle:
 cmp       ax, 0
 je        ret_bad_handle
 xchg      ax, bx
 SHIFT_MACRO  shl bx 2
 cmp       word ptr cs: [_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_num_pages], -1
 xchg      ax, bx
 je        ret_bad_handle  ; the one handle is unalloced..
 SHIFT_MACRO  shr ax 2
   ; clear known 0
 ret
 ret_bad_handle:
 SHIFT_MACRO  shr ax 2
 stc
 ret

COMMON_allocate_pages:
   ; allocate ax pages to handle dx
   push bx
   push dx

   mov  bx, word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_head] ; get first unallocated page
   
   SHIFT_MACRO shl  dx 2
   xchg bx, dx
   mov  word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_num_pages], ax
   test ax, ax
   je   COMMON_allocate_zero_pages
   sub  word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count], ax

   mov  word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_first_page], dx
   mov  bx, dx
   dec  ax ; owns the 'first page' already.

 

   PAGE_loop_allocate_next_page:

   dec  ax
   js   PAGE_loop_hit_last_page
   mov  bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
   jmp  PAGE_loop_allocate_next_page
   PAGE_loop_hit_last_page:
   ; ax is -1
   xchg ax, word ptr cs:[bx + PAGE_INFO.page_info_next_page] ; mark end -1
   mov  word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_head], ax


   pop  dx
   pop  bx
   ret

COMMON_allocate_zero_pages:
   mov  word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_first_page], ax

   pop  dx
   pop  bx
   ret



COMMON_deallocate_pages:

   ; deallocate all pages from handle dx
   push bx
   push dx
   mov  bx, dx
   SHIFT_MACRO shl  bx 2

   mov  ax, -1   
   xchg ax, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_num_pages] ; set -1 and get page count
   add  word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_count], ax

   test ax, ax
   jz   handle_zero_page_deallocation

   mov  ax, word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_first_page] ; get first unallocated page
   xchg ax, bx   ; ax stores original pointer. bx gets first page

   cmp  bx, -1  ; special case 0 entry list
   je   skip_loop

   PAGE_loop_deallocate_next_page:
    mov  dx, bx
    mov  bx, word ptr cs:[bx + PAGE_INFO.page_info_next_page]
    cmp  bx, -1
    jne  PAGE_loop_deallocate_next_page

   ; dx is last page before -1.
   ; bx is -1
   ; ax is pointer to handle.

   xchg ax, bx

   ; ax is -1
   
   ; 1. handle first page becomes -1.
   ; 2. global/free linked list points to old handle first page
   ; 3. handle last page poinst to old global/free first page

   xchg word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_first_page], ax  ; -1
   lock mov  bx, dx  ; bx gets ptr
   xchg word ptr cs:[_RESIDENT_VARIABLE_unallocated_page_head], ax  ; point to first page 
   lock mov  word ptr cs:[bx + PAGE_INFO.page_info_next_page], ax

   skip_loop:
   deallocate_return:
   pop  dx
   pop  bx
   ret

   handle_zero_page_deallocation:
   dec  ax  ; -1
   mov  word ptr cs:[_RESIDENT_VARIABLE_handle_list + bx + HANDLE_INFO.handle_first_page], ax ; write -1
   jmp  deallocate_return


COMMON_get_next_free_handle:
   ; return next free handle in dx
   push  bx
   mov   bx, OFFSET _RESIDENT_VARIABLE_handle_list + (SIZE HANDLE_INFO) ; start at index 1
   mov   dx, -1
   
  check_next_handle:
   cmp   word ptr cs:[bx], dx
   je    found_free_handle
   add   bx, SIZE HANDLE_INFO
   cmp   bx, offset _RESIDENT_VARIABLE_handle_list_END
   jb    check_next_handle
   ; dx = -1
   pop   bx
   ret

  found_free_handle:
   sub   bx, OFFSET _RESIDENT_VARIABLE_handle_list 
   mov   dx, bx
   SHIFT_MACRO shr dx 2
   pop   bx
   ret






ALIGN 2

;; uh.. todo make this secure
_RESIDENT_VARIABLE_access_key:
dw DEFAULT_ACCESS_KEY_LOW, DEFAULT_ACCESS_KEY_HIGH

_RESIDENT_VARIABLE_access_blocked:
db 0

IFDEF MAX_CONTEXT_COUNT
   _RESIDENT_VARIABLE_context_is_allocated:
   REPT MAX_CONTEXT_COUNT
    db 0
   ENDM
ENDIF

ALIGN 2
; global handle (first allocation)


_RESIDENT_VARIABLE_unallocated_page_count:  ; free pages is handle 0 free pages
   dw MAX_PAGE_COUNT  ; num pages for handle. -1 means unallocated.
_RESIDENT_VARIABLE_unallocated_page_head:
   dw OFFSET _RESIDENT_VARIABLE_conventional_page_list ; ptr to first page. Can be -1 if the above is 0 for ems 4.0 driver

_RESIDENT_VARIABLE_handle_list:
; handle 0 is the OS handle and owns 
_RESIDENT_VARIABLE_OS_HANDLE_page_count:  ; free pages is handle 0 free pages
   dw DEFAULT_CONVENTIONAL_PAGE_COUNT  ; num pages for handle. -1 means unallocated.
_RESIDENT_VARIABLE_OS_HANDLE_first_page:
   dw -1 ; OS ptr starts with no extra pages


REPT (MAX_HANDLE_COUNT - 1)
   dw -1  ; num pages for handle. -1 means unallocated.
   dw -1  ; ptr to first page. Can be -1 if the above is 0 for ems 4.0 driver
ENDM

_RESIDENT_VARIABLE_handle_list_END:
public _RESIDENT_VARIABLE_handle_list


_RESIDENT_VARIABLE_handlename_list:
db "SQEMMEMM"
REPT (MAX_HANDLE_COUNT - 1)
db 0, 0, 0, 0, 0, 0, 0, 0
ENDM

; for function 8/9 'push/pop' like operation.
_RESIDENT_VARIABLE_handle_page_stack:
REPT MAX_HANDLE_COUNT
  dw -1, -1, -1, -1
ENDM



_RESIDENT_VARIABLE_conventional_page_list:
public _RESIDENT_VARIABLE_page_list
_RESIDENT_VARIABLE_page_list:

CURRENT_NEXT_POINTER = _RESIDENT_VARIABLE_page_list

COMMENT @
CURRENT_NEXT_POINTER = _RESIDENT_VARIABLE_conventi
onal_page_list

IF DEFAULT_CONVENTIONAL_PAGE_COUNT GE 1

   REPT (DEFAULT_CONVENTIONAL_PAGE_COUNT - 1)
      CURRENT_NEXT_POINTER = CURRENT_NEXT_POINTER + (SIZE PAGE_INFO)
      dw  CURRENT_NEXT_POINTER
   ENDM
   dw  -1   ; last entry
   CURRENT_NEXT_POINTER = CURRENT_NEXT_POINTER + (SIZE PAGE_INFO)

ENDIF
@


REPT (MAX_PAGE_COUNT - 1)
   CURRENT_NEXT_POINTER = CURRENT_NEXT_POINTER + (SIZE PAGE_INFO)
   dw  CURRENT_NEXT_POINTER
ENDM
dw  -1   ; last entry




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


STRING_resident_driver_size                 db            "EMS Driver Resident Memory Usage: "
STRING_resident_driver_size_EDIT_OFFSET     db            "      Bytes, Entrypoint:  "
STRING_resident_driver_location_EDIT_OFFSET db            "0000:0000",'$'

STRING_driver_memory db 0Dh, 0Ah, "EMS Memory: "
STRING_driver_memory_EDIT_EMS_TOTAL    db "   0 KB   Starting Position: "
STRING_driver_memory_EDIT_OFFSET_TOTAL db "   0 KB$"


STRING_testing_memory    db 0Dh, 0Ah, 'Testing Memory Page:    $'
STRING_testing_memory_finished: db "OK! ", 0Dh, 0Ah, '$'
STRING_forced_failure     db 0Dh, 0Ah, 'Driver forced to failure with -X parameter.$'
STRING_bad_frame      db 0Dh, 0Ah, "Page Frame "
STRING_bad_frame_EDIT db "D000 failed pagination test!$"
STRING_bad_memory    db 0Dh, 0Ah, 'Memory test failed!$'
STRING_driver_exists db 0Dh, 0Ah, 'EMS Driver already loaded (chaining not supported).',0Dh, 0Ah, '$'
STRING_driver_successfully_installed db 0Dh, 0Ah, 'SQEMM successfully initialized.', 0Ah, 0Dh, '$'
STRING_driver_failed_installing db 0Dh, 0Ah, ' Driver not initialized.', 0Ah,  '$'
STRING_bad_page_frame_chipset db 0Dh, 0Ah,  'Bad Page Frame defined in Chipset Setting! SQEMM was not loaded.', 0Dh, 0Ah,'$'
STRING_bad_port_chipset db 0Dh, 0Ah,  'Bad Port in Chipset Setting! SQEMM was not loaded.', 0Dh, 0Ah,'$'
STRING_bad_page_frame_param db 0Dh, 0Ah,  'Bad Page Frame Param in Driver Parameters! SQEMM was not loaded.', 0Dh, 0Ah,'$'
STRING_bad_page_count_param db 0Dh, 0Ah,  'Bad Page Count Param in Driver Parameters! SQEMM was not loaded.', 0Dh, 0Ah,'$'
STRING_bad_page_offset_param db 0Dh, 0Ah, 'Bad Page Offset Param in Driver Parameters! SQEMM was not loaded.', 0Dh, 0Ah,'$'
STRING_bad_port_param       db 0Dh, 0Ah,  'Bad Port Param in Driver Parameters! SQEMM was not loaded.', 0Dh, 0Ah,'$'
STRING_could_not_determine  db 0Dh, 0Ah,  'Could not determine page frame or port! SQEMM was not loaded.', 0Dh, 0Ah,'$'
STRING_dynamic_determine    db 0Dh, 0Ah,  'Dynamically determined parameters!', 0Dh, 0Ah,'$'
STRING_parsed_parameter                     db            " (User Parameter)", 0Dh, 0Ah,'$'
STRING_unparsed_parameter                   db            " (Default Parameter)", 0Dh, 0Ah,'$'
STRING_chipset_parameter                    db            " (Chipset Parameter)", 0Dh, 0Ah,'$'
STRING_dynamic_parameter                    db            " (Dynamic Parameter)", 0Dh, 0Ah,'$'

STRING_good_port_param                      db            "Using Port:  "
STRING_good_port_param_EDIT_OFFSET          db            "0208",'$'
STRING_good_page_frame_param                db            "Page Frame:  "
STRING_good_page_frame_param_EDIT_OFFSET    db            "D000",'$'
STRING_good_page_count_param                db            "Page Count:  "
STRING_good_page_count_param_EDIT_OFFSET    db            "0256",'$'
STRING_good_page_offset_param               db            "Page Offset: "
STRING_good_page_offset_param_EDIT_OFFSET   db            "0128",'$'




IF COMPILE_CHIPSET EQ SCAMP_CHIPSET
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for VLSI SCAMP', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for Fantasy Card', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for Rodneys 286 Chipset', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for C&T SCAT', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for Headland HT-18, HT-21, HT-22, HT-25', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for Headland HT-12', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for HEDAKA/CITYGATE/PCCHIPS Chipsets', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for Lo-tech EMS Board', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for Chips NEAT', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ NEAT_2MB_CHIPSET
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for Chips NEAT (2MB MAX)', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for Intel Above Board', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for SARC RC2016A', 0Dh, 0Ah,'$'
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
  STRING_main_header db 0Dh, 0Ah, 'SQEMM v 0.8 for Standard EMS Boards', 0Dh, 0Ah,'$'
ENDIF

_INIT_PARAM_OFFSET:
dw 0
_INIT_PARAM_command_line_length:
dw 0
_INIT_PARAM_last_parsed_param:


DRIVER_INIT:
public DRIVER_INIT
push  cs
pop   ds
; selfmodify to disable double init.
mov   byte ptr ds:[SELFMODIFY_prevent_double_init+1], OFFSET RETURN_UNRECOGNIZED_COMMAND - SELFMODIFY_prevent_double_init_AFTER     ; overwrite pointer to this init function with pointer to "failed to install" (03fa5h)
mov   dx, OFFSET STRING_main_header

mov   ah, 9  ; PRINT_STRING
int   021h

; get interrupt vector. check it's header/string
mov   ax, 03567h
int   021h
mov   di, 0Ah
mov   si, di
mov   cx, 8
rep   cmpsb
 
jne   EMS_INTERRUPT_FREE
; an ems driver is already installed

mov   dx, OFFSET STRING_driver_exists

DRIVER_NOT_INSTALLED:
mov   ah, 9  ; PRINT_STRING
int   021h

mov   dx, OFFSET STRING_driver_failed_installing
mov   ah, 9  ; PRINT_STRING
int   021h

lds   bx, [_RESIDENT_VARIABLE_request_header_pointer]
mov   word ptr ds:[bx + 3], 0810ch
mov   word ptr ds:[bx + 0eh], OFFSET end_of_driver_label
mov   word ptr ds:[bx + 010h], cs
;mov   word ptr ds:[bx + 017h], 00
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
   INCLUDE max/init\scamp.asm
ELSEIF COMPILE_CHIPSET EQ FANTASY_EMS
   INCLUDE max/init\fantasy.asm
ELSEIF COMPILE_CHIPSET EQ RODNEY_EMS
   INCLUDE max/init\rodney.asm
ELSEIF COMPILE_CHIPSET EQ SCAT_CHIPSET
   INCLUDE max/init\scat.asm
ELSEIF COMPILE_CHIPSET EQ HT18_CHIPSET
   INCLUDE max/init\ht18.asm
ELSEIF COMPILE_CHIPSET EQ HT12_CHIPSET
   INCLUDE max/init\ht12.asm
ELSEIF COMPILE_CHIPSET EQ HEDAKA_CHIPSET
   INCLUDE max/init\hedaka.asm
ELSEIF COMPILE_CHIPSET EQ LOTECH_BOARD
   INCLUDE max/init\lotech.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_CHIPSET
   INCLUDE max/init\neat.asm
ELSEIF COMPILE_CHIPSET EQ NEAT_2MB_CHIPSET
   INCLUDE max/init\neat2mb.asm
ELSEIF COMPILE_CHIPSET EQ INTEL_ABOVEBOARD
   INCLUDE max/init\intelab.asm
ELSEIF COMPILE_CHIPSET EQ SARC_RC2016A
   INCLUDE max/init\sarc.asm
ELSEIF COMPILE_CHIPSET EQ STANDARD_EMS_BOARD
   INCLUDE max/init\standard.asm
ENDIF


;  memory tests

mov   ah, "S" ; skip tests
call  parse_driver_params

jnc   dont_skip_tests

jmp   skip_tests
dont_skip_tests:

mov   dx, OFFSET STRING_testing_memory
mov   ah, 9  ; PRINT_STRING
int   021h

mov   cx, word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count]
mov   ds, word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1]

xor   bx, bx
; simple test of each page in frame 0
test_if_next_page_ok:

   mov   ax, bx
   call  print_ax_at_cursor

   mov   dx, bx ; logical
   xor   ax, ax ; page 0
   call  UTIL_set_page

   mov   al, byte ptr ds:[di] ; store
   mov   ah, byte ptr ds:[di] ; store
   cmp   al, ah
   jne   bad_memory_error

   xor   al, 0FFh
   mov   byte ptr ds:[di], al
   cmp   byte ptr ds:[di], al
   jne   bad_memory_error ; not writable?
   mov   byte ptr ds:[di], ah  ; restore

   inc   bx
   loop  test_if_next_page_ok

memory_good:


mov   ah, 03  ; INT 10,3 - Read Cursor Position and Size
xor   bx, bx  ; video page i guess
int   010h   

inc   dx
inc   dx

mov   ah, 02  ; INT 10,2 - Set Cursor Position
xor   bx, bx  ; video page i guess
int   010h


; now lets test all four pages...

mov   cx, 4

test_if_next_page_frame_ok:

   
   mov   ax, 4
   sub   ax, cx  ; physical page
   cwd  ; logical page 0
   call  UTIL_set_page

   mov   al, byte ptr ds:[di] ; store
   mov   ah, byte ptr ds:[di] ; store
   cmp   al, ah
   jne   bad_frame_error

   xor   al, 0FFh
   mov   byte ptr ds:[di], al
   cmp   byte ptr ds:[di], al
   jne   bad_frame_error ; not writable?
   mov   byte ptr ds:[di], ah  ; restore

   mov   ax, 4
   sub   ax, cx  ; physical page
   cwd
   dec   dx  ; unmap
   call  UTIL_set_page


   mov   ax, ds
   add   ax, 0400h
   mov   ds, ax

   loop  test_if_next_page_frame_ok

jmp   page_frame_good

bad_memory_error:
   push  cs
   pop   ds
   mov   dx, OFFSET STRING_bad_memory
   jmp   DRIVER_NOT_INSTALLED

bad_frame_error:
   mov   ax, ds
   push  cs
   pop   ds
   mov   al, ah
   and   ah, 0Fh
   SHIFT_MACRO shr al 4
   add   ax, (("A" - 0Ah) SHL 8) + "A" - 0Ah

   mov   word ptr ds:[STRING_bad_frame_EDIT], ax
   mov   dx, OFFSET STRING_bad_frame
   jmp   DRIVER_NOT_INSTALLED



page_frame_good:

push  cs
pop   ds
mov   dx, OFFSET STRING_testing_memory_finished
mov   ah, 9  ; PRINT_STRING
int   021h


skip_tests:


mov   ah, "r" ; skip umb resident
call  parse_driver_params

mov   si, 0
jc    page_frame_on

dec   si

page_frame_on:

mov   cx, 4

loop_default_page_frame:
   mov  dx, si
   mov  ax, 4
   sub  ax, cx
   call  UTIL_set_page

   test si, si
   js   skip_logical_increase
   inc  si
   skip_logical_increase:

   loop loop_default_page_frame

mov   ax, PAGE_FRAME_COUNT
mov   byte ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_1+1], al ; todo... should we increase based on presence of other pages versus ROMS etc?


mov   word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_3+1], ax
mov   word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_4+1], ax
shl   ax, 1
mov   word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_2+1], ax
shl   ax, 1
mov   word ptr ds:[_RESIDENT_VARIABLE_pageable_frame_count_5+2], ax

mov    si, word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count]
shl    si, 1
add    si, OFFSET  _RESIDENT_VARIABLE_page_list
mov    word ptr ds:[si-2], -1    ; last offset.

; bx is end of driver.


; set page table to page frame.

mov   ax, word ptr ds:[_RESIDENT_VARIABLE_page_frame_segment+1]
mov   word ptr ds:[mappable_phys_page_struct_page_frame+0], ax
add   ax, 0400h
mov   word ptr ds:[mappable_phys_page_struct_page_frame+4], ax
add   ax, 0400h
mov   word ptr ds:[mappable_phys_page_struct_page_frame+8], ax
add   ax, 0400h
mov   word ptr ds:[mappable_phys_page_struct_page_frame+12], ax




push  cs
pop   es
std
mov   ax, si   ; end of driver 
mov   bx, 10
mov   di, OFFSET STRING_resident_driver_size_EDIT_OFFSET + 3

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
mov        di, OFFSET STRING_resident_driver_location_EDIT_OFFSET

call       do_print_driver_param_hex
inc        di   ; skip colon
mov        ax, OFFSET MAIN_EMS_INTERRUPT_VECTOR
call       do_print_driver_param_hex

mov        dx, OFFSET STRING_resident_driver_size
mov        ah, 9  ; PRINT_STRING
int        021h

here:
public  here

mov   ah, "x" ; force failure
call  parse_driver_params
jnc   force_driver_failure




; todo variableize, remap pointers etc.


public _RESIDENT_VARIABLE_handle_count
; set interrupt vector  067h
mov        dx, OFFSET MAIN_EMS_INTERRUPT_VECTOR
mov        ax, 02567h
int        021h

DRIVER_INSTALLED:

mov   di, OFFSET STRING_driver_memory_EDIT_EMS_TOTAL
mov   ax, word ptr ds:[_RESIDENT_VARIABLE_unallocated_page_count]
call  print_kb_ems_fourchar

mov   di, OFFSET STRING_driver_memory_EDIT_OFFSET_TOTAL
mov   ax, word ptr ds:[_INIT_PARAM_OFFSET]
call  print_kb_ems_fourchar


mov   dx, OFFSET STRING_driver_memory
mov   ah, 9  ; PRINT_STRING
int   021h




mov   dx, OFFSET STRING_driver_successfully_installed
mov   ah, 9  ; PRINT_STRING
int   021h

lds   bx, dword ptr ds:[_RESIDENT_VARIABLE_request_header_pointer]
mov   word ptr ds:[bx + 3], 0100h

; 0Eh: MS-DOS 5 set pointer to end of memory used by driver
; 10h: the segment for above
mov   word ptr ds:[bx + 0eh], si  ; end of driver
mov   word ptr ds:[bx + 010h], cs
;mov   word ptr ds:[bx + 017h], 00
ret

force_driver_failure:
mov  dx, OFFSET string_forced_failure
jmp  DRIVER_NOT_INSTALLED

print_kb_ems_fourchar:

xor   dx, dx
mov   cx, 6
loop_shift_6:
   shr   ax, 1
   rcr   dl, 1
   loop  loop_shift_6
; ax:dl megabytes.
SHIFT_MACRO shr   dl 2  

test  ax, ax 
jz    write_ems_kb

write_ems_mb:
   mov   word ptr ds:[di+5], "BM"
   cmp   al, 10
   jb    one_character_ems_mb
   mov   dh, 10
   div   dh
   xor   dh, dh
one_character_ems_mb:
   xchg  al, ah
   add   ax, ('0' SHL 8) + '0'
   cmp   al, '0'
   jne   do_print_ems_mb
   mov   al, ' '
   do_print_ems_mb:
   stosw
   mov   al, '.'
   stosb
   xchg  ax, dx
   mov   dl, 10
   mov   dh, 64
   mul   dl
   div   dh
   add   al, '0'
   stosb
   ret


write_ems_kb:
   xchg ax, dx

write_ems_kb_call:
   ;mov   word ptr ds:[di+5], "BK"  ; there by default.
   test ax, ax
   jz   just_write_zero
   add  di, 4
   std
   mov  cx, 4
   mov  bx, 10
   mov  dx, 16
   mul  dx
   loop_print_next_ems_kb:
      xor  dx, dx
      div       bx
      xchg      ax, dx  ; get   remainder in ax
      add       al, '0' ; ASCIIfy
      stosb             ; print remainder from ax
      xchg      ax, dx  ; get   quotient back in ax
      test      ax, ax
      jnz       loop_print_next_ems_kb

   cld
   just_write_zero:
   ret


; idea was to capitalize, find end of command line
; turns out ms-dos pre-capitalizes it all? (what about other DOS?) consider removing. 
process_command_line:

   push       ds
   lds        si, dword ptr cs:[_RESIDENT_VARIABLE_request_header_pointer]
   lds        si, ds:[si + 012h]  ; todo whats this offset
   xor        cx, cx

   pcl_parse_next_character:
      lodsb
      cmp        al, 0Dh
      je         pcl_done_processing_command_line
      inc        cx

      ; capitalize character
      cmp        al, 061h
      jb         no_upper
      cmp        al, 07Ah
      ja         no_upper
      sub        al, 020h
      mov        byte ptr ds:[si-1], al
      no_upper:

      jmp        pcl_parse_next_character

   pcl_done_processing_command_line:
   mov        word ptr cs:[_INIT_PARAM_command_line_length], cx
   pop        ds
   ret


parse_driver_params:

; character to search for passed in ah
; search for "-X" where X is ah
; return pointer in es:di
; return found == true in carry flag.
cld ; this got set before... not sure where
push       cx

mov        cx, word ptr cs:[_INIT_PARAM_command_line_length] ; max param length
les        di, dword ptr cs:[_RESIDENT_VARIABLE_request_header_pointer]
les        di, es:[di + 012h]  ; todo whats this offset

mov        al, "-"
mov        word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_unparsed_parameter ; default not found

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
mov       word ptr ds:[_INIT_PARAM_last_parsed_param], OFFSET STRING_parsed_parameter
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


print_ax_at_cursor:
   push  bx
   push  cx
   push  dx
   push  si
   
   push  ax
   
   mov   ah, 03  ; INT 10,3 - Read Cursor Position and Size
   xor   bx, bx  ; video page i guess
   int   010h   


   mov   si, 10
   pop   ax
   push  dx    ; match A
   
   do_next_digit_print:
      push  dx  ; match B
      xor   dx, dx
      div   si
      xchg  ax, dx  ; get   remainder in ax
      
      xor   bx, bx  ; video page i guess
      add   al, '0' ; ASCIIfy
      mov   cx, 1
      mov   ah, 0Ah; 
      int   010h  ; INT 10,A - Write Character Only at Current Cursor Position

      xchg  ax, dx ; ax gets div result again

      pop   dx  ; match B cursor
      dec   dx  ; minus one to position
      push  ax  ; match C
      mov   ah, 02  ; INT 10,2 - Set Cursor Position
      xor   bx, bx  ; video page i guess
      int   010h
      pop   ax  ; match C restore div.

      test  ax, ax
      jnz   do_next_digit_print

   
   pop   dx  ; match A restore col position
   mov   ah, 02  ; INT 10,2 - Set Cursor Position
   xor   bx, bx  ; video page i guess
   int   010h


   pop   si
   pop   dx
   pop   cx
   pop   bx
   ret


;;; END GENERIC INIT CODE. This section is not resident after initialization
;;; END GENERIC INIT CODE. This section is not resident after initialization
;;; END GENERIC INIT CODE. This section is not resident after initialization
;;; END GENERIC INIT CODE. This section is not resident after initialization


;;; BEGIN CHIPSET SPECIFIC FUNCTION INIT DEFINITIONS. This section is not resident after initialization
;;; BEGIN CHIPSET SPECIFIC FUNCTION INIT DEFINITIONS. This section is not resident after initialization
;;; BEGIN CHIPSET SPECIFIC FUNCTION INIT DEFINITIONS. This section is not resident after initialization
;;; BEGIN CHIPSET SPECIFIC FUNCTION INIT DEFINITIONS. This section is not resident after initialization


; TODO move the below to another file

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


IF COMPILE_CHIPSET EQ NEAT_CHIPSET
   _NEAT_PORT_LOOKUP:
   db 008h
   db 018h 
   db 000h ; 00h = bad value
   db 000h
   db 000h
   db 058h
   db 068h
   db 000h
   db 000h
   db 000h
   db 0A8h
   db 0B8h
   db 000h
   db 000h
   db 0E8h
   db 00h

_NEAT_DRAM_BANK_LOOKUP:

  ; bit 5 = num banks
  ; bit 6-7:   00 = nomem  01 = mixed () 640k, 1.64 if bit 5 on
  ; bit 6-7:   10 = 1MB per bank   11 = 4MB per bank

  ;          al  ah   ; num pages (subtract offset for ems pages)
  ; 8 MB   = E0, E0   512
  ; 5 MB   = E0, A0   320
  ; 4.64MB = E0, 60   296
  ; 2MB (B)= A0, A0   128
  ; 1.64MB = A0, 60   104
  ; 6 MB   = E0, C0   384
  ; 3 MB   = A0, C0   192
  ; 4 MB   = E0, 00   256
  ; 1.5 MB = A0, 80   96
  ; 1 MB   = A0, 00   64
  ; 640KB  = 60, 00   40
  ; 2 MB   = C0, 00   128
  ; 512KB  = 80, 00   32
  ; 0  KB  = 00, 00   0

  ; so
  ; 60 = 40
  ; 80 = 32
  ; a0 = 64
  ; c0 = 128
  ; e0 = 256
  ; shift right 5 and subtract 3 to get 0 1 2 3 4 from 60 80 a0 c0 e0
  
db  40-1, 32-1, 64-1, 128-1, 256-1 ; add one back later. fit in less space and less register juggle.



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
