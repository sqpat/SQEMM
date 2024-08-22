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
;0009Fh
RETURN_SUCCESS:
mov  word ptr [bx + 3], 0100h
ret  
;000a5h

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
; 144 bytes long 
; i think a clone of the above struct in practice except pre-formatted for return in function 5800h (2nd arg a word, ordered lowest segment first)
mappable_phys_page_struct:
dw 04000h, 000Ch, 04400h, 000Dh, 04800h, 000Eh, 04C00h, 000Fh
dw 05000h, 0010h, 05400h, 0011h, 05800h, 0012h, 05C00h, 0013h
dw 06000h, 0014h, 06400h, 0015h, 06800h, 0016h, 06C00h, 0017h
dw 07000h, 0018h, 07400h, 0019h, 07800h, 001Ah, 07C00h, 001Bh
dw 08000h, 001Ch, 08400h, 001Dh, 08800h, 001Eh, 08C00h, 001Fh
dw 09000h, 0020h, 09400h, 0021h, 09800h, 0022h, 09C00h, 0023h
dw 0D000h, 0000h, 0D400h, 0001h, 0D800h, 0002h, 0DC00h, 0003h
dw 0E000h, 0004h, 0E400h, 0005h, 0E800h, 0006h, 0EC00h, 0007h
dw 0C000h, 0008h, 0C400h, 0009h, 0C800h, 000Ah, 0CC00h, 000Bh 

 


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

cmp        bx, word ptr [unallocated_page_count]
ja         ARG_BX_ABOVE_PAGE_COUNT
cmp        bx, word ptr [total_page_count]
ja         ARG_BX_ABOVE_TOTAL_PAGE_COUNT

cmp        word ptr [handle_count], 0
je         NO_HANDLES_LEFT
mov        si, word ptr [handle_table_pointer]

jmp         FOUND_PAGES_FOR_ALLOCATION

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

FOUND_PAGES_FOR_ALLOCATION:

ALLOCATE_SUCCESS:
sub word ptr [unallocated_page_count], bx

dec word ptr [handle_count]
pop        bx
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

ENOUGH_PAGES:
cmp        dx,  1
jne        RETURN_RESULT_83
nop        
FOUND_EMM_HANDLE:
call       TURN_OFF_EMS_PAGE
cmp        bx, -1
je         RETURN_RESULT_00

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


cmp bx, 1
jne  NO_EMM_HANDLE_FOUND

GOOD_EMM_HANDLE:

add        word ptr [unallocated_page_count], bx
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



;          14 Get All Handle Pages                           4Dh       
; we write all handles and their page counts to es:di
EMS_FUNCTION_04Dh:

mov   word ptr es:[di], 0000h
mov   word ptr es:[di+2], 0000h
mov   word ptr es:[di+4], 0001h
mov   word ptr es:[di+6], 0100h
; one handle plus one?
mov   bx, 2


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
string_driver_exists db 0Dh, 0Ah, ' EMS Driver already exists (chaining not supported).',0Dh, 0Ah,0Ah, 0Ah, '$'
; 03B0Bh  
string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for VL82C311', 0Dh, 0Ah,'$'
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
string_driver_successfully_installed db 0Dh, 0Ah, 'SQEMM successfully initialized.', 0Ah, 0Dh, '$'
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
mov        word ptr [pointer_to_ems_init], OFFSET RETURN_UNRECOGNIZED_COMMAND     ; overwrite pointer to this init function with pointer to "failed to install" (03fa5h)
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

; do actual driver preparation here
; todotodo

; hard coded to d000 for now
mov        word ptr [page_frame_segment], 0D000h

; 256 pages hardcoded for now
mov        word ptr [unallocated_page_count], 256
mov        word ptr [total_page_count], 256

; ok?
mov        word ptr [number_ems_pages], 36

; one handle for now
mov        word ptr [handle_count], 01h

; prep this pointer
lea        si, handle_table
mov        word ptr [handle_table_pointer], si



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
; 0610h?  ;1006h?
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
; todo whats this
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

END
