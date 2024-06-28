; overview of file:
; first 0Ah bytes: standard sys header
; up to 062h: data, pointers
; 062h to 0BDh: entry points to driver
; then several thousand bytes of data
; then the main code, including accessory functions, ems functions, and driver init entry point.

	.286
	.MODEL  tiny
	
.DATA
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
pointer_to_ems_init dw 3F57h

;0004Ah various pointers to various possible entry points - most go to "unrecognized command"
dw 00A5h 
dw 00A5h 
dw 00A5h 
dw 00A5h 
dw 00A5h 
;00054h Seems to be the pointer used in ems_driver_call?
dw 00A5h 
dw 00A5h 
dw 00A5h 
dw 00A5h 
dw 009Fh 
dw 00A5h 
dw 00A5h


; 00062h
EMS_DRIVER_INIT:
mov  word ptr cs:[driver_arguments], bx        ; store 32 bit pointer to arguments to 02871h
mov  word ptr cs:[driver_arguments+2], es        
retf 

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
mov  bx, ds:word ptr [driver_arguments]
mov  es, ds:word ptr [driver_arguments+2]
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
mov  word ptr [bx + 3], 0100h
ret  
RETURN_UNRECOGNIZED_COMMAND:
mov  word ptr [bx + 3], 08103h
ret  

 
;000abh
db 'HANDLE_TABLE_START'

CONST_HANDLE_TABLE_STRUCT_SIZE = 017h
CONST_HANDLE_TABLE_LENGTH = 0FFh

STRUCT_23_BYTES MACRO 
  db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
ENDM

;000bdh 23 byte struct, apparently up to 255 in length. (5865, 016E9h)
; a handle contains the information on an allocation  
; word 0         number of pages to this handle
; bytes 02-09h   8 bytes, name?
; word 0ah is count of pages in the handle. 0 means a freed handle
; byte 0ch 0 or ffh, related to saving/restoring page map
; 0dh-16h is used to store 10 bytes of data when storing/restoring page map
;   - its the page frame's four registers's words worth of ems index port data (read from ports EAh/EBh)
;   - followed by 0Bh/0Ch chipset data bytes
handle_table:

REPT CONST_HANDLE_TABLE_LENGTH
    STRUCT_23_BYTES
endm


;017A6h seems to contain number of pages that dont include ROM fragments
upper_C000toEC00_non_rom_pages dw 0000h

;017A8h
db 'FRAME_USEABLE'

;017B5h 
; ff byte if theres a BIOS in this 0400h eligible page frame from c000 to ec00.
bios_in_upper_pages dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h

;017C1h
db 'L_PAGE_START'

;017CDh - 4 byte struct array  24 (018h) in length.
 ; word 0: page register index pointer to previous entry in list.
 ; word 1: the pointer to the next page (in this struct) in this segment. 0FFFFh if the end

 ; not sure - this might be related to keeping track of free pages internally(??) so when pages get deallocated, reallocated,
 ; you need to be able to find those gaps and free physical page frame indices... seems to get modified a lot in reallocate pages
 
page_linked_list:

STRUCT_4_BYTES MACRO 
  dw 0000h, 0000h
ENDM

REPT 36
    STRUCT_4_BYTES
endm

REPT 952
    STRUCT_4_BYTES
endm

; there's a ton of extra unused space here for some reason. page_linked_list should only be 144 or 0x90 bytes?



;0273Dh
db 'P_PAGE_START'
;02749h 108 bytes
;02749h  3 byte struct arrary related to the ems page registers. 36 page registers in length
 ; byte 0-1: page frame segment
 ; byte 2: ems register
page_frame_segment_to_ems_index_port_map_byte:
db 00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h
db 00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h
db 00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h,  00h, 00h, 00h

db 'P_PAGE_END'

; 027bfh 
; Two-word pairs. first word is page frame (04000h, 04400h... etc) up to f000.  
;                 second word its physical ems index port
; 156 bytes long? enough for 39 registers. too much? chipset max is 36.
; i think a clone of the above struct in practice except pre-formatted for return in function 5800h (2nd arg a word, ordered lowest segment first)
mappable_phys_page_struct:
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h

;0284Fh
db 'MAP_PAGE_END'

;0285bh  page frame values
page_frame_segment_values:
dw 0C000h
dw 0C400h 
dw 0C800h 
dw 0CC00h 
dw 0D000h 
dw 0D400h 
dw 0D800h 
dw 0DC00h 
dw 0E000h

dw 0000h
dw 0000h

; 02871h: 32-bit pointer to arguments to driver
driver_arguments dd 00000000h 

;02875h some key used for access rights to OS level calls, generated from sys clock + some algo
os_password_low dw 0000h
;02877h initailization clock time 
os_password_high dw 0000h

;02879h: 
  ;holds pointer to 000bdh or the start of handle_table
handle_table_pointer dw 0000h 
;0287bh:
dw 0000h

; 0287dh pointer to page_linked_list
page_linked_list_pointer dw 0000h
; 0287fh pointer to end of page_linked_list
end_of_page_linked_list dw 0000h




;02881h  ; segment of pageframe
page_frame_segment dw 0000h 
; 02883h
temporary_jump_addr dw 0000h
 
; 02885h initialized to 0feh.
handle_count dw 0000h

; 02887h
  ; pointer to result of GET_EMM_HANDLE
get_emm_handle_result_pointer dw 0000h;


; 02889h
; stores total page count
total_page_count dw 0000h


; 0288Bh
db 'L_Page_num'
; 02895h
; stores unallocated page count 
unallocated_page_count dw 0000h;
; 02897h
db 'P_Page_num'
;028a1h
number_ems_pages dw 0000h
;028a3h
page_map_call_stored_ax dw 0000h 
;028a5h
stored_ax dw 0000h
;028a7h
dw 0000h
;028a9h
page_map_call_stored_dx dw 0000h 
;028abh
page_map_call_stored_ds dw 0000h 
;028adh
page_map_call_stored_si dw 0000h 
;028afh
dw 0000h
;028b1h
page_map_call_stack_pointer dw 0000h 
;028b3h mystery bytes
func_24_temp_storage_5 dw 0000h
;028b5h mystery bytes
func_24_temp_storage_6 dw 0000h
;028b7h mystery bytes
func_24_temp_storage_3 dw 0000h
;028b9h mystery bytes
func_24_temp_storage_4 dw 0000h
;028bbh func 24 arguments, 18 bytes copied here at start of func_24
func_24_region_length_low_word dw 0000h
;028bdh 
func_24_region_length_high_word dw 0000h
;028bfh 
func_24_source_memory_type db 00h
;028c0h 
func_24_source_handle dw 0000h
;028c2h 
func_24_source_initial_offset dw 0000h
;028c4h 
func_24_source_initial_seg_page dw 0000h
;028c6h 
func_24_dest_memory_type db 00h
;028c7h 
func_24_dest_handle dw 0000h
;028c9h 
func_24_dest_initial_offset dw 0000h
;028cbh 
func_24_dest_initial_seg_page dw 0000h
;028cdh  unused?
func_24_emm_handle_result_pointer dw 0000h
;028cfh  unused
func_24_emm_handle_result_pointer_2 dw 0000h
;028d1h holds ff or 0. 
func_24_overlapping_emm_handle db 00h
;028d2h seems to hold 0 or 1 but never read
func_24_temp_storage_18 db 00h
;028d3h seems to hold copy byte amount for the current page
func_24_temp_storage_19 dw 0000h
;028d5h something related to how much to copy
func_24_temp_storage_20 dw 0000h
;028d7h something related to how much to copy
func_24_temp_storage_21 dw 0000h
;028d9h something related to how much to copy
func_24_temp_storage_22 dw 0000h
;028dbh may be the direction of the copy
func_24_temp_storage_23 dw 0000h
; 028ddh
ose_function_set_enabled_1 db 0FFh
; 028deh
ose_function_set_enabled_2 db 00h
; 028dfh  32 bit pointer
stored_es dw 0000h
; 028e1h  32 bit pointer
stored_di dw 0000h
; 028e3h some complicated 10 byte return result from function 5900h/5901h
hardware_configuration_array dw 0400h, 0000h, 0000h, 0000h, 0000h

; 028edh Backfill enabled flag
backfill_enabled db 00h

; 028eeh this doesnt fit in 16 bits. need to fix.
backfill_register_flags dw 0000h
; 028F0h  8 bytes used during warmboot function
warmboot_data dw 2020h, 2020h, 2020h, 2020h

; 028F8h: EMS Function pointer table
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
BEEP:
push ax
mov  ax, 0e07h
int  010h
pop  ax
ret  


; look up emm handle. if cant find it return 0 in carry flag. otherwise carry flag = 1 result in get_emm_handle_result_pointer
; not sure yet whats going on here.
; dx is a page frame number?  ax and bx unused?
; if byte 0Ah of 23 byte structure is 0, return 0.
GET_EMM_HANDLE:
push       ax
push       bx
push       dx
cmp        dx, CONST_HANDLE_TABLE_LENGTH
ja         RETURN_CARRY_FLAG                  ; no error? weird.
mov        ax, CONST_HANDLE_TABLE_STRUCT_SIZE
mul        dx
add        ax, word ptr cs:[handle_table_pointer]
mov        bx, ax
mov        bx, word ptr cs:[bx + 0ah]
cmp        bx, 0
je         RETURN_CARRY_FLAG
mov        word ptr cs:[get_emm_handle_result_pointer], ax
RETURN_NO_CARRY_FLAG:
clc        
jmp        RETURN_WITH_RESULT
nop        
RETURN_CARRY_FLAG:
stc        
RETURN_WITH_RESULT:
pop        dx
pop        bx
pop        ax
ret        

; read from chipset register AL into AL
READCHIPSETREG:
out        0ech, al
jmp        NOP_A
NOP_A:
jmp        NOP_B
NOP_B:
in         al, 0edh
ret      

; WRITE AH TO chipset register AL
WRITECHIPSETREG:
out        0ech, al
jmp        NOP_C
NOP_C:
jmp        NOP_D
NOP_D:
xchg       al, ah
out        0edh, al
xchg       al, ah
ret        

; READ from EMS index port AL  into AX
READEMSPORT:
out        0e8h, al
jmp        NOP_E
NOP_E:
jmp        NOP_F
NOP_F:
in         ax, 0eah
ret        

; WRITE AL to ems index port DX to port EA/EAB
WRITEEMSPORT:
out        0e8h, al
jmp        NOP_G
NOP_G:
jmp        NOP_H
NOP_H:
push       ax
mov        ax, dx
out        0eah, ax
pop        ax
ret
        

; al = page register number 
; bx is value to write to that port
; then we turn enable that page as ems enabled.

TURN_ON_EMS_PAGE:
push       ax
push       bx
push       cx
push       dx
call       GET_PAGE_FRAME_REGISTER_FOR_INDEX
cmp        al, 023h
ja         EXIT_FUNCTION  ; exit if al > 35 or 023h. 023h is the maximum page frame register 
mov        dx, bx
call       WRITEEMSPORT
cmp        al, 0bh       ; if page register was > 0Bh - which means its backfill

; routines to get bit number [al] turned on
ja         HANDLE_BACKFILL_REGISTER
cmp        al, 7
ja         HANDLE_8_TO_12_REGISTER
; 0-7 case: just shift 01 left that many times
mov        ah, 1
mov        cl, al
shl        ah, cl
mov        al, 0ch           ; read EMS configuration register 02 which has the ON bits for pages 00-07
call       READCHIPSETREG
or         al, ah
mov        ah, al
mov        al, 0ch           ; 
call       WRITECHIPSETREG
jmp        EXIT_FUNCTION
nop        
HANDLE_8_TO_12_REGISTER:
sub        al, 8
mov        ah, 1
mov        cl, al
shl        ah, cl
mov        al, 0bh       ; read EMS configuration register 01 which has the ON bits for pages 08-0b
call       READCHIPSETREG
or         al, ah
mov        ah, al
mov        al, 0bh
call       WRITECHIPSETREG
jmp        EXIT_FUNCTION
nop        

HANDLE_BACKFILL_REGISTER:
cmp        byte ptr [backfill_enabled], 0
je         EXIT_FUNCTION

; backfill enabled
; BUG: this is not doing anything right. shifts too much. does not update right registers.
sub        al, 0ch      ; get backfill index
mov        cl, al       ; in theory this ranges from 0 to 018h
mov        ax, 1
shl        ax, cl
mov        bx, word ptr cs:[backfill_register_flags]
or         bx, ax
mov        word ptr cs:[backfill_register_flags], bx
mov        al, 0bh
call       READCHIPSETREG
or         al, 040h
mov        ah, al
mov        al, 0bh
call       WRITECHIPSETREG
EXIT_FUNCTION:
pop        dx
pop        cx
pop        bx
pop        ax
ret        


; called with AL = page register
; turns off a register
TURN_OFF_EMS_PAGE:
push       ax
push       bx
push       cx
push       dx
call       GET_PAGE_FRAME_REGISTER_FOR_INDEX
cmp        al, 023h
ja         EXIT_FUNCTION_C
cmp        al, 0bh
ja         HANDLE_BACKFILL_REGISTER_B
cmp        al, 7
ja         HANDLE_8_TO_12_REGISTER_B
; 0-7 case here
mov        ah, 1
mov        cl, al
shl        ah, cl
not        ah
mov        al, 0ch
call       READCHIPSETREG
and        al, ah
mov        ah, al
mov        al, 0ch
call       WRITECHIPSETREG
jmp        EXIT_FUNCTION_C
nop        
HANDLE_8_TO_12_REGISTER_B:
sub        al, 8
mov        ah, 1
mov        cl, al
shl        ah, cl
not        ah
mov        al, 0bh
call       READCHIPSETREG
and        al, ah
mov        ah, al
mov        al, 0bh
call       WRITECHIPSETREG
jmp        EXIT_FUNCTION_C
nop        
HANDLE_BACKFILL_REGISTER_B:
mov        dx, 010h
mov        ah, al
sub        ah, 0ch
add        dl, ah
call       WRITEEMSPORT
sub        al, 0ch
mov        cl, al
mov        ax, 1
shl        ax, cl
not        ax
mov        bx, word ptr cs:[backfill_register_flags]
and        bx, ax
mov        word ptr cs:[backfill_register_flags], bx ; check to see if the flag is enabled??
cmp        bx, 0
jne        EXIT_FUNCTION_C
mov        al, 0bh
call       READCHIPSETREG ; update ems page to enable it too
and        al, 0bfh
mov        ah, al
mov        al, 0bh
call       WRITECHIPSETREG
EXIT_FUNCTION_C:
pop        dx
pop        cx
pop        bx
pop        ax
ret

; gets page frame index for page al
; read byte at page_frame_segment_to_ems_index_port_map_byte + [al * 3] + 2;

GET_PAGE_FRAME_REGISTER_FOR_INDEX:
push       si
push       cx
mov        si, OFFSET page_frame_segment_to_ems_index_port_map_byte
xor        ah, ah
mov        cl, 3
mul        cl
add        si, ax
mov        al, byte ptr cs:[si + 2]
pop        cx
pop        si
ret


; read byte at page_frame_segment_to_ems_index_port_map_byte + [al * 3] + 2;
; get byte at 28a1
; if ax == byte at 2749 return bl
; else 
; finds the index of the 3 byte mystery struct with first byte == ax

FIND_PAGE_REGISTER_BY_INDEX:
push       si
push       bx
push       cx
mov        bl, 0
mov        si, OFFSET page_frame_segment_to_ems_index_port_map_byte
mov        cx, word ptr cs:[number_ems_pages]
CHECK_NEXT_PAGE_REGISTER_DATA_2:
cmp        word ptr cs:[si], ax
je         FOUND_PAGE_REGISTER_DATA_2
inc        bl
add        si, 3
loop       CHECK_NEXT_PAGE_REGISTER_DATA_2
FOUND_PAGE_REGISTER_DATA_2:
mov        al, bl
pop        cx
pop        bx
pop        si
ret

; reads and writes out first CX pages' EMS register data from page map to ES:DI as words, followed by contents of chipset register 0bh and 0ch
GET_EMS_REGISTER_DATA:
push       ax
push       cx
push       dx
push       si
mov        si, OFFSET page_frame_segment_to_ems_index_port_map_byte
GET_NEXT_PAGE_REGISTER_DATA:
mov        al, byte ptr cs:[si + 2]
call       READEMSPORT
stosw
add        si, 3
loop       GET_NEXT_PAGE_REGISTER_DATA
mov        al, 0bh
call       READCHIPSETREG
stosb
mov        al, 0ch
call       READCHIPSETREG
stosb
pop        si
pop        dx
pop        cx
pop        ax
ret

; writes a list of registers (source is cs/ds:si)
WRITE_PAGE_MAP:
push       ax
push       bx
push       cx
push       dx
mov        bx, OFFSET page_frame_segment_to_ems_index_port_map_byte
WRITE_NEXT_EMS_DATA:
lodsw
mov        dx, ax
mov        al, byte ptr cs:[bx + 2]
call       WRITEEMSPORT
add        bx, 3
loop       WRITE_NEXT_EMS_DATA
lodsb
mov        ah, al
mov        al, 0bh
call       WRITECHIPSETREG
lodsb
mov        ah, al
mov        al, 0ch
call       WRITECHIPSETREG
pop        dx
pop        cx
pop        bx
pop        ax
ret   

MAIN_EMS_INTERRUPT_VECTOR:
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
mov        bx, word ptr cs:[bx + 028f8h]
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
DO_ALLOCATE_PAGE:
cmp        bx, word ptr [unallocated_page_count]
ja         ARG_BX_ABOVE_PAGE_COUNT
cmp        bx, word ptr [total_page_count]
ja         ARG_BX_ABOVE_TOTAL_PAGE_COUNT
cmp        word ptr [handle_count], 0
je         NO_HANDLES_LEFT
mov        si, word ptr [handle_table_pointer]
mov        dx, 0
mov        cx, CONST_HANDLE_TABLE_LENGTH
CHECK_NEXT_PAGE_SPACE:
cmp        word ptr [si + 0ah], 0
je         FOUND_EMPTY_PAGE_SPACE
add        si, CONST_HANDLE_TABLE_STRUCT_SIZE               ; increment to the next struct
inc        dx
loop       CHECK_NEXT_PAGE_SPACE
jmp        RETURNINTERRUPTRESULT_85
SOME_ERROR_HAPPENED:
PAGE_OVERFLOW_2:
PAGE_UNDERFLOW_2:
mov        dx, 0
pop        bx
jmp        RETURNINTERRUPTRESULT_80
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
mov        dx, 0
pop        bx
jmp        RETURNINTERRUPTRESULT_87

FOUND_EMPTY_PAGE_SPACE:
cmp        word ptr [si], 0
jne        SOME_ERROR_HAPPENED  ; some error. this byte shouldnt be zero if it was identified as empty
mov        al, 0
mov        cx, 8
mov        di, si
;add        di, 2
db 081h, 0C7h, 002h, 000h
; above instruction this gets compiled into a smaller instruction

push       cs
pop        es
rep scasb    ; scan 8 bytes out of the 23  to see if theyre empty
jne        SOME_ERROR_HAPPENED ; some error. handle name should be null if this was identified as empty
mov        di, 0ah
add        di, si ; get the 0ah offset within the struct
mov        word ptr [si], bx   ; store num pages in the handle
mov        si, word ptr [page_linked_list_pointer]
mov        cx, bx
cmp        bx, 0    ; minor BUG: i don't think bx = 0 can ever make it here. it's caught above.. so this is dead code?
jne        DECREMENT_ANOTHER_PAGE
mov        cx, 1

; find entry in this 'page_linked_list_pointer'
DECREMENT_ANOTHER_PAGE:
cmp        si, word ptr [end_of_page_linked_list]  
jae        PAGE_OVERFLOW_2
cmp        si, word ptr [page_linked_list_pointer] 
jb         PAGE_UNDERFLOW_2
cmp        word ptr [si + 2], 0
je         FOUND_EMPTY_LINKED_LIST_SPOT
add        si, 4
jmp        DECREMENT_ANOTHER_PAGE
FOUND_EMPTY_LINKED_LIST_SPOT:
mov        word ptr [di], si    ; store pointer to the next empty slot
mov        di, 2
add        di, si
add        si, 4
loop       DECREMENT_ANOTHER_PAGE
cmp        bx, 0
je         DO_UNMAP

mov word ptr [di], 0ffffh
sub word ptr [total_page_count], bx
DO_UNMAP:
dec word ptr [handle_count]
pop        bx
jmp        RETURNINTERRUPTRESULT0

;          5  Map/Unmap Handle Page                          44h      

EMS_FUNCTION_044h:
push       cs
pop        ds
push       bx
push       dx
xor        ah, ah
mov        di, ax
cmp        ax, word ptr cs:[number_ems_pages]
jb         ENOUGH_PAGES
jmp        RETURN_RESULT_8B
nop        
ENOUGH_PAGES:
call       GET_EMM_HANDLE
jae        FOUND_EMM_HANDLE               ; jump if not carry
; couldnt find
jmp        RETURN_RESULT_83
nop        
FOUND_EMM_HANDLE:
call       TURN_OFF_EMS_PAGE
cmp        bx, -1
je         RETURN_RESULT_00
mov        si, word ptr [get_emm_handle_result_pointer]
; bx is logical page number...
cmp        bx, word ptr [si]
jb         FOUND_VALID_EMM_HANDLE_POINTER
jmp        RETURN_RESULT_8A
nop        
FOUND_VALID_EMM_HANDLE_POINTER:
mov        si, word ptr [si + 0ah]
mov        cx, bx
jcxz       CX_IS_ZERO               ; jump if cx is 0
LOOP_ADD_TO_SI:
mov        si, word ptr [si + 2]
loop       LOOP_ADD_TO_SI
CX_IS_ZERO:
cmp        si, word ptr [end_of_page_linked_list]
jae        PAGE_OVERFLOW_3
cmp        si, word ptr [page_linked_list_pointer]
jb         PAGE_UNDERFLOW_3
mov        bx, word ptr [si]
mov        ax, di
call       TURN_ON_EMS_PAGE
RETURN_RESULT_00:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0
PAGE_OVERFLOW_3:
PAGE_UNDERFLOW_3:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_80

; The memory manager couldn't find the EMM handle your program specified.
RETURN_RESULT_83:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_83

RETURN_RESULT_8A:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_8A

RETURN_RESULT_8B:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_8B

;         6  Deallocate Pages                               45h       

EMS_FUNCTION_045h:
push       cs
pop        ds
push       bx
push       dx
call       GET_EMM_HANDLE
jb         NO_EMM_HANDLE_FOUND
mov        si, word ptr [get_emm_handle_result_pointer]
cmp        byte ptr [si + 0ch], 0ffh
je         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED
mov        si, word ptr [get_emm_handle_result_pointer]
mov        cx, word ptr [si]
cmp        cx, 0
je         GOOD_EMM_HANDLE
mov        si, word ptr [si + 0ah]
; not sure but i think we are looping thru these handles...
CHECK_EMM_HANDLE:
cmp        si, word ptr [end_of_page_linked_list]
jae        PAGE_OVERFLOW_4
cmp        si, word ptr [page_linked_list_pointer]
jb         PAGE_UNDERFLOW_4
mov        di, word ptr [si + 2]
mov        word ptr [si + 2], 0
cmp        di, -1
je         GOOD_EMM_HANDLE
mov        si, di
jmp        CHECK_EMM_HANDLE
GOOD_EMM_HANDLE:
mov        di, word ptr [get_emm_handle_result_pointer]
mov        bx, word ptr [di]
add        word ptr [total_page_count], bx
mov        word ptr [di], 0
cmp        dx, 0
je         SKIP_INC_HANDLE_COUNT    ; if there are no pages left dec the handle
inc        word ptr [handle_count]  ; handle freed, increment handle count
mov        word ptr [di + 0ah], 0   ; mark handle freed
SKIP_INC_HANDLE_COUNT:
add        di, 2
push       cs
pop        es
mov        al, 0
mov        cx, 8
rep stosb
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0
PAGE_OVERFLOW_4:
PAGE_UNDERFLOW_4:
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
push       cs
pop        ds
push       bx
push       dx
call       GET_EMM_HANDLE
jb         NO_EMM_HANDLE_FOUND
mov        si, word ptr [get_emm_handle_result_pointer]
cmp        byte ptr [si + 0ch], 0ffh
je         STATE_ALREADY_EXISTS
mov        byte ptr [si + 0ch], 0ffh
mov        di, si
add        di, 0dh
mov        ax, cs
mov        es, ax
push       cx
mov        cx, 4
call       GET_EMS_REGISTER_DATA
pop        cx
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0
STATE_ALREADY_EXISTS:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_8D

;          9  Restore Page Map                               48h       

EMS_FUNCTION_048h:
push       cs
pop        ds
push       bx
push       dx
call       GET_EMM_HANDLE
jb         NO_EMM_HANDLE_FOUND
mov        si, word ptr [get_emm_handle_result_pointer]
cmp        byte ptr [si + 0ch], 0ffh
jne        STATE_DOESNT_EXIST
mov        byte ptr [si + 0ch], 0
add        si, 0dh
push       cx
mov        cx, 4
call       WRITE_PAGE_MAP
pop        cx
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_80
STATE_DOESNT_EXIST:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_8E

;          10 Reserved                                       49h       


EMS_FUNCTION_049h:
jmp        RETURNINTERRUPTRESULT0

;          11 Reserved                                       4Ah       

EMS_FUNCTION_04Ah:
jmp        RETURNINTERRUPTRESULT0

;          12 Get Handle Count                               4Bh       

EMS_FUNCTION_04Bh:
mov        bx, CONST_HANDLE_TABLE_LENGTH
sub        bx, word ptr cs:[handle_count]
jmp        RETURNINTERRUPTRESULT0

;          13 Get Handle Pages                               4Ch       

EMS_FUNCTION_04Ch:
call       GET_EMM_HANDLE
jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_2
mov        bx, word ptr cs:[get_emm_handle_result_pointer]
mov        bx, word ptr cs:[bx]
jmp        RETURNINTERRUPTRESULT0
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_2:
jmp        RETURNINTERRUPTRESULT_83


; BUG: INCOMPLETE: does not fill ES:DI with entries
;          14 Get All Handle Pages                           4Dh       
; we write all handles and their page counts to es:di
EMS_FUNCTION_04Dh:
push       dx
push       cs
pop        ds
mov        cx, 0ffh
xor        ax, ax
xor        dx, dx
mov        bx, word ptr [handle_table_pointer]

SEARCH_NEXT_PAGES:
mov        si, bx
cmp        word ptr [si + 0ah], 0
je         SKIP_EMPTY_PAGE  ; this page is empty. don't write it.
inc        dx
stosw
movsw      ; write page data to es:di

SKIP_EMPTY_PAGE:
inc        ax     ; ax unused.
add        bx, CONST_HANDLE_TABLE_STRUCT_SIZE
loop       SEARCH_NEXT_PAGES
mov        bx, dx
pop        dx
jmp        RETURNINTERRUPTRESULT0

;          15 Get Page Map                                   4E00h    
;             Set Page Map                                   4E01h     
;             Get & Set Page Map                             4E02h     
;             Get Size of Page Map Save Array                4E03h     

EMS_FUNCTION_04Eh:
cmp        al, 3
jb         ARG_LT_3
jmp        ARG_GTE_3
nop        
ARG_LT_3:
cmp        al, 1
je         EMS_FUNCTION_04E01h
push       cx
mov        cx, word ptr cs:[number_ems_pages]
call       GET_EMS_REGISTER_DATA
pop        cx
cmp        al, 0
jne        EMS_FUNCTION_04E02h
jmp        RETURNINTERRUPTRESULT0
EMS_FUNCTION_04E02h:
EMS_FUNCTION_04E01h:
push       cx
mov        cx, word ptr cs:[number_ems_pages]
call       WRITE_PAGE_MAP
pop        cx
jmp        RETURNINTERRUPTRESULT0
ARG_GTE_3:
cmp        al, 3
je         EMS_FUNCTION_04E03h
jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
EMS_FUNCTION_04E03h:
mov        ax, word ptr cs:[number_ems_pages]
shl        ax, 1
add        al, 2
xor        ah, ah
jmp        RETURNINTERRUPTRESULT0

; 16 Get Partial Page Map                           4F00h     
;             Set Partial Page Map                           4F01h     
;             Get Size of Partial Page Map Save Array        4F02h     
EMS_FUNCTION_04Fh:
cmp        al, 0
je         EMS_FUNCTION_04F00h
jmp        CHECK_FUNCTION_TYPE_04Fh
nop        
EMS_FUNCTION_04F00h:
push       bx
push       dx
mov        bp, di
cld        
lodsw
cmp        ax, word ptr cs:[number_ems_pages]
ja         TOO_MANY_PAGES
stosw
mov        cx, ax
jcxz       RESULT_OK
GET_NEXT_PARAM:
lodsw
call       FIND_PAGE_REGISTER_BY_INDEX
stosb
call       GET_PAGE_FRAME_REGISTER_FOR_INDEX
call       READEMSPORT
stosw
loop       GET_NEXT_PARAM
RESULT_OK:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0
pop        dx
pop        bx
mov        word ptr es:[bp], 0
jmp        RETURNINTERRUPTRESULT_8B
TOO_MANY_PAGES:
pop        dx
pop        bx
mov        word ptr es:[bp], 0
jmp        RETURNINTERRUPTRESULT_A3
CHECK_FUNCTION_TYPE_04Fh:
cmp        al, 1
je         EMS_FUNCTION_04F01h
jmp        EMS_FUNCTION_04F02h
nop        

EMS_FUNCTION_04F01h:
push       bx
push       dx
cld        
lodsw
mov        cx, ax
cmp        cx, word ptr cs:[number_ems_pages]
ja         CORRUPTED_SOURCE_ARRAY
jcxz       RESULT_OK_2
SET_NEXT_PAGE:
lodsb
mov        bl, al
lodsw
xchg       ax, bx
call       TURN_ON_EMS_PAGE
loop       SET_NEXT_PAGE
RESULT_OK_2:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0
; unused
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_80
CORRUPTED_SOURCE_ARRAY:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_A3
; unused
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_9C
EMS_FUNCTION_04F02h:

cmp        al, 2
je         CORRECT_SUBFUNCTION
jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
CORRECT_SUBFUNCTION:
cmp        bx, word ptr cs:[number_ems_pages]
ja         TOO_MANY_PAGES_2
mov        al, 3
mul        bl
add        al, 2
jmp        RETURNINTERRUPTRESULT0
TOO_MANY_PAGES_2:
mov        al, 0
jmp        RETURNINTERRUPTRESULT_8B

;          17 Map/Unmap Multiple Handle Pages
;             (Physical page number mode)                    5000h     
;             (Segment address mode)                         5001h     

EMS_FUNCTION_050h:
cmp        cx, 0
jne        VALID_SUBFUNCTION_PARAMETER
; invalid subfunction parameter
jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
VALID_SUBFUNCTION_PARAMETER:
push       bx
push       dx
xor        ah, ah
mov        word ptr cs:[stored_ax], ax
DO_NEXT_PAGE:
lodsw
mov        bx, ax
lodsw
; read two words - bx and ax
cmp        word ptr cs:[stored_ax], 0
je         PHYSICAL_PAGE_NUMBER_MODE
; look up physical page number from segment address i guess
call       FIND_PAGE_REGISTER_BY_INDEX
PHYSICAL_PAGE_NUMBER_MODE:
; no need to find param 0, i guess it's 0
call       REMAP_PAGE
or         ah, ah     ; test nobzero error/result
jne        END_LOOP     ; leave with error
loop       DO_NEXT_PAGE
; exits if we fall thru loop with no error
END_LOOP:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT


; bx is logical page. if -1, won't be remapped.
; ax is physical page
REMAP_PAGE:
push       ds
push       bx
push       cx
push       dx
push       si
push       di
push       cs
pop        ds
mov        di, ax         ; cache ax
call       GET_EMM_HANDLE
jae        FOUND_EMM_HANDLE_2
jmp        RETURN_RESULT_B_83
nop        
FOUND_EMM_HANDLE_2:
call       TURN_OFF_EMS_PAGE
cmp        bx, -1            ; -1 means conventional memory/unmapped... no need to remap
je         NO_NEED_TO_REMAP
mov        si, word ptr [get_emm_handle_result_pointer] ; not sure what's going on here yet
cmp        bx, word ptr [si]    ; bx contains num pages to the handle
jb         EMM_HANDLE_VALUE_OK
jmp        RETURN_RESULT_B_8A
nop        
EMM_HANDLE_VALUE_OK:
mov        si, word ptr [si + 0ah]
mov        cx, bx
jcxz       FOUND_EMM_HANDLE_POINTER
FOLLOW_CHAIN_LOOP:
mov        si, word ptr [si + 2]
loop       FOLLOW_CHAIN_LOOP
FOUND_EMM_HANDLE_POINTER:
cmp        si, word ptr [end_of_page_linked_list]
jae        PAGE_OVERFLOW_5
cmp        si, word ptr [page_linked_list_pointer]  
jb         PAGE_UNDERFLOW_5
mov        bx, word ptr [si]
mov        ax, di
call       TURN_ON_EMS_PAGE

NO_NEED_TO_REMAP:
mov        ah, 0
jmp        RETURN_RESULT_B
nop        

PAGE_OVERFLOW_5:
PAGE_UNDERFLOW_5:
mov        ah, 080h
jmp        RETURN_RESULT_B
nop        

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




COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_3:
pop        dx
mov        di, word ptr [get_emm_handle_result_pointer]
mov        bx, word ptr [di]
jmp        RETURNINTERRUPTRESULT_83
INSUFFICIENT_PAGES:
pop        dx
mov        di, word ptr [get_emm_handle_result_pointer]
mov        bx, word ptr [di]
jmp        RETURNINTERRUPTRESULT_87



;          18 Reallocate Pages                               51h       
; DX = handle
;BX = reallocation_count                     
EMS_FUNCTION_051h:
push       dx
push       cs
pop        ds
call       GET_EMM_HANDLE
jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_3
cmp        bx, 03dch      ; i think this is close to 16 M - 640k or 1M or something.
ja         INSUFFICIENT_PAGES
mov        si, word ptr [get_emm_handle_result_pointer]
mov        cx, word ptr [si]
mov        bp, bx
; bx is requested allocation count, cx is current allocation count
cmp        cx, bx
je         RETURN_OK   ; same number of pages
jb         ADD_PAGES_TO_HANDLE      ; fewer?  need to deallocate
jmp        REMOVE_PAGES_FROM_HANDLE

ADD_PAGES_TO_HANDLE:
cmp        cx, 0
jne        ADD_TO_MORE_THAN_0
mov        di, si
add        di, 0ah
jmp        DO_ALLOCATE_MORE_PAGES_TO_HANDLE
nop        
ADD_TO_MORE_THAN_0:
sub        bx, cx   ; page diff
cmp        bx, word ptr [total_page_count]
ja         INSUFFICIENT_PAGES_2
mov        di, word ptr [si + 0ah]
dec        cx
jcxz       ALLOCATE_OK
; out of pages?


GET_END_OF_LINKED_LIST_LOOP:
cmp        di, word ptr [end_of_page_linked_list]
jae        PAGE_OVERFLOW
cmp        di, word ptr [page_linked_list_pointer]
jb         PAGE_UNDERFLOW
mov        di, word ptr [di + 2]
loop       GET_END_OF_LINKED_LIST_LOOP
ALLOCATE_OK:
cmp        word ptr [di + 2], -1
jne        BAD_PAGE_DATA
add        di, 2

DO_ALLOCATE_MORE_PAGES_TO_HANDLE:
; for each new page to allocate, do this stuff...
mov        cx, bx
mov        si, word ptr [page_linked_list_pointer]
DECREMENT_ANOTHER_PAGE_2:
cmp        si, word ptr [end_of_page_linked_list] ; overflow
jae        PAGE_OVERFLOW
cmp        si, word ptr [page_linked_list_pointer]  ; underflow
jb         PAGE_UNDERFLOW
cmp        word ptr [si + 2], 0
je         FOUND_EMPTY_LINKED_LIST_SPOT_2
add        si, 4
jmp        DECREMENT_ANOTHER_PAGE_2
FOUND_EMPTY_LINKED_LIST_SPOT_2:
mov        word ptr [di], si
mov        di, si
add        di, 2
add        si, 4
loop       DECREMENT_ANOTHER_PAGE_2

mov        word ptr [di], 0ffffh      ; mark last page  
sub        word ptr [total_page_count], bx

DO_RETURN_OK:
mov        di, word ptr [get_emm_handle_result_pointer]
mov        word ptr [di], bp
jmp        RETURN_OK
nop        
RETURN_OK:
pop        dx
mov        di, word ptr [get_emm_handle_result_pointer]
mov        bx, word ptr [di]
jmp        RETURNINTERRUPTRESULT0
PAGE_OVERFLOW:
PAGE_UNDERFLOW:
BAD_PAGE_DATA:
pop        dx
mov        di, word ptr [get_emm_handle_result_pointer]
mov        bx, word ptr [di]
jmp        RETURNINTERRUPTRESULT_80
INSUFFICIENT_PAGES_2:
pop        dx
mov        di, word ptr [get_emm_handle_result_pointer]
mov        bx, word ptr [di]
jmp        RETURNINTERRUPTRESULT_88
REMOVE_PAGES_FROM_HANDLE:
mov        cx, bx
cmp        cx, 0
jne        DEALLOCATE_MORE_THAN_0_FROM_HANDLE
mov        si, word ptr [si + 0ah]
jmp        DO_DEALLOCATE_PAGES_FROM_LINKED_LIST
nop        
DEALLOCATE_MORE_THAN_0_FROM_HANDLE:
mov        si, word ptr [si + 0ah]
sub        cx, 1
jcxz       SKIP_DEALLCOATE_LOOP

GET_END_OF_LINKED_LIST_LOOP_2:
cmp        si, word ptr [end_of_page_linked_list]
jae        PAGE_OVERFLOW
cmp        si, word ptr [page_linked_list_pointer]
jb         PAGE_UNDERFLOW
mov        si, word ptr [si + 2]
loop       GET_END_OF_LINKED_LIST_LOOP_2

SKIP_DEALLCOATE_LOOP:
mov        di, word ptr [si + 2]
mov        word ptr [si + 2], 0ffffh
mov        si, di
DO_DEALLOCATE_PAGES_FROM_LINKED_LIST:
cmp        si, word ptr [end_of_page_linked_list]
jae        PAGE_OVERFLOW
cmp        si, word ptr [page_linked_list_pointer]
jb         PAGE_UNDERFLOW
mov        di, word ptr [si + 2]
mov        word ptr [si + 2], 0
cmp        di, -1
je  FINISH_RETURN
mov si, di
jmp DO_DEALLOCATE_PAGES_FROM_LINKED_LIST

FINISH_RETURN:
mov di, [get_emm_handle_result_pointer]
mov        word ptr [di], bp
jmp        RETURN_OK


;          19 Get Handle Attribute                           5200h     
;             Set Handle Attribute                           5201h     
;             Get Handle Attribute Capability                5202h     

; it seems this is mostly unsupported.
EMS_FUNCTION_052h:
cmp        al, 0
jne        NOT_05200h
call       GET_EMM_HANDLE
jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_4
mov        al, 0
jmp        RETURNINTERRUPTRESULT0
NOT_05200h:
cmp        al, 1
jne        NOT_05201h
call       GET_EMM_HANDLE
jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_4
cmp        bl, 0
jne        UNDEFINED_ATTRIBUTE_TYPE
jmp        RETURNINTERRUPTRESULT0
UNDEFINED_ATTRIBUTE_TYPE:
cmp        bl, 1
jne        UNSUPPORTED_FEATURE
jmp        RETURNINTERRUPTRESULT_90
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_4:
jmp        RETURNINTERRUPTRESULT_83
UNSUPPORTED_FEATURE:
jmp        RETURNINTERRUPTRESULT_91
NOT_05201h:
cmp        al, 2
jne        BAD_SUBFUNCTION_PARAMETER
mov        al, 0
jmp        RETURNINTERRUPTRESULT0
BAD_SUBFUNCTION_PARAMETER:
jmp        RETURN_BAD_SUBFUNCTION_PARAMETER

;          20 Get Handle Name                                5300h     
;             Set Handle Name                                5301h     

       
EMS_FUNCTION_053h:
push       bx
push       dx
call       GET_EMM_HANDLE
jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_5
cmp        al, 1
ja         BAD_SUBFUNCTION_PARAMETER_2
je         EMS_FUNCTION_05301h
EMS_FUNCTION_05300h:
push       cs
pop        ds
mov        si, word ptr [get_emm_handle_result_pointer]
;add        si, 2
db 081h, 0C6h, 002h, 000h

mov        cx, 4
rep movsw
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0
EMS_FUNCTION_05301h:
mov        ax, ds
mov        es, ax
mov        di, si
mov        cx, 4
xor        ax, ax
rep scasw  ; write four words into name addr
mov        ax, cs
mov        es, ax
je         CS_EQUALS_ES   ; 
mov        bp, si
mov        ax, word ptr cs:[handle_table_pointer]
add        ax, 2
mov        cx, 0ffh
CHECK_EXISTING_HANDLE_NAMES_LOOP:
mov        si, bp
mov        di, ax
mov        bx, cx
mov        cx, 4
rep cmpsw
je         HANDLE_WITH_THIS_NAME_EXISTS
add        ax, CONST_HANDLE_TABLE_STRUCT_SIZE
mov        cx, bx
loop       CHECK_EXISTING_HANDLE_NAMES_LOOP
CS_EQUALS_ES:
mov        di, word ptr cs:[get_emm_handle_result_pointer]
;add        di, 2
db 081h, 0C7h, 002h, 000h
mov        si, bp
mov        cx, 4
rep movsw
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_5:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_83
BAD_SUBFUNCTION_PARAMETER_2:
pop        dx
pop        bx
jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
HANDLE_WITH_THIS_NAME_EXISTS:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_A1

;          21 Get Handle Directory                           5400h     
;             Search for Named Handle                        5401h     
;             Get Total Handles                              5402h     


EMS_FUNCTION_054h:
push       bx
push       dx
cmp        al, 0
jne        NOT_05400h
EMS_FUNCTION_05400h:
push       cs
pop        ds
xor        ax, ax
xor        dx, dx
mov        bx, word ptr [handle_table_pointer]
mov        cx, 0ffh
CHECK_NEXT_HANDLE_LOOP:
cmp        word ptr [bx + 0ah], 0
je         HANDLE_NOT_EMPTY_DONT_COUNT
stosw
mov        si, bx
;add        si, 2
db 081h, 0C6h, 002h, 000h
push       cx
mov        cx, 4
rep movsw
pop        cx
inc        dx
HANDLE_NOT_EMPTY_DONT_COUNT:
add        bx, CONST_HANDLE_TABLE_STRUCT_SIZE
inc        ax
loop       CHECK_NEXT_HANDLE_LOOP
mov        al, dl
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0
NOT_05400h:
cmp        al, 1
jne        NOT_05401h
EMS_FUNCTION_05401h:
push       ds
pop        es
mov        di, si
mov        cx, 4
xor        ax, ax
rep scasw
je         NAME_WAS_NULL
push       cs
pop        es
mov        bp, si
xor        dx, dx
mov        ax, word ptr cs:[handle_table_pointer]
add        ax, 2
mov        cx, 0ffh
CHECK_NEXT_NAME_LOOP:
mov        si, bp
mov        di, ax
mov        bx, cx
mov        cx, 4
rep cmpsw
je         RETURN_NAME
inc        dx
add        ax, CONST_HANDLE_TABLE_STRUCT_SIZE
mov        cx, bx
loop       CHECK_NEXT_NAME_LOOP
jmp        NAME_NOT_FOUND
nop        
RETURN_NAME:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0
NOT_05401h:
cmp        al, 2
jne        BAD_SUBFUNCTION_PARAMETER_3
EMS_FUNCTION_05402h:
pop        dx
pop        bx
mov        bx, 0ffh ; todo make this a constant
jmp        RETURNINTERRUPTRESULT0
BAD_SUBFUNCTION_PARAMETER_3:
pop        dx
pop        bx
jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
NAME_NOT_FOUND:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_A0
NAME_WAS_NULL:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_A1

;      22 Alter Page Map & Jump
;             (Physical page number mode)                    5500h     
;             Alter Page Map & Jump
;             (Segment address mode)                         5501h     

EMS_FUNCTION_055h:
push       bx
push       dx
mov        bp, sp
mov        word ptr cs:[page_map_call_stored_ds], ds
mov        word ptr cs:[page_map_call_stored_si], si
xor        ch, ch
mov        cl, byte ptr [si + 4]
lds        si, [si + 5]
mov        ah, 050h     ; call ourselves to alter page
int        067h
cmp        ah, 0
je         PAGE_MAP_ALTER_WAS_OK
; return error from the alter page map, don't jump
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT
PAGE_MAP_ALTER_WAS_OK:
; im pretty sure this is stack hacking to manipulate iret into a jmp (?)
mov        ds, word ptr cs:[page_map_call_stored_ds]
mov        si, word ptr cs:[page_map_call_stored_si]
push       ss
pop        es
mov        di, bp
add        di, 0ch
movsw
movsw
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT0
EMS_FUNCTION_05602h:

;   BX = total_handles
; The value returned represents the maximum number of handles
; which a program may request the memory manager to allocate
; memory to.  The value returned includes the operating
; system handle (handle value 0).

mov        bx, 020h
jmp        RETURNINTERRUPTRESULT0

;          23 Alter Page Map & Call
;             (Physical page number mode)                    5600h     
;             Alter Page Map & Call
;             (Segment address mode)                         5601h     
;             Get Page Map Stack Space Size                  5602h     

EMS_FUNCTION_056h:
cmp        al, 2
je         EMS_FUNCTION_05602h
add        sp, 2
mov        word ptr cs:[page_map_call_stack_pointer], sp   ; store stack pointer
push       cx
push       si
push       di
push       bp
push       ds
push       es
push       bx
push       dx
cmp        al, 2    ; why would this have changed?
jb         PREPARE_CALL
jmp        EXITINTERRUPTA2
PREPARE_CALL:
mov        word ptr cs:[page_map_call_stored_ds], ds
mov        word ptr cs:[page_map_call_stored_si], si
mov        word ptr cs:[page_map_call_stored_ax], ax
mov        word ptr cs:[page_map_call_stored_dx], dx
xor        ch, ch
mov        cl, byte ptr [si + 4]
mov        di, word ptr [si + 5]
mov        bx, word ptr [si + 7]
mov        si, di
mov        ds, bx
mov        ah, 050h
int        067h
cmp        ah, 0
je         EMS_FUNCTION_05600h
jmp        EMS_FUNCTION_05601h  
nop        
EMS_FUNCTION_05600h:
mov        bp, word ptr cs:[page_map_call_stack_pointer]   ; sets up a function pointer to call 03211h
mov        word ptr [bp + 6], 03211h   ; replace 03211h with PAGE_MAP_CALL syntax?
mov        word ptr [bp + 8], cs
mov        ax, word ptr cs:[page_map_call_stored_ds]
mov        ds, ax
mov        si, word ptr cs:[page_map_call_stored_si]
mov        ax, word ptr [si]
mov        word ptr [bp], ax
mov        ax, word ptr [si + 2]
mov        word ptr [bp + 2], ax
mov        ax, word ptr [bp + 0eh]
mov        word ptr [bp + 4], ax
pop        dx
pop        bx
pop        es
pop        ds
pop        bp
pop        di
pop        si
pop        cx
iret

PAGE_MAP_CALL:
push       dx
push       bx
push       es
push       ds
push       bp
push       di
push       si
push       cx
pushf      
pop        bp
mov        ax, word ptr cs:[page_map_call_stored_ds]
mov        ds, ax
mov        si, word ptr cs:[page_map_call_stored_si]
mov        ax, word ptr cs:[page_map_call_stored_ax]
mov        dx, word ptr cs:[page_map_call_stored_dx]
xor        ch, ch
mov        cl, byte ptr [si + 9]
mov        di, word ptr [si + 0ah]
mov        bx, word ptr [si + 0ch]
mov        si, di
mov        ds, bx
mov        ah, 050h
int        067h
mov        bx, bp
mov        bp, word ptr cs:[page_map_call_stack_pointer]   ; get stack pointer
mov        word ptr [bp + 0eh], bx
pop        cx
pop        si
pop        di
pop        bp
pop        ds
pop        es
pop        bx
pop        dx
iret
EMS_FUNCTION_05601h:  ; the stack has been manipulated to make the call happen on iret (? not sure)
EXITINTERRUPTA2:
pop        dx
pop        bx
pop        es
pop        ds
pop        bp
pop        di
pop        si
pop        cx
add        sp, 0ah
iret

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
push       bx
push       dx
cmp        al, 1
ja         BAD_SUBFUNCTION_PARAMETER_7
xor        ah, ah
mov        word ptr cs:[stored_ax], ax
mov        ax, cs
mov        es, ax
mov        di, OFFSET func_24_region_length_low_word ; copy 18 bytes from source over...
mov        cx, 012h  ; BUG: buffer overrun? probably should be 010h, but whatever...
rep movsb
push       cs
pop        ds
cmp        word ptr [func_24_region_length_high_word], 010h  ; corresponds to an 01000h00 copy, or 1024k
jne        COPY_1024k
cmp        word ptr [func_24_region_length_low_word], 0     ; ok as long as its 1024k + 0..
COPY_1024k:
ja         COPY_TOO_BIG
cmp        byte ptr [func_24_source_memory_type], 1
ja         UNDEFINED_SOURCE_OR_DEST_TYPE
cmp        byte ptr [func_24_dest_memory_type], 1
ja         UNDEFINED_SOURCE_OR_DEST_TYPE
mov        ax, word ptr [func_24_region_length_low_word]
or         ax, word ptr [func_24_region_length_high_word]
jne        CHECK_MEMORY_TYPE_SOURCE
jmp        COPY_DONE    ; length 0
BAD_SUBFUNCTION_PARAMETER_7:
pop        dx
pop        bx
jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
COPY_TOO_BIG:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_96
;                     The memory source and destination types are undefined.
UNDEFINED_SOURCE_OR_DEST_TYPE:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_98
SOME_SORT_OF_MALFUNCTION_2:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_80
OFFSET_EXCEEDS_PAGE_SIZE:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_95
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_6:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_83
OUT_OF_RANGE_EMM_HANDLE:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_8A

CHECK_MEMORY_TYPE_SOURCE:
cmp        byte ptr [func_24_source_memory_type], 1
jne        CONVENTIONAL_MEMORY_TYPE_SOURCE
EXPANDED_MEMORY_TYPE_SOURCE:
cmp        word ptr [func_24_source_initial_offset], 03fffh
ja         OFFSET_EXCEEDS_PAGE_SIZE
mov        dx, word ptr [func_24_source_handle]
call       GET_EMM_HANDLE
jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_6
mov        ax, word ptr [get_emm_handle_result_pointer]
mov        word ptr [func_24_emm_handle_result_pointer_2], ax
mov        si, ax
mov        ax, word ptr [func_24_source_initial_seg_page]
cmp        word ptr [si], ax
jbe        OUT_OF_RANGE_EMM_HANDLE
mov        ax, 04000h
mul        word ptr [func_24_source_initial_seg_page]
add        ax, word ptr [func_24_source_initial_offset]
adc        dx, 0
add        ax, word ptr [func_24_region_length_low_word]
adc        dx, word ptr [func_24_region_length_high_word]
sub        ax, 1
sbb        dx, 0
mov        cx, 04000h
div        cx
cmp        word ptr [si], ax
jbe        OUT_OF_RANGE_EMM_HANDLE
mov        word ptr [func_24_temp_storage_3], ax
mov        word ptr [func_24_temp_storage_4], dx
jmp        CHECK_MEMORY_TYPE_DEST
CONVENTIONAL_MEMORY_TYPE_SOURCE:
mov        ax, word ptr [func_24_source_initial_seg_page]
mov        cl, 4
xor        dh, dh
mov        dl, ah
shr        dl, cl
shl        ax, 4
add        ax, word ptr [func_24_source_initial_offset]  ; dl:ax now holds source address offset (20 bit addr, no seg)
adc        dx, 0
mov        word ptr [func_24_source_initial_seg_page], dx
mov        word ptr [func_24_source_initial_offset], ax ; page:offset converted to 20 bit addr
add        ax, word ptr [func_24_region_length_low_word]
adc        dx, word ptr [func_24_region_length_high_word]
sub        ax, 1
sbb        dx, 0
cmp        dx, 010h
jne        CHECK_MEMORY_LENGTH_CONVENTIONAL_SOURCE
cmp        ax, 0
CHECK_MEMORY_LENGTH_CONVENTIONAL_SOURCE:
ja         WRAP_AROUND_1M_CONVENTIONAL_ERROR
mov        word ptr [func_24_temp_storage_3], dx
mov        word ptr [func_24_temp_storage_4], ax
mov        bx, word ptr [page_frame_segment]
rol        bx, 4
mov        cx, bx
and        bx, 0fff0h
and        cx, 0fh
cmp        dx, cx
jne        SKIP_COMPARE_1
cmp        ax, bx
SKIP_COMPARE_1:
jb         CHECK_MEMORY_TYPE_DEST
mov        dx, word ptr [func_24_source_initial_seg_page]
mov        ax, word ptr [func_24_source_initial_offset]
add        bx, 0c000h
adc        cx, 0
cmp        dx, cx
jne        SKIP_COMPARE_2
cmp        ax, bx
SKIP_COMPARE_2:
ja         CHECK_MEMORY_TYPE_DEST
jmp        OVERLAP_CONVENTIONAL_ERROR
nop        

COPY_DONE:
pop        dx
pop        bx
mov        ah, 0
cmp        byte ptr cs:[func_24_overlapping_emm_handle], 0ffh
jne        RETURN_NO_ERROR
; not an error, but 092h to say handle overlap is ok for move (not exchange)
mov        ah, 092h
RETURN_NO_ERROR:
jmp        RETURNINTERRUPTRESULT
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_7:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_83
OUT_OF_RANGE_EMM_HANDLE_2:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_8A
OVERLAP_CONVENTIONAL_ERROR:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_94
OFFSET_EXCEEDS_PAGE_SIZE_2:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_95
WRAP_AROUND_1M_CONVENTIONAL_ERROR:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_A2
CHECK_MEMORY_TYPE_DEST:
cmp        byte ptr [func_24_dest_memory_type], 1
jne        CONVENTIONAL_MEMORY_TYPE_DEST
EXPANDED_MEMORY_TYPE_DEST:
cmp        word ptr [func_24_dest_initial_offset], 03fffh
ja         OFFSET_EXCEEDS_PAGE_SIZE_2
mov        dx, word ptr [func_24_dest_handle]
call       GET_EMM_HANDLE
jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_7
mov        ax, word ptr [get_emm_handle_result_pointer]
mov        word ptr [func_24_emm_handle_result_pointer], ax
mov        si, ax
mov        ax, word ptr [func_24_dest_initial_seg_page]
cmp        word ptr [si], ax
jbe        OUT_OF_RANGE_EMM_HANDLE_2
mov        ax, 04000h
mul        word ptr [func_24_dest_initial_seg_page]
add        ax, word ptr [func_24_dest_initial_offset]
adc        dx, 0
add        ax, word ptr [func_24_region_length_low_word]
adc        dx, word ptr [func_24_region_length_high_word]
sub        ax, 1
sbb        dx, 0
mov        cx, 04000h
div        cx
cmp        word ptr [si], ax
jbe        OUT_OF_RANGE_EMM_HANDLE_2
mov        word ptr [func_24_temp_storage_5], ax
mov        word ptr [func_24_temp_storage_6], dx
jmp        DO_DESTINATION_COPY
nop        
CONVENTIONAL_MEMORY_TYPE_DEST:
; we're not actually checking for nonzero bad args i guess.
mov        ax, word ptr [func_24_dest_initial_seg_page]
mov        cl, 4
xor        dh, dh
mov        dl, ah
shr        dl, cl
shl        ax, 4
add        ax, word ptr [func_24_dest_initial_offset]
adc        dx, 0
mov        word ptr [func_24_dest_initial_seg_page], dx
mov        word ptr [func_24_dest_initial_offset], ax
add        ax, word ptr [func_24_region_length_low_word]
adc        dx, word ptr [func_24_region_length_high_word]
sub        ax, 1
sbb        dx, 0
cmp        dx, 010h
jne        CHECK_MEMORY_LENGTH_CONVENTIONAL_DEST
cmp        ax, 0
CHECK_MEMORY_LENGTH_CONVENTIONAL_DEST:

jbe        MEMORY_LENGTH_OK
jmp        WRAP_AROUND_1M_CONVENTIONAL_ERROR
MEMORY_LENGTH_OK:
mov        word ptr [func_24_temp_storage_5], dx
mov        word ptr [func_24_temp_storage_6], ax
mov        bx, word ptr [page_frame_segment]
rol        bx, 4
mov        cx, bx
and        bx, 0fff0h
and        cx, 0fh
cmp        dx, cx
jne        SKIP_COMPARE_3
cmp        ax, bx
SKIP_COMPARE_3:
jb         DO_DESTINATION_COPY
mov        dx, word ptr [func_24_dest_initial_seg_page]
mov        ax, word ptr [func_24_dest_initial_offset]
add        bx, 0c000h
adc        cx, 0
cmp        dx, cx
jne        SKIP_COMPARE_4
cmp        ax, bx
SKIP_COMPARE_4:
ja         DO_DESTINATION_COPY
jmp        OVERLAP_CONVENTIONAL_ERROR

DO_DESTINATION_COPY:
mov        byte ptr [func_24_overlapping_emm_handle], 0
mov        byte ptr [func_24_temp_storage_18], 0
cmp        byte ptr [func_24_source_memory_type], 0
jne        MEMORY_TYPE_NOT_CONVENTIONAL
cmp        byte ptr [func_24_dest_memory_type], 0
je         MEMORY_TYPE_CONVENTIONAL
jmp        CHECK_HANDLE_OVERLAP

MEMORY_TYPE_NOT_CONVENTIONAL:
cmp        byte ptr [func_24_dest_memory_type], 1
je         MEMORY_TYPE_EXPANDED   
jmp        CHECK_HANDLE_OVERLAP
MEMORY_TYPE_CONVENTIONAL:
mov        cx, word ptr [func_24_source_initial_seg_page]
mov        bx, word ptr [func_24_source_initial_offset]
mov        di, word ptr [func_24_temp_storage_3]
mov        si, word ptr [func_24_temp_storage_4]
mov        dx, word ptr [func_24_dest_initial_seg_page]
mov        ax, word ptr [func_24_dest_initial_offset]
cmp        dx, cx
jne        SKIP_COMPARE_6
cmp        ax, bx
jne        SKIP_COMPARE_6
jmp        RETURNINTERRUPTRESULT0
SKIP_COMPARE_6:
jb         SKIP_COMPARE_7
cmp        dx, di
jne        SKIP_COMPARE_8
cmp        ax, si
SKIP_COMPARE_8:
ja         CHECK_HANDLE_OVERLAP
mov        word ptr [func_24_source_initial_seg_page], di
mov        word ptr [func_24_source_initial_offset], si
mov        word ptr [func_24_temp_storage_3], cx
mov        word ptr [func_24_temp_storage_4], bx
mov        bp, word ptr [func_24_temp_storage_5]
mov        word ptr [func_24_dest_initial_seg_page], bp
mov        bp, word ptr [func_24_temp_storage_6]
mov        word ptr [func_24_dest_initial_offset], bp
mov        word ptr [func_24_temp_storage_5], dx
mov        word ptr [func_24_temp_storage_6], ax
mov        byte ptr [func_24_overlapping_emm_handle], 0ffh
mov        byte ptr [func_24_temp_storage_18], 1
jmp        CHECK_HANDLE_OVERLAP
nop        
SKIP_COMPARE_7:
mov        dx, word ptr [func_24_temp_storage_5]
mov        ax, word ptr [func_24_temp_storage_6]
cmp        dx, cx
jne        SKIP_COMPARE_5
cmp        ax, bx
SKIP_COMPARE_5:
jb         CHECK_HANDLE_OVERLAP
mov        byte ptr [func_24_overlapping_emm_handle], 0ffh
jmp        CHECK_HANDLE_OVERLAP
nop        
MEMORY_TYPE_EXPANDED:
mov        ax, word ptr [func_24_source_handle]
cmp        word ptr [func_24_dest_handle], ax
jne        CHECK_HANDLE_OVERLAP
jmp        MEMORY_TYPE_CONVENTIONAL
; cant overlap on exchange
HANDLE_OVERLAP_ERROR:
pop        dx
pop        bx
jmp        RETURNINTERRUPTRESULT_97

CHECK_HANDLE_OVERLAP:
cmp        byte ptr [func_24_overlapping_emm_handle], 0ffh
jne        HANDLE_NOT_OVERLAPPING
mov        ax, word ptr [stored_ax]
cmp        al, 1
je         HANDLE_OVERLAP_ERROR
HANDLE_NOT_OVERLAPPING:
cld        
mov        word ptr [func_24_temp_storage_22], 01000h
mov        word ptr [func_24_temp_storage_23], 1
mov        word ptr [func_24_temp_storage_21], 0
mov        word ptr [func_24_temp_storage_20], 04000h
mov        word ptr [func_24_temp_storage_19], 0
cmp        byte ptr [func_24_temp_storage_18], 0
je         BEGIN_COPYING
std        

mov        word ptr [func_24_temp_storage_22], 0f000h
mov        word ptr [func_24_temp_storage_23], 0ffffh
mov        word ptr [func_24_temp_storage_21], 0ffffh
mov        word ptr [func_24_temp_storage_20], 0ffffh
mov        word ptr [func_24_temp_storage_19], 03fffh

BEGIN_COPYING:
mov        al, 0
call       GET_PAGE_FRAME_REGISTER_FOR_INDEX
call       READEMSPORT
mov        word ptr [page_map_call_stored_dx], ax
mov        al, 1
call       GET_PAGE_FRAME_REGISTER_FOR_INDEX
call       READEMSPORT
mov        word ptr [page_map_call_stored_si], ax
cmp        byte ptr [func_24_source_memory_type], 0
jne        DO_EXPANDED_COPY
mov        ax, word ptr [func_24_source_initial_seg_page]
ror        ax, 4
mov        ds, ax
mov        si, word ptr cs:[func_24_source_initial_offset]
jmp        DO_COPY
nop        
DO_EXPANDED_COPY:
mov        si, word ptr cs:[func_24_source_initial_offset]
mov        ds, word ptr cs:[page_frame_segment]
mov        bx, word ptr cs:[func_24_source_initial_seg_page]
mov        dx, word ptr cs:[func_24_source_handle]
mov        ax, 04400h     ; DO EMS map/unmap page 0
int        067h
or         ah, ah
je         DO_COPY
jmp        SOME_SORT_OF_MALFUNCTION_2
DO_COPY:
cmp        byte ptr cs:[func_24_dest_memory_type], 0
jne        DO_COPY_TO_EXPANDED
mov        ax, word ptr cs:[func_24_dest_initial_seg_page]
ror        ax, 4
mov        es, ax
mov        di, word ptr cs:[func_24_dest_initial_offset]
cmp        byte ptr cs:[func_24_source_memory_type], 0
je         HANDLE_NEXT_BYTE_4
jmp        HANDLE_NEXT_BYTE
DO_COPY_TO_EXPANDED:
mov        ax, word ptr cs:[page_frame_segment]
add        ax, 0400h
mov        es, ax
mov        di, word ptr cs:[func_24_dest_initial_offset]
mov        bx, word ptr cs:[func_24_dest_initial_seg_page]
mov        dx, word ptr cs:[func_24_dest_handle]
mov        ax, 04401h   ; DO EMS map/unmap page 1
int        067h
or         ah, ah
je         PAGE_REMAP_WAS_OK
jmp        SOME_SORT_OF_MALFUNCTION_2

PAGE_REMAP_WAS_OK:
cmp        byte ptr cs:[func_24_source_memory_type], 0
je         HANDLE_NEXT_BYTE_3
jmp        HANDLE_NEXT_BYTE_2

HANDLE_NEXT_BYTE_4:
mov        ax, word ptr cs:[stored_ax]
cmp        ax, 0
je         OPERATION_IS_COPY_4
mov        ah, byte ptr es:[di]
mov        al, byte ptr [si]
mov        byte ptr [si], ah
stosb
lodsb
jmp        OPERATION_IS_EXCHANGE_4
nop        
OPERATION_IS_COPY_4:
movsb
OPERATION_IS_EXCHANGE_4:
sub        word ptr cs:[func_24_region_length_low_word], 1
sbb        word ptr cs:[func_24_region_length_high_word], 0
mov        ax, word ptr cs:[func_24_region_length_low_word]
or         ax, word ptr cs:[func_24_region_length_high_word]
jne        CONTINUE_IN_SAME_PAGE_4
jmp        HANDLE_PAGE_CHANGE
CONTINUE_IN_SAME_PAGE_4:
cmp        si, word ptr cs:[func_24_temp_storage_21]
jne        SKIP_SOMETHING_NOT_SURE_4
mov        ax, ds
add        ax, word ptr cs:[func_24_temp_storage_22]
mov        ds, ax
SKIP_SOMETHING_NOT_SURE_4:
cmp        di, word ptr cs:[func_24_temp_storage_21]
jne        HANDLE_NEXT_BYTE_4
mov        ax, es
add        ax, word ptr cs:[func_24_temp_storage_22]
mov        es, ax
jmp        HANDLE_NEXT_BYTE_4

HANDLE_NEXT_BYTE_3:
mov        ax, word ptr cs:[stored_ax]
cmp        al, 0
je         OPERATION_IS_COPY_3
mov        ah, byte ptr es:[di]
mov        al, byte ptr [si]
mov        byte ptr [si], ah
stosb
lodsb
jmp        OPERATION_IS_EXCHANGE_3
nop        
OPERATION_IS_COPY_3:
movsb
OPERATION_IS_EXCHANGE_3:
sub        word ptr cs:[func_24_region_length_low_word], 1
sbb        word ptr cs:[func_24_region_length_high_word], 0
mov        ax, word ptr cs:[func_24_region_length_low_word]
or         ax, word ptr cs:[func_24_region_length_high_word]
jne        CONTINUE_IN_SAME_PAGE_3
jmp        HANDLE_PAGE_CHANGE
CONTINUE_IN_SAME_PAGE_3:
call       MYSTERY_FUNCTION_7
cmp        si, word ptr cs:[func_24_temp_storage_21]
jne        HANDLE_NEXT_BYTE_3
mov        ax, ds
add        ax, word ptr cs:[func_24_temp_storage_22]
mov        ds, ax
jmp        HANDLE_NEXT_BYTE_3

HANDLE_NEXT_BYTE:
mov        ax, word ptr cs:[stored_ax]
cmp        al, 0
je         OPERATION_IS_COPY
; operation is exchange..
mov        ah, byte ptr es:[di]
mov        al, byte ptr [si]
mov        byte ptr [si], ah
stosb
lodsb
jmp        OPERATION_IS_EXCHANGE
nop        

; byte is copied, so the exchange still happens but 'exchanges' nothing
OPERATION_IS_COPY:
movsb
OPERATION_IS_EXCHANGE:
sub        word ptr cs:[func_24_region_length_low_word], 1     ; decrement counter
sbb        word ptr cs:[func_24_region_length_high_word], 0    ; with carry
mov        ax, word ptr cs:[func_24_region_length_low_word]    ; get addr
or         ax, word ptr cs:[func_24_region_length_high_word]
jne        DO_FUNC_8_1
jmp        HANDLE_PAGE_CHANGE
DO_FUNC_8_1:
call       MYSTERY_FUNCTION_8
cmp        di, word ptr cs:[func_24_temp_storage_21]
jne        HANDLE_NEXT_BYTE
mov        ax, es
add        ax, word ptr cs:[func_24_temp_storage_22]
mov        es, ax
jmp        HANDLE_NEXT_BYTE

HANDLE_NEXT_BYTE_2:
mov        ax, word ptr cs:[stored_ax]
cmp        ax, 0
je         OPERATION_IS_COPY_2
mov        ah, byte ptr es:[di]
mov        al, byte ptr [si]
mov        byte ptr [si], ah
stosb
lodsb
jmp        OPERATION_IS_EXCHANGE_2
nop        
OPERATION_IS_COPY_2:
movsb
OPERATION_IS_EXCHANGE_2:
sub        word ptr cs:[func_24_region_length_low_word], 1
sbb        word ptr cs:[func_24_region_length_high_word], 0
mov        ax, word ptr cs:[func_24_region_length_low_word]
or         ax, word ptr cs:[func_24_region_length_high_word]
jne        DO_FUNC_7_8
jmp        HANDLE_PAGE_CHANGE
nop        
DO_FUNC_7_8:
call       MYSTERY_FUNCTION_7
call       MYSTERY_FUNCTION_8
jmp        HANDLE_NEXT_BYTE_2

; seems to check bounds and change pages if necessary
MYSTERY_FUNCTION_8:
cmp        si, word ptr cs:[func_24_temp_storage_20]
jne        POINTER_NOT_EQUAL_1
mov        bx, word ptr cs:[func_24_source_initial_seg_page]
add        bx, word ptr cs:[func_24_temp_storage_23]
mov        word ptr cs:[func_24_source_initial_seg_page], bx
mov        dx, word ptr cs:[func_24_source_handle]
mov        ax, 04400h      ; DO EMS map/unmap page 0
int        067h
or         ah, ah
jne        POP_AND_RETURN
mov        si, word ptr cs:[func_24_temp_storage_19]
POINTER_NOT_EQUAL_1:
ret
POP_AND_RETURN:
pop        ax
jmp        SOME_SORT_OF_MALFUNCTION_2

; seems to check bounds and change pages if necessary
MYSTERY_FUNCTION_7:
cmp        di, word ptr cs:[func_24_temp_storage_20]
jne        POINTER_NOT_EQUAL_2
mov        bx, word ptr cs:[func_24_dest_initial_seg_page]
add        bx, word ptr cs:[func_24_temp_storage_23]
mov        word ptr cs:[func_24_dest_initial_seg_page], bx
mov        dx, word ptr cs:[func_24_dest_handle]
mov        ax, 04401h   ; DO EMS map/unmap page 1
int        067h
or         ah, ah
jne        POP_AND_RETURN
mov        di, word ptr cs:[func_24_temp_storage_19]
POINTER_NOT_EQUAL_2:
ret

HANDLE_PAGE_CHANGE:
push       cs
pop        ds
mov        al, 0
mov        bx, word ptr [page_map_call_stored_dx]
call       TURN_ON_EMS_PAGE
mov        al, 1
mov        bx, word ptr [page_map_call_stored_dx]
call       TURN_ON_EMS_PAGE
jmp        COPY_DONE

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
mov        cx, word ptr cs:[number_ems_pages]
LOOP_05800h:
mov        ax, word ptr [si]
stosw
mov        ax, word ptr [si + 2]
stosw
add        si, 4
loop       LOOP_05800h
mov        cx, word ptr cs:[number_ems_pages]
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
mov        cx, word ptr cs:[number_ems_pages]
mov        ax, 0
iret
EXITINTERRUPTB_RESULT8F:
mov        ah, 08fh
iret

;          26 Get Hardware Configuration Array               5900h     
;             Get Unallocated Raw Page Count                 5901h     

EMS_FUNCTION_059h:
cmp        al, 0
jne        NOT_05900h
EMS_FUNCTION_05900h:
push       cs
pop        ds
cmp        byte ptr [ose_function_set_enabled_1], 0ffh
jne        DENIED_BY_OS
; tasm optimizes this into mov, si
NOSMART
lea        si, word ptr [hardware_configuration_array]
SMART
;8D36 E328
push       ax
mov        ax, word ptr cs:[number_ems_pages]
shl        ax, 1
mov        word ptr [si + 4], ax
pop        ax
push       cx
mov        cx, 5
rep movsw
pop        cx
jmp        RETURNINTERRUPTRESULT0
DENIED_BY_OS:
jmp        RETURNINTERRUPTRESULT_A4
NOT_05900h:
cmp        al, 1
jne        BAD_SUBFUNCTION_PARAMETER_4
EMS_FUNCTION_05901h:
mov        dx, word ptr cs:[unallocated_page_count]
mov        bx, word ptr cs:[total_page_count]
jmp        RETURNINTERRUPTRESULT0
BAD_SUBFUNCTION_PARAMETER_4:
jmp        RETURN_BAD_SUBFUNCTION_PARAMETER


;          27 Allocate Standard Pages                        5A00h     
;             Allocate Raw Pages                             5A01h     

EMS_FUNCTION_05ah:
push       cs
pop        ds
cmp        al, 1
ja         BAD_SUBFUNCTION_PARAMETER_5
push       bx
jmp        DO_ALLOCATE_PAGE   ; i guess this maps to function 04??
BAD_SUBFUNCTION_PARAMETER_5:
jmp        RETURN_BAD_SUBFUNCTION_PARAMETER

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
cmp        byte ptr cs:[ose_function_set_enabled_1], 0ffh
jne        DENIED_BY_OS_1
cmp        al, 0
jne        NOT_05B00h
EMS_FUNCTION_05B00h:
add        sp, 0ch
mov        es, word ptr cs:[stored_es]
mov        di, word ptr cs:[stored_di]
mov        ax, es
or         ax, di
je         JUMP_TO_RETURN
push       cx
mov        cx, word ptr cs:[number_ems_pages]
call       GET_EMS_REGISTER_DATA
pop        cx
JUMP_TO_RETURN:
mov        es, word ptr cs:[stored_es]
mov        di, word ptr cs:[stored_di]
mov        bl, 0
iret
DENIED_BY_OS_1:
jmp        RETURNINTERRUPTRESULT_A4
NOT_05B00h:
cmp        al, 1
je         EMS_FUNCTION_05B01h
jmp        NOT_05B01h
nop        
EMS_FUNCTION_05B01h:
push       bx
push       dx
cmp        bl, 0
jne        DMA_REGISTER_SET_ERROR_2
mov        word ptr cs:[stored_di], di
mov        word ptr cs:[stored_es], es
mov        ax, es
or         ax, di
je         RETURN_OK_2
push       es
pop        ds
mov        si, di
push       cx
mov        cx, word ptr cs:[number_ems_pages]
call       WRITE_PAGE_MAP
pop        cx
RETURN_OK_2:
pop        dx
pop        bx
mov        ah, 0
jmp        RETURNINTERRUPTRESULT0
DMA_REGISTER_SET_ERROR_2:
pop        dx
pop        bx
mov        ah, 09ch
jmp        RETURNINTERRUPTRESULT_9C
NOT_05B01h:

cmp        al, 2
jne        NOT_05B02h
EMS_FUNCTION_05B02h:

mov        ax, word ptr cs:[number_ems_pages]
shl        ax, 1
add        ax, 2
add        ax, 2
mov        dx, ax
mov        ah, 0
jmp        RETURNINTERRUPTRESULT0
NOT_05B02h:
cmp        al, 3
jne        NOT_05B03h
mov        bl, 0
mov        ah, 0
jmp        RETURNINTERRUPTRESULT0
NOT_05B03h:
cmp        al, 4
jne        NOT_05B04h
cmp        bl, 0
jne        DMA_REGISTER_SET_ERROR
mov        ah, 0
jmp        RETURNINTERRUPTRESULT0
DMA_REGISTER_SET_ERROR:
jmp        RETURNINTERRUPTRESULT_9C
NOT_05B04h:
cmp        al, 5
jne        NOT_05B05h
mov        bl, 0
mov        ah, 0
jmp        RETURNINTERRUPTRESULT0
NOT_05B05h:
cmp        al, 6
jne        NOT_05B06h
cmp        bl, 0
jne        DMA_REGISTER_SET_ERROR
mov        ah, 0
jmp        RETURNINTERRUPTRESULT0
NOT_05B06h:
cmp        al, 7
jne        NOT_05B07h
cmp        bl, 0
jne        DMA_REGISTER_SET_ERROR
mov        ah, 0
jmp        RETURNINTERRUPTRESULT0
NOT_05B07h:
cmp        al, 8
jne        NOT_05B08h
cmp        bl, 0
jne        DMA_REGISTER_SET_ERROR
mov        ah, 0
jmp        RETURNINTERRUPTRESULT0
NOT_05B08h:
jmp        NOT_05B08h   ; BUG:  infinite loop?

;          29 Prepare Expanded Memory Hardware for Warmboot  5Ch       

EMS_FUNCTION_05Ch:
push       bx
mov        ax, cs
mov        ds, ax
mov        es, ax
NOSMART
lea        di, handle_table
SMART
push       di
xor        al, al
mov        bx, 0ffh
ZERO_OUT_HANDLE_TABLE_LOOP:
mov        cx, CONST_HANDLE_TABLE_STRUCT_SIZE
rep stosb
dec        bx
jne        ZERO_OUT_HANDLE_TABLE_LOOP
pop        di
;add        di, 2
db 081h, 0C7h, 002h, 000h
NOSMART
lea        si, [warmboot_data]
SMART
mov        cx, 8
rep movsb
NOSMART
lea        ax, page_linked_list
SMART
stosw
NOSMART
lea        di, page_linked_list
SMART
xor        ax, ax
mov        cx, 03dch
ZERO_OUT_PAGE_LINKED_LIST_LOOP:
;add        di, 2
db 081h, 0C7h, 002h, 000h
stosw
loop       ZERO_OUT_PAGE_LINKED_LIST_LOOP
mov        ax, CONST_HANDLE_TABLE_LENGTH
dec        ax
mov        word ptr [handle_count], ax
mov        ax, word ptr [unallocated_page_count]
mov        word ptr [total_page_count], ax
pop        bx
jmp        RETURNINTERRUPTRESULT0

;          30 Enable OS/E Function Set                       5D00h     
;             Disable OS/E Function Set                      5D01h     
;             Return OS/E Access Key                         5D02h     


EMS_FUNCTION_05Dh:
push       cs
pop        ds
add        sp, 0ch
cmp        al, 0
jne        NOT_05D00h
EMS_FUNCTION_05D00h:
cmp        byte ptr [ose_function_set_enabled_2], 0ffh
je         CHECK_OS_RIGHTS_PASSWORD_2
mov        bx, word ptr [os_password_low]
mov        cx, word ptr [os_password_high]
jmp        PASSWORD_OK_2
nop        
CHECK_OS_RIGHTS_PASSWORD_2:
cmp        bx, word ptr [os_password_low]
jne        DENIED_BY_OS_2
cmp        cx, word ptr [os_password_high]
jne        DENIED_BY_OS_2
PASSWORD_OK_2:
mov        byte ptr [ose_function_set_enabled_1], 0ffh
mov        byte ptr [ose_function_set_enabled_2], 0ffh
mov        ah, 0
iret
NOT_05D00h:
cmp        al, 1
jne        NOT_05D01h
EMS_FUNCTION_05D01h:
cmp        byte ptr [ose_function_set_enabled_2], 0ffh
je         CHECK_OS_RIGHTS_PASSWORD
mov        bx, word ptr [os_password_low]
mov        cx, word ptr [os_password_high]
jmp        PASSWORD_OK
nop        
CHECK_OS_RIGHTS_PASSWORD:
cmp        bx, word ptr [os_password_low]
jne        DENIED_BY_OS_2
cmp        cx, word ptr [os_password_high]
jne        DENIED_BY_OS_2
PASSWORD_OK:
mov        byte ptr [ose_function_set_enabled_1], 0
mov        byte ptr [ose_function_set_enabled_2], 0ffh
mov        ah, 0
iret

DENIED_BY_OS_2:
mov        ah, 0a4h
iret

BAD_SUBFUNCTION_PARAMETER_6:
mov        ah, 08fh
iret
NOT_05D01h:
cmp        al, 2
jne        BAD_SUBFUNCTION_PARAMETER_6
EMS_FUNCTION_05D02h:
cmp        byte ptr [ose_function_set_enabled_2], 0ffh
jne        DENIED_BY_OS_2
cmp        bx, word ptr [os_password_low]
jne        DENIED_BY_OS_2
cmp        cx, word ptr [os_password_high]
jne        DENIED_BY_OS_2
add        bh, cl
sub        ch, bl
xchg       bh, ch
rol        bx, 1
ror        cx, 1
mov        word ptr [os_password_low], bx
mov        word ptr [os_password_high], cx
mov        byte ptr [ose_function_set_enabled_1], 0ffh
mov        byte ptr [ose_function_set_enabled_2], 0
mov        ah, 0
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



; STRINGS
;03A9Dh
db 'DATATECH EMM PROGRAM END'
; 03ab5h: 3 byte structs, 0Eh of them.
;010004 020006 030008 040008 050010 060018 070020 080020 09803F 0A0020 0B803F 0C000C 0D0014 0E0030
memory_configs: 

db 01h, 00h, 04h
db 02h, 00h, 06h
db 03h, 00h, 08h
db 04h, 00h, 08h
db 05h, 00h, 10h
db 06h, 00h, 18h
db 07h, 00h, 20h
db 08h, 00h, 20h
db 09h, 80h, 3Fh
db 0Ah, 00h, 20h
db 0Bh, 80h, 3Fh
db 0Ch, 00h, 0Ch
db 0Dh, 00h, 14h
db 0Eh, 00h, 30h
; 03adfh  seems to be a dupe of mappable_384K_conventional?
mappable_384K_conventional_dupe dw 0000h
; 03ae1h  stored to seemingly never used again
mystery_value dw 0000h
; 03ae3h  stores slot pointer * 4
slotpointer_byte_times_4_word dw 0000h
; 03ae5h  stores cursor ending area from bios (00040h:0060)
cursor_ending_area dw 0000h
; 03ae7h  stores slot pointer byte
slotpointer_byte db 00h
; 03ae8h  amount of mappable memory in 256k-640k region. seems to either store 0 or 384 decimal (0180h)
mappable_384K_conventional dw 0000h
; 03aeah  
string_driver_exists db 0Dh, 0Ah, ' VL82C311 EMS has existed.',0Dh, 0Ah,0Ah, 0Ah, '$'
; 03B0Bh  
string_main_header db 0Dh, 0Ah, '===================================================', 0Dh, 0Ah, 'DTK VL82C311 Expanded Memory Manager  Ver 1.03 1992', 0Dh, 0Ah, '(C) Copyright Datatech Enterprise Co.,Ltd', 0Dh, 0Ah, 'All Rights Reserved', 0Dh, 0Ah, '#10062992', 0Dh, 0Ah, '===================================================', 0Dh, 0Ah,'$'
; 03BF8h
string_ems_not_enabled db 0Dh, 0Ah, '     EMS Disable ! $' 
; 03C0Eh
string_config_sys_page_frame_error db 0Dh, 0Ah, '     CONFIG.SYS parameter PAGE FRAME error.$'
; 03C3Ch
string_config_sys_page_port_error db 0Dh, 0Ah, '     CONFIG.SYS parameter PAGE PORT error.$'
; 03C69h
string_config_sys_ems_memory_error db 0Dh, 0Ah, '     CONFIG.SYS parameter EMS MEMORY error.$'
; 03C97h
string_ems_page_frame_prefix db 0Dh, 0Ah, '     User specified PAGE FRAME = $'

; 03CBBh
string_user_specified_ems_memory db 0Dh, 0Ah, '     User specified EMS MEMORY $'
; 03CDDh
string_user_specified_ems_backfill db 0Dh, 0Ah, '     User specified EMS backfill area = $'
; 03D07h
string_program_set_page_frame db 0Dh, 0Ah, '     Program set PAGE FRAME   = $'
; 03D2Bh
string_ems_page_frame_string db '1234H$'
; 03D31h
string_system_ram_specified_error db 0Dh, 0Ah, '     SYSTEM RAM specified error.$'
; 03D54h
string_memory_relocate_error db 0Dh, 0Ah, '     MEMORY RELOCATE specified error.$'
; 03D7Ch
string_ems_memory_specified_error db 0Dh, 0Ah, '     EMS MEMORY specified error.$'
; 03D9Fh
string_page_frame_specified_error db 0Dh, 0Ah, '     PAGE FRAME specified error.$'
; 03DC2h
string_shadow_ram_in_page_frame db 0Dh, 0Ah, '     There are SHADOW RAM in PAGE FRAME.$'

; 03DEDh
string_rom_in_page_frame db 0Dh, 0Ah, '     There are ROM ENABLE in PAGE FRAME.$'
; 03E18h
string_error_in_page db 0Dh, 0Ah, '     ERROR PAGE $'
; 03E2Bh
string_driver_successfully_installed db 0Dh, 0Ah, '     VL82C311 EMS has been installed.', 0Ah, 0Ah, 0Ah, 0Ah, 0Dh, '$'
; 03E58h
string_driver_failed_installing db 0Dh, 0Ah, '     VL82C311 EMS is not installed.', 0Ah, 0Ah, 0Ah, 0Ah, 0Dh, '$'
; 03E83h
string_testing_page db  0Dh, '     Test Expanded Memory Page '
; note this carries over
; 03EA3h
string_page_number db '0000$'
; 03EA8h
string_press_esc_to_bypass_testing db '  .... Press [Esc] to bypass testing$'
; 03ECDh
string_testing_bypassed db '  .... Testing bypassed.            $'
; 03EF2h
string_there_are db 0Dh, 0Ah, '     There are$'
; 03F03h
string_pages_for_ems db ' PAGEs for EMS.$'
; 03F13h
string_newline db 0Ah, '$'
; 03F15h
string_newline2 db 0Dh, 0Ah, '$'
; 03F18h
string_page_frames db 'C000H$C400H$C800H$CC00H$D000H$D400H$D800H$DC00H$E000H$'
; 03f4eh
page_frame_index_byte db 04h
; 03F4Fh
string_off_on db 'OFF$ON$'
; 03f56h
skip_testing_memory db 00h


DRIVER_INIT:
mov        ax, cs
mov        ds, ax
mov        word ptr [pointer_to_ems_init], 0a5h     ; overwrite pointer to this init function with pointer to "failed to install" (03fa5h)
NOSMART
lea        dx, [string_main_header]
SMART
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
NOSMART
lea        dx, [string_driver_exists]
SMART
jmp        DRIVER_NOT_INSTALLED_2

EMS_INTERRUPT_FREE:
mov        al, 3           ; register 03h  DRAM Map Register 
call       READCHIPSETREG
mov        ah, al
and        al, 0fh
cmp        al, 0
jb         INIT_ERROR_RAM
cmp        al, 0fh
jge        INIT_ERROR_RAM  ; 00fh (1111) is an invalid value for MEMAP0-3

; use 3ab5 lookup table to find this configuration value
; it's a preconfigured lookup table
; 01 0004 fail
; 02 0006 fail
; 03 0008 ok
; 04 0008 ok
; 05 0010 ok
; 06 0018 fail
; 07 0020 fail
; 08 0020 fail
; 09 803F fail
; 0A 0020 fail
; 0B 803F fail
; 0C 000C ok
; 0D 0014 fail
; 0E 0030 fail
; 3 4 5 c ok

mov        cx, 0eh
NOSMART
lea        si, memory_configs
SMART
CHECK_NEXT_STRUCT:
cmp        byte ptr [si], al
je         FOUND_RAM_CONFIG
add        si, 3
loop       CHECK_NEXT_STRUCT

; "System ram specified error"
INIT_ERROR_RAM:
NOSMART
lea        dx, [string_system_ram_specified_error]
SMART
jmp        DRIVER_NOT_INSTALLED


FOUND_RAM_CONFIG:
; ah = RAMMAP register
test       ah, 010h
je         FOUND_REMAP_384K
cmp        word ptr [si + 1], 0800h
je         FOUND_COMPATIBLEMEMMAP
cmp        word ptr [si + 1], 0c00h
je         FOUND_COMPATIBLEMEMMAP
cmp        word ptr [si + 1], 01000h
je         FOUND_COMPATIBLEMEMMAP
jmp        INIT_ERROR_RAM

; REMP384 is set. 384k is remapped. This might be incompatible with many ems features?
FOUND_REMAP_384K:
mov        word ptr [mappable_384K_conventional], 0
jmp        NO_384k
nop        

;
FOUND_COMPATIBLEMEMMAP:
mov        word ptr [mappable_384K_conventional], 0180h  ; equal to 384 decimal
NO_384k:

mov        ax, word ptr [si + 1]
add        ax, word ptr [mappable_384K_conventional]
mov        word ptr [mappable_384K_conventional_dupe], ax

mov        al, 2     ; register 02h  SLTPTR 
call       READCHIPSETREG
cmp        al, 010h            ; 010h slotpointer means at least 1M
jae        AT_LEAST_1_MEG_SLOT_POINTER
mov        al, 010h            ; adjust slot pointer downward. not sure if this actually works....

AT_LEAST_1_MEG_SLOT_POINTER:
mov        byte ptr [slotpointer_byte], al
xor        ah, ah
shl        ax, 2
mov        word ptr [slotpointer_byte_times_4_word], ax
shl        ax, 4
cmp        ax, word ptr [mappable_384K_conventional_dupe]

jb         EMS_CONFIGURED_PROPERLY
je         EMS_NOT_ENABLED
jmp        EMS_SPECIFIED_ERROR

EMS_NOT_ENABLED:
NOSMART
lea        dx, [string_ems_not_enabled]
SMART
jmp        DRIVER_NOT_INSTALLED

EMS_CONFIGURED_PROPERLY:
xchg       ax, bx
mov        ax, word ptr [mappable_384K_conventional_dupe]
sub        ax, bx
mov        word ptr [mystery_value], ax ; never accessed again?
mov        cl, 4
shr        ax, cl
mov        word ptr [unallocated_page_count], ax    ; store unallocated page count
mov        al, 0bh     ; register 0Bh EMS Configuration Register 1
call       READCHIPSETREG
or         al, 080h
mov        ah, al      ; store copy with high bit on
mov        al, 0bh     ; just write the same value back to 0bh register. mot sure why...
call       WRITECHIPSETREG
les        si, [driver_arguments]            ; load pointer to driver arguments
les        si, es:[si + 012h]
jmp        FIND_PAGE_FRAME_PARAM
nop        

; FROM THE DRIVER README:
;            F = page frame address (address of 64K window)
;                x=0  --> C000H, C400H, C800H, CC00H
;                  1  --> C400H, C800H, CC00H, D000H
;                  2  --> C800H, CC00H, D000H, D400H
;                  3  --> CC00H, D000H, D400H, D800H
;                  4  --> D000H, D400H, D800H, DC00H
;                  5  --> D400H, D800H, DC00H, E000H
;                  6  --> D800H, DC00H, E000H, E400H
;                  7  --> DC00H, E000H, E400H, E800H
;                  8  --> E000H, E400H, E800H, EC00H




GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR:
inc        si

FIND_PAGE_FRAME_PARAM:
cmp        byte ptr es:[si], 020h
je         GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR


; Check for end of parameter list...
cmp        byte ptr es:[si], 0dh
jne        NOT_0Dh
jmp        FINISHED_PARSING_DRIVER_PARAMS
nop        
NOT_0Dh:
cmp        byte ptr es:[si], 0ah
jne        NOT_0Ah
jmp        FINISHED_PARSING_DRIVER_PARAMS
nop        
NOT_0Ah:
cmp        byte ptr es:[si], 01ah
jne        NOT_01Ah
jmp        FINISHED_PARSING_DRIVER_PARAMS
nop        
NOT_01Ah:

; look for es:si to contain string 'F:0' to 'F:8'.
FIND_F0_F8:
and        byte ptr es:[si], 0dfh      ; 0DFh = 1101 1111
cmp        byte ptr es:[si], 046h      ; 046h = 'F'
je         FOUND_ASCII_F
jmp        GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR
FOUND_ASCII_F:
cmp        byte ptr es:[si + 1], 03ah
jne        GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR
cmp        byte ptr es:[si + 2], 030h
jb         GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR
cmp        byte ptr es:[si + 2], 038h
ja         GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR
; ES:SI points to 'F:0' to 'F:8'
mov        al, byte ptr es:[si + 2]
sub        al, 030h                    ; ascii to hex
mov        bh, al
mov        byte ptr [page_frame_index_byte], al       ; store the 0-8 as page frame string offset
add        si, 3
jmp        FIND_PAGE_FRAME_PARAM

; UNUSED ERROR CODES
NOSMART
lea        dx, [string_config_sys_page_frame_error]
SMART
jmp        DRIVER_NOT_INSTALLED
NOSMART
lea        dx, [string_config_sys_page_port_error]
SMART
jmp        DRIVER_NOT_INSTALLED
NOSMART
lea        dx, [string_config_sys_ems_memory_error]
SMART
jmp        DRIVER_NOT_INSTALLED

FINISHED_PARSING_DRIVER_PARAMS:
NOSMART
lea        dx, [string_ems_page_frame_prefix]
SMART
call       PRINT_STRING
mov        al, byte ptr [page_frame_index_byte]   ; store page frame string offset
mov        bl, 6                   ; 6 bytes per string... used to get string offset.
mul        bl
NOSMART
lea        dx, [string_page_frames]            ; get EMS page frame string
SMART
add        dx, ax                  ; add offset to get the exact page frame string
call       PRINT_STRING
xor        ah, ah
mov        al, bh
call       FIND_BIOSES
xor        ah, ah
mov        al, byte ptr [page_frame_index_byte]
call       CHECK_IF_VALID_PAGE_FRAME
mov        word ptr [page_frame_segment], ax                 ; store used page frame
NOSMART
lea        dx, [string_program_set_page_frame]   ;  Program set PAGE FRAME   = $1234H$
SMART
call       PRINT_STRING

push       es
push       di
push       cs
pop        es
mov        di, offset string_ems_page_frame_string        ; 
call       HEX_WORD_TO_ASCII
NOSMART
lea        dx, [string_ems_page_frame_string]
SMART
call       PRINT_STRING
pop        di
pop        es
jmp        DONE_PRINTING_PAGE_FRAME
nop        

; EMS SPECIFIED ERROR
EMS_SPECIFIED_ERROR:
NOSMART
lea        dx, [string_ems_memory_specified_error]
SMART
jmp        DRIVER_NOT_INSTALLED


;UNUSED CHECK FOR BACKFILL PARAMETER!!!
; look for es:si to contain string 'B:0' or 'B:1'. store 0 or 1 into 028edh. then increment si by 3
FIND_B0_B1:
jmp        GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR
cmp        byte ptr es:[si], 042h
jne        FIND_B0_B1
cmp        byte ptr es:[si + 1], 03ah
jne        FIND_B0_B1
cmp        byte ptr es:[si + 2], 030h
jb         FIND_B0_B1
cmp        byte ptr es:[si + 2], 031h
ja         FIND_B0_B1
mov        al, byte ptr es:[si + 2]
sub        al, 030h
mov        byte ptr [backfill_enabled], al
add        si, 3
jmp        FIND_PAGE_FRAME_PARAM

DONE_PRINTING_PAGE_FRAME:
cmp        byte ptr [backfill_enabled], 0
je         BACKFILL_NOT_ENABLED
mov        word ptr [number_ems_pages], 024h  ; has backfill, 36 pages
jmp        BACKFILL_IS_ENABLED
nop        

BACKFILL_NOT_ENABLED:
mov        word ptr [number_ems_pages], 0ch  ; no backfill, only 12 pages
BACKFILL_IS_ENABLED:

mov        word ptr [upper_C000toEC00_non_rom_pages], 0
mov        bx, OFFSET bios_in_upper_pages
mov        cx, 0ch
; loop 0ch times, check bytes for bios presence
CHECK_NEXT_PAGE_SETTING:
NOSMART
cmp        byte ptr cs:[bx], 0ffh
SMART
jne        MARK_NON_BIOS_PAGE
sub        word ptr [number_ems_pages], 1      ; bios page so subtract 1 from total pages
jmp        CONTINUE_LOOP_A
nop        

MARK_NON_BIOS_PAGE:
; add one free page found
add        word ptr cs:[upper_C000toEC00_non_rom_pages], 1
CONTINUE_LOOP_A:
inc        bx
loop       CHECK_NEXT_PAGE_SETTING


; The following segment of code fills up the page_frame_segment_to_ems_index_port_map_byte structure with the ems register to page frame segment map.
; first four will be the page frame. then the next entries will be the other mappable upper memory pages.
; first the pages before the page frame (unless its c000) will be added, then the ones after

mov        ax, word ptr [page_frame_segment]
mov        si, OFFSET page_frame_segment_to_ems_index_port_map_byte
mov        cx, 4
CONTINUE_WRITING_PAGE_FRAME_INFO:
mov        bx, ax
sub        bx, 0c000h
shr        bx, 0ah             ; bx has the page frame index (i.e. 0 is c000, 4 is d000)
mov        word ptr [si], ax
mov        byte ptr [si + 2], bl
add        si, 3
add        ax, 0400h
loop       CONTINUE_WRITING_PAGE_FRAME_INFO

mov        dx, ax
cmp        word ptr [page_frame_segment], 0c000h
je         CONTINUE_FINDING_ROM_SEGMENTS_AFTER_PAGE_FRAME  

; initial condition
mov        ax, 0c000h
CONTINUE_FINDING_ROM_SEGMENTS_BEFORE_PAGE_FRAME:
mov        bx, ax
sub        bx, 0c000h
shr        bx, 0ah
NOSMART
cmp        byte ptr cs:[bx + bios_in_upper_pages], 0ffh
SMART
je         PAGE_IS_ROM

mov        word ptr [si], ax
mov        byte ptr [si + 2], bl
add        si, 3

PAGE_IS_ROM:
add        ax, 0400h
cmp        ax, word ptr [page_frame_segment]
jne        CONTINUE_FINDING_ROM_SEGMENTS_BEFORE_PAGE_FRAME
mov        ax, dx
cmp        ax, 0f000h
je         FINISHED_SEARCHING_PRE_PAGE_FRAME_ROM_SEGMENTS

CONTINUE_FINDING_ROM_SEGMENTS_AFTER_PAGE_FRAME:
mov        bx, ax
sub        bx, 0c000h
shr        bx, 0ah
NOSMART
cmp        byte ptr cs:[bx + bios_in_upper_pages], 0ffh
SMART
je         FOUND_LAST_ENTRY
mov        word ptr [si], ax
mov        byte ptr [si + 2], bl
add        si, 3
FOUND_LAST_ENTRY:
add        ax, 0400h
cmp        ax, 0f000h
jne        CONTINUE_FINDING_ROM_SEGMENTS_AFTER_PAGE_FRAME

FINISHED_SEARCHING_PRE_PAGE_FRAME_ROM_SEGMENTS:
cmp        byte ptr [backfill_enabled], 0
je         SKIP_BACKFILL_REGISTERS

mov        bl, 0ch
mov        ax, 04000h
mov        cx, 018h
CONTINUE_WRITING_BACKFILL_REGISTERS:
mov        byte ptr [si + 2], bl
mov        word ptr [si], ax
inc        bl
add        si, 3
add        ax, 0400h
loop       CONTINUE_WRITING_BACKFILL_REGISTERS

SKIP_BACKFILL_REGISTERS:
mov        ax, word ptr [page_frame_segment]
mov        es, ax
mov        al, 080h
out        061h, al           ; clear keyboard port (?)
push       ds
push       040h
pop        ds
; 0400h is BDA (BIOS data area)
;mov        ax, word ptr [060h]   ; 	bios data segment "Cursor ending (bottom) scan line"
; todo fix
db 0A1h, 060h, 000h 

pop        ds
mov        word ptr [cursor_ending_area], ax
mov        cx, 0f00h
mov        ah, 1
int        010h               ; Set Cursor Type 00f00h
mov        cx, word ptr [unallocated_page_count]
mov        bx, word ptr [slotpointer_byte_times_4_word]

; going to mark all pageable memory FFEE all over

MARK_NEXT_PAGE_FFFE:
xor        al, al
call       TURN_ON_EMS_PAGE  ; turn on ems page 0...
push       cx
mov        cx, 02000h   ; do this for 8192 words or 16384 bytes
mov        ax, 0fffeh
xor        di, di
rep stosw ; es points to page frame segment. BUG: Never gets updated for backfill segment?
pop        cx
inc        bx
loop       MARK_NEXT_PAGE_FFFE

mov        bp, word ptr [unallocated_page_count]
xor        ax, ax
mov        word ptr [unallocated_page_count], ax
NOSMART
lea        si, page_linked_list                     ; we arent using this pointer for anything right now...
SMART
cmp        byte ptr [backfill_enabled], 0
je         NO_BACKFILL_ENABLED
add        si, 060h
NO_BACKFILL_ENABLED:
; bunch of stuff to print page frame...
mov        ax, 0
mov        cl, 4
mul        cl
add        si, ax
mov        bx, word ptr [slotpointer_byte_times_4_word]
NOSMART
lea        dx, [string_newline]
SMART
call       PRINT_STRING
mov        ax, word ptr [unallocated_page_count]
NOSMART
lea        dx, [string_testing_page]
SMART
call       PRINT_STRING
NOSMART
lea        dx, [string_press_esc_to_bypass_testing]
SMART
call       PRINT_STRING
NEXT_PAGE_MEMORY_TEST_ITER:
inc        ax
push       ax
call       SET_UP_STRING_DIGITS
NOSMART
lea        dx, [string_testing_page]
SMART
call       PRINT_STRING
cmp        byte ptr [skip_testing_memory], 1
jne        NOT_SKIPPING_MEMORY_TEST
jmp        CURRENT_PAGE_FINISHED_TESTING

NOT_SKIPPING_MEMORY_TEST:
mov        ah, 1
int        016h
je         BREAK_KEY_NOT_PRESSED
mov        ah, 0
int        016h       ; int 16,1 get keyboard status
cmp        al, 01bh   ; check for break key
jne        BREAK_KEY_NOT_PRESSED
mov        byte ptr [skip_testing_memory], 1 ; skip testing
NOSMART
lea        dx, [string_testing_page]
SMART
call       PRINT_STRING
NOSMART
lea        dx, [string_testing_bypassed]
SMART
call       PRINT_STRING

BREAK_KEY_NOT_PRESSED:
mov        cx, 4
xor        al, al
TURN_ON_NEXT_PAGE:
call       TURN_ON_EMS_PAGE
inc        al
loop       TURN_ON_NEXT_PAGE
; scan for word 01234h in page. this wont be there. i assume this is to check that the memory is mapped and readable.
; some interrupt would fire on a bad read?
mov        ax, 01234h
mov        cx, 02000h
xor        di, di
rep scasw 

; lets do it again for some reason. 
mov        ax, 01234h
mov        cx, 02000h
xor        di, di
rep scasw 

in         al, 061h
mov        ah, al
or         ah, 0ch    ; ; turn on the keypress bits from 61h
and        al, 0f3h   
mov        cx, 2
;check for keypress twice or something? not sure? not important?
OUT_LOOP:
xchg       al, ah
out        061h, al     ; 
jmp        NOP_1     ; nop
NOP_1:
jmp        NOP_2     ; nop
NOP_2:
loop       OUT_LOOP 

mov        ax, 0fffeh
xor        di, di


; Up ahead we are basically going to check the page to make sure its all 0FFFEh. this was written above.
; then we will write all 0AA55h and check for that. then we will write all 055AAh and check for that. Then 00101h.
; then finally we zero out memory in the page.

CHECK_PAGE_FOR_PATTERN:
mov        cx, 02000h
; check that the last write made it thru

LOOP_CHECK_PAGE_FOR_PATTERN:
cmp        word ptr es:[di], ax
jne        READ_MISMATCH
READ_OK:
add        di, 2
loop       LOOP_CHECK_PAGE_FOR_PATTERN

jmp        DETERMINE_NEXT_PATTERN
nop        
push       ax
in         al, 061h
test       al, 0c0h
pop        ax
je         DETERMINE_NEXT_PATTERN
jmp        PRINT_MEMORY_ERROR_FOUND
nop        


; earlier write of 0fffeh was not found. but we are checkign a second time for some reason.
READ_MISMATCH:
cmp        word ptr es:[di], ax
jmp        NOP_3
NOP_3:
jne        PRINT_MEMORY_ERROR_FOUND
jmp        READ_OK
DETERMINE_NEXT_PATTERN:
cmp        ax, 0fffeh
je         AX_WAS_FFFE
cmp        ax, 0aa55h
je         AX_WAS_AA55
cmp        ax, 055aah
je         AX_WAS_55AA
jmp        AX_WAS_SOMETHING_ELSE
nop        

AX_WAS_FFFE:
; next we do 0AA55h
mov        ax, 0aa55h
jmp        WRITE_AX_TO_PAGE
nop        
AX_WAS_AA55:
; next we do 055AAh
mov        ax, 055aah
jmp        WRITE_AX_TO_PAGE
nop        
AX_WAS_55AA:
; next we do 00101h
mov        ax, 0101h

WRITE_AX_TO_PAGE:
sub        di, 04000h
mov        cx, 02000h
rep stosw
jmp        CHECK_PAGE_FOR_PATTERN
AX_WAS_SOMETHING_ELSE:
; now lets finally zero out memory
xor        di, di
xor        ax, ax
mov        cx, 02000h
rep stosw

CURRENT_PAGE_FINISHED_TESTING:
; this page is done.
mov        word ptr [si], bx
add        si, 4
inc        word ptr [unallocated_page_count]

DO_NEXT_PAGE_MEMORY_TEST_ITER:
pop        ax
dec        bp
je         MEMORY_TEST_DONE
inc        bx
jmp        NEXT_PAGE_MEMORY_TEST_ITER

; print memory error found but continue the loop
PRINT_MEMORY_ERROR_FOUND:
NOSMART
lea        dx, [string_error_in_page]
SMART
call       PRINT_STRING
NOSMART
lea        dx, [string_page_number]
SMART
call       PRINT_STRING
jmp        DO_NEXT_PAGE_MEMORY_TEST_ITER

MEMORY_TEST_DONE:
; print how many pages there are
NOSMART
lea        dx, [string_there_are]
SMART
call       PRINT_STRING
mov        ax, word ptr [unallocated_page_count]
mov        word ptr [total_page_count], ax
call       SET_UP_STRING_DIGITS
NOSMART
lea        dx, [string_page_number]
SMART
call       PRINT_STRING
NOSMART
lea        dx, [string_pages_for_ems]
SMART
call       PRINT_STRING
in         al, 061h
jmp        NOP_4
nop        
NOP_4:
or         al, 0ch
out        061h, al
jmp        NOP_5
nop        
NOP_5:
and        al, 0f3h
out        061h, al
nop        
nop        
; undo cursor stuff
mov        al, 0fh
out        070h, al
mov        cx, word ptr [cursor_ending_area]
mov        ah, 1
int        010h
mov        cx, 4
mov        al, 0

TURN_OFF_NEXT_PAGE_LOOP:
call       TURN_OFF_EMS_PAGE
inc        al
loop       TURN_OFF_NEXT_PAGE_LOOP


; now we are mostly calculating allocatable pages...

mov        ax, word ptr [unallocated_page_count]
mov        word ptr [total_page_count], ax
cmp        byte ptr [backfill_enabled], 0
je         NO_BACKFILL_FOR_PAGE_COUNT
; add 24 pages to unallocated count for the backfill registers.
add        word ptr [unallocated_page_count], 018h
NO_BACKFILL_FOR_PAGE_COUNT:
NOSMART
lea        si, page_linked_list
SMART

cmp        byte ptr [backfill_enabled], 0
je         NO_BACKFILL_HERE_EITHER
; backfill is enabled..
mov        cx, 018h
mov        bx, 0
mov        ax, 04000h
shr        ax, 0ah                ; page register index (not ems page frame segment)
WRITE_NEXT_BACKFILL_PAGE_DATA:
mov        word ptr [si], ax
mov        word ptr [si + 2], si
add        word ptr [si + 2], 4
add        ax, 1
add        si, 4
loop       WRITE_NEXT_BACKFILL_PAGE_DATA
mov        word ptr [si - 2], 0ffffh  ; why is this happening

NO_BACKFILL_HERE_EITHER:
cmp        word ptr [mappable_384K_conventional], 0
jne        MAPPABLE_384K
mov        ax, 0c000h
shr        ax, 0ah
mov        bx, OFFSET bios_in_upper_pages
mov        cx, 0ch

CHECK_NEXT_PAGE_FOR_ROM:
NOSMART
cmp        byte ptr cs:[bx], 0ffh
SMART
je         PAGE_IS_ROM_B
mov        word ptr [si], ax
add        si, 4
add        word ptr [unallocated_page_count], 1
PAGE_IS_ROM_B:
add        ax, 1
inc        bx
loop       CHECK_NEXT_PAGE_FOR_ROM

MAPPABLE_384K:
NOSMART
lea        si, handle_table
SMART
mov        word ptr [handle_table_pointer], si
NOSMART
lea        ax, page_linked_list
SMART
mov        word ptr [si + 0ah], ax
cmp        byte ptr [backfill_enabled], 0
je         BACKFILL_NOT_ENABLED_2

; do this only for backfill..
; we are initializing the EMS registers for backfill areas to point to their default locations. (pages 010h....)
; this seems like a weird place to start, but ok. they shouild probably default to -1 (conventional) or 0Ch... since there are 0Ch upper pages, max.
mov        word ptr [si], 018h
mov        cx, 018h
mov        dx, 010h
mov        al, 0ch
LOOP_WRITE_TO_EMS_PORT:
call       WRITEEMSPORT
add        al, 1
add        dx, 1
loop       LOOP_WRITE_TO_EMS_PORT
mov        al, 0bh
; here we write EMSENAB to register 00Bh again for some reason. this shouldn't be here unless it were already on?
call       READCHIPSETREG
or         al, 040h
mov        ah, al
mov        al, 0bh
call       WRITECHIPSETREG

BACKFILL_NOT_ENABLED_2:
mov        ax, CONST_HANDLE_TABLE_LENGTH
dec        ax
mov        word ptr [handle_count], ax
NOSMART
lea        si, page_linked_list
SMART
mov        word ptr [page_linked_list_pointer], si
mov        ax, word ptr [unallocated_page_count]
mov        bx, 4
mul        bx
add        si, ax
mov        word ptr [end_of_page_linked_list], si
mov        si, OFFSET mappable_phys_page_struct
mov        ax, 04000h
LOOK_FOR_NEXT_PAGE_REGISTER:
mov        cx, word ptr [number_ems_pages]
mov        bx, OFFSET page_frame_segment_to_ems_index_port_map_byte
mov        dx, 0
LOOK_FOR_PAGE_REGISTER_DATA_LOOP:
cmp        ax, word ptr [bx]
je         FOUND_PAGE_REGISTER_DATA
add        bx, 3
inc        dx
loop       LOOK_FOR_PAGE_REGISTER_DATA_LOOP
jmp        NO_PAGE_REGISTER_DATA
nop        
FOUND_PAGE_REGISTER_DATA:
mov        word ptr [si], ax
mov        word ptr [si + 2], dx
add        si, 4
NO_PAGE_REGISTER_DATA:
add        ax, 0400h
cmp        ax, 0f000h
jne        LOOK_FOR_NEXT_PAGE_REGISTER

; generate OS rights password
mov        ah, 0
int        01ah       ; Read System Clock Counter
add        dh, cl
sub        ch, dl
xchg       dh, ch
mov        bx, cx
mov        word ptr [os_password_low], bx
mov        cx, dx
mov        word ptr [os_password_high], cx

; set interrupt vector  067h
NOSMART
lea        dx, MAIN_EMS_INTERRUPT_VECTOR
SMART
mov        al, 067h
mov        ah, 025h
int        021h

DRIVER_INSTALLED:
NOSMART
lea        dx, [string_driver_successfully_installed]
SMART
call       PRINT_STRING
les        bx, [driver_arguments]
mov        word ptr es:[bx + 3], 0100h
mov        ax, OFFSET memory_configs
mov        word ptr es:[bx + 0eh], ax
mov        word ptr es:[bx + 010h], cs
ret

; DRIVER NOT INSTALLED
; preloaded with string 'reason' for the print string
DRIVER_NOT_INSTALLED:
call       PRINT_STRING 
NOSMART
lea        dx, [string_driver_failed_installing]
SMART
DRIVER_NOT_INSTALLED_2:
call       PRINT_STRING
les        bx, [driver_arguments]
mov        word ptr es:[bx + 3], 0810ch
mov        word ptr es:[bx + 0eh], 0
mov        word ptr es:[bx + 010h], cs
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

; takes string_page_number string offset and sets it up in format of spaces and 0s according to input AX's digit count in decimal.
; i.e. input AX = 0110h = 272. string becomes ' 000'. input 20 because '  00'.
SET_UP_STRING_DIGITS:
push       ax
push       bx
push       cx
push       dx
push       di
push       es
push       cs
pop        es
push       ax
NOSMART
lea        di, [string_page_number]
SMART
mov        ax, 02020h
mov        cx, 2
cld        
rep stosw       ; write two spaces (020h) to string two times. four in total (overwriting old string)
pop        ax
DO_NEXT_DIGIT:
xor        dx, dx
mov        bx, 0ah
div        bx                         ; divide by AX input by 10
xchg       ax, dx                     ; dx = ax / 10. AX = 0.
add        al, 030h                   ; al = '0'
dec        di                         ; move backward in string a character
mov        byte ptr [di], al          
mov        ax, dx                     ; ax = ax / 10
cmp        dx, 0                      ; if dx > 0
jne        DO_NEXT_DIGIT              ; then do this for one more digit..
pop        es
pop        di
pop        dx
pop        cx
pop        bx
pop        ax
ret


; calls GET_ASCII_CHAR four four nibbles of the word to generate four ascii values. result stored in es:di
HEX_WORD_TO_ASCII:
push       ax
push       bx
push       cx
push       dx
mov        bx, ax
mov        al, bh
shr        al, 4
call       GET_ASCII_CHAR
mov        al, bh
and        al, 0fh
call       GET_ASCII_CHAR
mov        al, bl
shr        al, 4
call       GET_ASCII_CHAR
mov        al, bl
and        al, 0fh
call       GET_ASCII_CHAR
pop        dx
pop        cx
pop        bx
pop        ax
ret

; seems like alphanumeric encoding. 0-9 value is '0' indexed ascii, 0Ah and up is 'a' indexed ascii
; Hexadecimal nibble to ascii char function. result stored in es:di
GET_ASCII_CHAR:
cmp        al, 0ah
jae        CHAR_A_TO_F
add        al, 030h
jmp        CHAR_CONVERTED
nop        
CHAR_A_TO_F:
sub        al, 0ah
add        al, 041h
CHAR_CONVERTED:
stosb
ret


; Takes in page frame index in al  (0 = c000h, 1 = c400h... 8 = e000h);
; checks to see if there are no pageable frames from [al ... al+3] with rom fragments.
; if there are rom fragments, a scan of c000 to ec00 is done to try and find four consecutive fragments.
; returns page frame start segment in AX  
; doesn't seem to gracefully handly any error case
CHECK_IF_VALID_PAGE_FRAME:
push       ds
push       bx
push       cx
push       dx

; this seems to do nothing. bh is clobbered the next line anyway

cmp        al, 4
jbe        AL_LTE_4
mov        bh, 0

AL_LTE_4:
mov        bx, ax
mov        cx, 4

; scan desired 64k page region four four non-rom pages.
KEEP_SEARCHING_FOR_ROM_PAGE_B:
cmp        byte ptr [bx + bios_in_upper_pages], 0ffh
je         FOUND_ROM_PAGE_B
add        bx, 1
loop       KEEP_SEARCHING_FOR_ROM_PAGE_B

; didnt find FF
mov        bx, ax
shl        bx, 1
mov        ax, word ptr cs:[bx + page_frame_segment_values]  ; set ax equal to c000 c400 etc
jmp        EXIT_FUNCTION_B
nop        

; there was a ROM in the desired 64k page frame range. lets scan the whole pageable upper region for four consecutive free pages.
FOUND_ROM_PAGE_B:
; this is a page with ROM
xor        bx, bx
mov        dx, bx
RESTART_LOOP:
mov        cx, 4      ; look for four consecutive clear pages again
CHECK_NEXT_PAGE:
NOSMART
cmp        byte ptr cs:[bx + bios_in_upper_pages], 0ffh
SMART
je         FOUND_ROM_PAGE
add        bx, 1
loop       CHECK_NEXT_PAGE
mov        bx, dx
shl        bx, 1
mov        ax, word ptr cs:[bx + page_frame_segment_values]
jmp        EXIT_FUNCTION_B
nop        
FOUND_ROM_PAGE:
add        dx, 1
mov        bx, dx
cmp        bx, 4
jbe        RESTART_LOOP
EXIT_FUNCTION_B:
pop        dx
pop        cx
pop        bx
pop        ds
ret


FIND_BIOSES:
push       ax
push       bx
mov        ax, 0c000h
LOOP_DO_CHECKSUM:
call       DO_CHECKSUM
jae        NO_BIOS_FOUND
push       ax
push       bx
push       cx
push       ax
push       ax
sub        ax, 0c000h
shr        ax, 0ah        ; ax is now page frame index..
pop        cx             ; cx is tested bios fragment
shl        cx, 6          ; page frame part is shifted out. if zero then we have c400 c800 etc segment
je         HAVE_SEGMENT        
inc        ax             ; otherwise we have a segment like c480 c880 etc. so we are incrementing the page frame index
HAVE_SEGMENT:
pop        bx             ; bx is now tested bios segment
sub        bx, dx         ; dx is byte size of last segment
sub        bx, 0c000h     ; subtract page frame... we have an offset.
shr        bx, 0ah        ; shift right
; based on size of bios and how many page frames it carries over, lets mark all those pages as having bios in them
CONTINUE_RECORDING_BIOS_FRAGMENT:
cmp        bx, ax         ; bx and ax are both some page frame segments.
jae        DONE_RECORDING_BIOS_FRAGMENT         
mov        byte ptr cs:[bx + bios_in_upper_pages], 0ffh ; mark bios found
inc        bx             ; inc fragment
jmp        CONTINUE_RECORDING_BIOS_FRAGMENT
DONE_RECORDING_BIOS_FRAGMENT:
pop        cx
pop        bx
pop        ax
NO_BIOS_FOUND:
; stop before F000
cmp        ax, 0ef80h
jbe        LOOP_DO_CHECKSUM

pop        bx
pop        ax
ret


; this checks to see if the segment in AX points to a BIOS.
; return carry flag if it is
; dx returns bios segment size. 080h if nothing (test next one) otherwise numbers of segments. 
DO_CHECKSUM:
push       ds
push       bx
push       cx
push       si
mov        ds, ax
xor        bx, bx
cmp        word ptr [bx], 0aa55h
jne        RETURN_NO_CARRY_FLAG_2
xor        si, si
xor        cx, cx
mov        cl, byte ptr [bx + 2]      ; cl * 512 = bios size
shl        cx, 9
mov        dx, cx
CONTINUE_CHECKSUMMING:
lodsb
add        bl, al
loop       CONTINUE_CHECKSUMMING
jne        RETURN_NO_CARRY_FLAG_2
shr        dx, 4
mov        ax, ds
add        ax, dx
RETURN_CARRY_FLAG_2:
stc        
jmp        CONTINUE_RETURN
nop        
RETURN_NO_CARRY_FLAG_2:
mov        dx, 080h
mov        ax, ds
add        ax, dx
clc        
CONTINUE_RETURN:
pop        si
pop        cx
pop        bx
pop        ds
ret     

END
