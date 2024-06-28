; overview of file:
; first 0xA bytes: standard sys header
; up to 0x62: random data
; 0x62 to 0xBD: entry points to driver
; then several thousand bytes of data
; then the main code, including accessory functions, ems functions, and driver init entry point.



.DATA
;0x0000
dw 0FFFFh
dw 0FFFFh
dw 0080h

;dw 6200h
dw OFFSET EMS_DRIVER_INIT
;dw 6D00h
dw OFFSET EMS_DRIVER_CALL

;0x000A
STRING 'EMMXXXX0 DTK VL82C311 Expended Memory Manager V 1.03  06/29/92'

;0x0048
pointer_to_ems_init dw 573Fh

;0x004A various pointers to various possible entry points - most go to "unrecognized command"
dw A500h 
dw A500h 
dw A500h 
dw A500h 
dw A500h 
;0x0054 Seems to be the pointer used in ems_driver_call?
dw A500h 
dw A500h 
dw A500h 
dw A500h 
dw 9F00h 
dw A500h 
dw A500h

; 0x0062
EMS_DRIVER_INIT:
0x0062:  2E 89 1E 71 28    mov  word ptr cs:[driver_arguments], bx        ; store 32 bit pointer to arguments to 0x2871
0x0067:  2E 8C 06 73 28    mov  word ptr cs:[driver_arguments+2], es        
0x006c:  CB                retf 

EMS_DRIVER_CALL:
0x006d:  52                push dx
0x006e:  51                push cx
0x006f:  53                push bx
0x0070:  50                push ax
0x0071:  56                push si
0x0072:  57                push di
0x0073:  1E                push ds
0x0074:  06                push es
0x0075:  55                push bp
0x0076:  0E                push cs
0x0077:  1F                pop  ds
0x0078:  8B 1E 71 28       mov  bx, word ptr [driver_arguments]
0x007c:  8E 06 73 28       mov  es, word ptr [driver_arguments+2]
0x0080:  26 8B 47 02       mov  ax, word ptr es:[bx + 2]
0x0084:  B4 00             mov  ah, 0
0x0086:  3C 0C             cmp  al, 0xc
0x0088:  72 02             jb   CHECK_SOMETHING_IN_PARAMS ; not sure what we're checking or doing here exactly...
0x008a:  B0 0C             mov  al, 0xc
CHECK_SOMETHING_IN_PARAMS:
0x008c:  D1 E0             shl  ax, 1
0x008e:  BE 48 00          mov  si, OFFSET pointer_to_ems_init
0x0091:  03 F0             add  si, ax
0x0093:  FF 14             call word ptr [si]
0x0095:  5D                pop  bp
0x0096:  07                pop  es
0x0097:  1F                pop  ds
0x0098:  5F                pop  di
0x0099:  5E                pop  si
0x009a:  58                pop  ax
0x009b:  5B                pop  bx
0x009c:  59                pop  cx
0x009d:  5A                pop  dx
0x009e:  CB                retf 
0x009f:  C7 47 03 00 01    mov  word ptr [bx + 3], 0x100
0x00a4:  C3                ret  
RETURN_UNRECOGNIZED_COMMAND:
0x00a5:  C7 47 03 03 81    mov  word ptr [bx + 3], 0x8103
0x00aa:  C3                ret  

;0x00ab
STRING DB "HANDLE_TABLE_START"


STRUCT_23_BYTES MACRO
    db 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h
		ENDM

;0x00bd 23 byte struct, apparently up to 255 in length. (5865, 0x16E9)
handle_table  STRUCT_23_BYTES

repeat 254
    STRUCT_23_BYTES
endm


;0x17A6 seems to contain number of pages that dont include ROM fragments
upper_C000toEC00_non_rom_pages dw 0000h

;0x17A8
STRING DB "FRAME_USEABLE"

;0x17B5 
; ff byte if theres a BIOS in this 0x400 eligible page frame from c000 to ec00.
bios_in_upper_pages db 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h

;0x17C1
STRING DB "L_PAGE_START"

;0x17CD - 4 byte struct array related to the backfill page registers. 24 (0x18) in length.
 ; word 0: page register index
 ; word 1: the pointer to that page (in this struct) in this segment.
backfill_page_map dw 0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h 
dw 0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h  0000h 0000h 


;0x2749  3 byte struct arrary related to the ems page registers. 36 page registers in length
 ; byte 0-1: page frame segment
 ; byte 2: ems register
page_register_data db 00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h
db 00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h
db 00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h  00h 00h 00h

; 0x27bf array of 2 word structs. 156 bytes long? first word is pointers entries in page_register_data, indexed where 0x4000 = 0, 0x4400 = 1... up to f000.  then 2nd word its register index
page_register_data_pointers dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h
dw 0000h 0000h 0000h 0000h 0000h 0000h


;0x285b  page frame values
page_frame_segment_values dw 00C0h 00C4h 00C8h 00CCh 00D0h 00D4h 00D8h 00DCh 00E0h

; 0x2871: 32-bit pointer to arguments to driver
driver_arguments dw 0000h 0000h 

;0x2875 some key used for access rights to OS level calls, generated from sys clock + some algo
os_password_low dw 0000h
;0x2877 initailization clock time 
os_password_high dw 0000h

;0x2879: 
  ;holds pointer to 0x00bd or the start of handle_table
handle_table_pointer dw 0000h

; 0x287d pointer to backfill_page_map
backfill_page_map_pointer dw 0000h
; 0x287f pointer to unallocated_page_count
unallocated_page_count_pointer dw 0000h




;0x2881  ; segment of pageframe
page_frame_segment dw 0000h 
; 0x2883
temporary_jump_addr dw 0000h
 dw 0000h
; 0x2885 initialized to 0xfe.
handle_count dw 0000h

; 0x2887
  ; pointer to result of GET_EMM_HANDLE
get_emm_handle_result_pointer dw 0000h;


; 0x2889
; stores total page count
total_page_count dw 0000h;

; 0x288B
STRING 'L_Page_num'
; 0x2895
; stores unallocated page count 
unallocated_page_count dw 0000h;
; 0x2897
STRING 'P_Page_num'
;0x28a1
number_ems_pages dw 0000h
;0x28a3
page_map_call_stored_ax dw 0000h 
;0x28a5
stored_ax dw 0000h
;0x28a7
dw 0000h
;0x28a9
page_map_call_stored_dx dw 0000h 
;0x28ab
page_map_call_stored_ds dw 0000h 
;0x28ad
page_map_call_stored_si dw 0000h 
;0x28af
dw 0000h
;0x28b1
page_map_call_stack_pointer dw 0000h 
;0x28b3 mystery bytes
func_24_temp_storage_5 dw 0000h
;0x28b5 mystery bytes
func_24_temp_storage_6 dw 0000h
;0x28b7 mystery bytes
func_24_temp_storage_3 dw 0000h
;0x28b9 mystery bytes
func_24_temp_storage_4 dw 0000h
;0x28bb func 24 arguments, 18 bytes copied here at start of func_24
func_24_region_length_low_word dw 0000h
;0x28bd 
func_24_region_length_high_word dw 0000h
;0x28bf 
func_24_source_memory_type db 00h
;0x28c0 
func_24_source_handle dw 0000h
;0x28c2 
func_24_source_initial_offset dw 0000h
;0x28c4 
func_24_source_initial_seg_page dw 0000h
;0x28c6 
func_24_dest_memory_type db 00h
;0x28c7 
func_24_dest_handle dw 0000h
;0x28c9 
func_24_dest_initial_offset dw 0000h
;0x28cb 
func_24_dest_initial_seg_page dw 0000h
;0x28cd 
func_24_emm_handle_result_pointer dw 0000h
;0x28cf 
func_24_emm_handle_result_pointer_2 dw 0000h
;0x28d1 holds ff or 0. 
func_24_overlapping_emm_handle db 00h
;0x28d2 seems to hold 0 or 1 but never read
func_24_temp_storage_18 db 00h
;0x28d3 seems to hold copy byte amount for the current page
func_24_temp_storage_19 dw 0000h
;0x28d5 something related to how much to copy
func_24_temp_storage_20 dw 0000h
;0x28d7 something related to how much to copy
func_24_temp_storage_21 dw 0000h
;0x28d9 something related to how much to copy
func_24_temp_storage_22 dw 0000h
;0x28db may be the direction of the copy
func_24_temp_storage_23 dw 0000h
; 0x28dd
ose_function_set_enabled_1 db 00h
; 0x28de
ose_function_set_enabled_2 db 00h
; 0x28df  32 bit pointer
stored_es dw 0000h
; 0x28e1  32 bit pointer
stored_di dw 0000h
; 0x28e3 some complicated 10 byte return result from function 5900h/5901h
hardware_configuration_array dw 0400h 0000h 0000h 0000h 0000h

; 0x28ed Backfill enabled flag
backfill_enabled db 00h

; 0x28ee this doesnt fit in 16 bits. need to fix.
backfill_register_flags dw 0000
; 0x28F0  8 bytes used during warmboot function
warmboot_data dw 2020h 2020h 2020h 2020h

; 0x28F8: EMS Function pointer table
dw  3E2Bh
dw  412Bh
dw  492Bh
dw  562Bh
dw  102Ch
dw  752Ch
dw  EF2Ch
dw  F42Ch
dw  262Dh
dw  572Dh
dw  5A2Dh
dw  5D2Dh
dw  682Dh
dw  7B2Dh
dw  A02Dh
dw  DD2Dh
dw  6F2Eh
dw  142Fh
dw  1530h
dw  4E30h
dw  C630h
dw  5431h
dw  9631h
dw  6132h
dw  9337h
dw  D237h
dw  0F38h
dw  1C38h
dw  F938h
dw  4639h



; BEEP function
BEEP:
0x2934:  50          push ax
0x2935:  B8 07 0E    mov  ax, 0xe07
0x2938:  CD 10       int  0x10
0x293a:  58          pop  ax
0x293b:  C3          ret  

; look up emm handle. if cant find it return 0 in carry flag. otherwise carry flag = 1 result in get_emm_handle_result_pointer
; not sure yet whats going on here.
; dx is a page frame number?  ax and bx unused?
; if byte 0xA of 23 byte structure is 0, return 0.
GET_EMM_HANDLE:
0x293c:  50                push       ax
0x293d:  53                push       bx
0x293e:  52                push       dx
0x293f:  81 FA FF 00       cmp        dx, 0xff
0x2943:  77 1D             ja         RETURN_CARRY_FLAG
0x2945:  B8 17 00          mov        ax, 0x17            ; 23 bytes per structure?
0x2948:  F7 E2             mul        dx
0x294a:  2E 03 06 79 28    add        ax, word ptr cs:[handle_table_pointer]
0x294f:  8B D8             mov        bx, ax
0x2951:  2E 8B 5F 0A       mov        bx, word ptr cs:[bx + 0xa]
0x2955:  83 FB 00          cmp        bx, 0
0x2958:  74 08             je         RETURN_CARRY_FLAG
0x295a:  2E A3 87 28       mov        word ptr cs:[get_emm_handle_result_pointer], ax
RETURN_NO_CARRY_FLAG:
0x295e:  F8                clc        
0x295f:  EB 02             jmp        RETURN_WITH_RESULT
0x2961:  90                nop        
RETURN_CARRY_FLAG:
0x2962:  F9                stc        
RETURN_WITH_RESULT:
0x2963:  5A                pop        dx
0x2964:  5B                pop        bx
0x2965:  58                pop        ax
0x2966:  C3                ret        

; read from chipset register AL into AL
READCHIPSETREG:
0x2967:  E6 EC             out        0xec, al
0x2969:  EB 00             jmp        NOP_A
NOP_A:
0x296b:  EB 00             jmp        NOP_B
NOP_B:
0x296d:  E4 ED             in         al, 0xed
0x296f:  C3                ret      

; WRITE AH TO chipset register AL
WRITECHIPSETREG:
0x2970:  E6 EC             out        0xec, al
0x2972:  EB 00             jmp        NOP_C
NOP_C:
0x2974:  EB 00             jmp        NOP_D
NOP_D:
0x2976:  86 C4             xchg       ah, al
0x2978:  E6 ED             out        0xed, al
0x297a:  86 C4             xchg       ah, al
0x297c:  C3                ret        

; READ from EMS index port AL  into AX
READEMSPORT:
0x297d:  E6 E8             out        0xe8, al
0x297f:  EB 00             jmp        NOP_E
NOP_E:
0x2981:  EB 00             jmp        NOP_F
NOP_F:
0x2983:  E5 EA             in         ax, 0xea
0x2985:  C3                ret        

; WRITE AL to ems index port DX to port EA/EAB
WRITEEMSPORT:
0x2986:  E6 E8             out        0xe8, al
0x2988:  EB 00             jmp        NOP_G
NOP_G:
0x298a:  EB 00             jmp        NOP_H
NOP_H:
0x298c:  50                push       ax
0x298d:  8B C2             mov        ax, dx
0x298f:  E7 EA             out        0xea, ax
0x2991:  58                pop        ax
0x2992:  C3                ret
        

; al = page register number 
; bx is value to write to that port
; then we turn enable that page as ems enabled.

TURN_ON_EMS_PAGE:
0x2993:  50                push       ax
0x2994:  53                push       bx
0x2995:  51                push       cx
0x2996:  52                push       dx
0x2997:  E8 F3 00          call       GET_PAGE_FRAME_REGISTER_FOR_INDEX
0x299a:  3C 23             cmp        al, 0x23
0x299c:  77 67             ja         EXIT_FUNCTION  ; exit if al > 35 or 0x23. 0x23 is the maximum page frame register 
0x299e:  8B D3             mov        dx, bx
0x29a0:  E8 E3 FF          call       WRITEEMSPORT
0x29a3:  3C 0B             cmp        al, 0xb       ; if page register was > 0xB - which means its backfill

; routines to get bit number [al] turned on
0x29a5:  77 34             ja         HANDLE_BACKFILL_REGISTER
0x29a7:  3C 07             cmp        al, 7
0x29a9:  77 17             ja         HANDLE_8_TO_12_REGISTER
; 0-7 case: just shift 01 left that many times
0x29ab:  B4 01             mov        ah, 1
0x29ad:  8A C8             mov        cl, al
0x29af:  D2 E4             shl        ah, cl
0x29b1:  B0 0C             mov        al, 0xc           ; read EMS configuration register 02 which has the ON bits for pages 00-07
0x29b3:  E8 B1 FF          call       READCHIPSETREG
0x29b6:  0A C4             or         al, ah
0x29b8:  8A E0             mov        ah, al
0x29ba:  B0 0C             mov        al, 0xc           ; 
0x29bc:  E8 B1 FF          call       WRITECHIPSETREG
0x29bf:  EB 44             jmp        EXIT_FUNCTION
0x29c1:  90                nop        
HANDLE_8_TO_12_REGISTER:
0x29c2:  2C 08             sub        al, 8
0x29c4:  B4 01             mov        ah, 1
0x29c6:  8A C8             mov        cl, al
0x29c8:  D2 E4             shl        ah, cl
0x29ca:  B0 0B             mov        al, 0xb       ; read EMS configuration register 01 which has the ON bits for pages 08-0b
0x29cc:  E8 98 FF          call       READCHIPSETREG
0x29cf:  0A C4             or         al, ah
0x29d1:  8A E0             mov        ah, al
0x29d3:  B0 0B             mov        al, 0xb
0x29d5:  E8 98 FF          call       WRITECHIPSETREG
0x29d8:  EB 2B             jmp        EXIT_FUNCTION
0x29da:  90                nop        

HANDLE_BACKFILL_REGISTER:
; backfill registers not supported in this function
0x29db:  80 3E ED 28 00    cmp        byte ptr [backfill_enabled], 0
0x29e0:  74 23             je         EXIT_FUNCTION

; backfill enabled
; BUG: this is not doing anything right. shifts too much. does not update right registers.
0x29e2:  2C 0C             sub        al, 0xc      ; get backfill index
0x29e4:  8A C8             mov        cl, al       ; in theory this ranges from 0 to 0x18
0x29e6:  B8 01 00          mov        ax, 1
0x29e9:  D3 E0             shl        ax, cl
0x29eb:  2E 8B 1E EE 28    mov        bx, word ptr cs:[backfill_register_flags]
0x29f0:  0B D8             or         bx, ax
0x29f2:  2E 89 1E EE 28    mov        word ptr cs:[backfill_register_flags], bx
0x29f7:  B0 0B             mov        al, 0xb
0x29f9:  E8 6B FF          call       READCHIPSETREG
0x29fc:  0C 40             or         al, 0x40
0x29fe:  8A E0             mov        ah, al
0x2a00:  B0 0B             mov        al, 0xb
0x2a02:  E8 6B FF          call       WRITECHIPSETREG
EXIT_FUNCTION:
0x2a05:  5A                pop        dx
0x2a06:  59                pop        cx
0x2a07:  5B                pop        bx
0x2a08:  58                pop        ax
0x2a09:  C3                ret        


; called with AL = page register
; turns off a register
TURN_OFF_EMS_PAGE:
0x2a0a:  50                push       ax
0x2a0b:  53                push       bx
0x2a0c:  51                push       cx
0x2a0d:  52                push       dx
0x2a0e:  E8 7C 00          call       GET_PAGE_FRAME_REGISTER_FOR_INDEX
0x2a11:  3C 23             cmp        al, 0x23
0x2a13:  77 73             ja         EXIT_FUNCTION_C
0x2a15:  3C 0B             cmp        al, 0xb
0x2a17:  77 38             ja         HANDLE_BACKFILL_REGISTER_B
0x2a19:  3C 07             cmp        al, 7
0x2a1b:  77 19             ja         HANDLE_8_TO_12_REGISTER_B
; 0-7 case here
0x2a1d:  B4 01             mov        ah, 1
0x2a1f:  8A C8             mov        cl, al
0x2a21:  D2 E4             shl        ah, cl
0x2a23:  F6 D4             not        ah
0x2a25:  B0 0C             mov        al, 0xc
0x2a27:  E8 3D FF          call       READCHIPSETREG
0x2a2a:  22 C4             and        al, ah
0x2a2c:  8A E0             mov        ah, al
0x2a2e:  B0 0C             mov        al, 0xc
0x2a30:  E8 3D FF          call       WRITECHIPSETREG
0x2a33:  EB 53             jmp        EXIT_FUNCTION_C
0x2a35:  90                nop        
HANDLE_8_TO_12_REGISTER_B:
0x2a36:  2C 08             sub        al, 8
0x2a38:  B4 01             mov        ah, 1
0x2a3a:  8A C8             mov        cl, al
0x2a3c:  D2 E4             shl        ah, cl
0x2a3e:  F6 D4             not        ah
0x2a40:  B0 0B             mov        al, 0xb
0x2a42:  E8 22 FF          call       READCHIPSETREG
0x2a45:  22 C4             and        al, ah
0x2a47:  8A E0             mov        ah, al
0x2a49:  B0 0B             mov        al, 0xb
0x2a4b:  E8 22 FF          call       WRITECHIPSETREG
0x2a4e:  EB 38             jmp        EXIT_FUNCTION_C
0x2a50:  90                nop        
HANDLE_BACKFILL_REGISTER_B:
0x2a51:  BA 10 00          mov        dx, 0x10
0x2a54:  8A E0             mov        ah, al
0x2a56:  80 EC 0C          sub        ah, 0xc
0x2a59:  02 D4             add        dl, ah
0x2a5b:  E8 28 FF          call       WRITEEMSPORT
0x2a5e:  2C 0C             sub        al, 0xc
0x2a60:  8A C8             mov        cl, al
0x2a62:  B8 01 00          mov        ax, 1
0x2a65:  D3 E0             shl        ax, cl
0x2a67:  F7 D0             not        ax
0x2a69:  2E 8B 1E EE 28    mov        bx, word ptr cs:[backfill_register_flags]
0x2a6e:  23 D8             and        bx, ax
0x2a70:  2E 89 1E EE 28    mov        word ptr cs:[backfill_register_flags], bx ; check to see if the flag is enabled??
0x2a75:  83 FB 00          cmp        bx, 0
0x2a78:  75 0E             jne        EXIT_FUNCTION_C
0x2a7a:  B0 0B             mov        al, 0xb
0x2a7c:  E8 E8 FE          call       READCHIPSETREG ; update ems page to enable it too
0x2a7f:  24 BF             and        al, 0xbf
0x2a81:  8A E0             mov        ah, al
0x2a83:  B0 0B             mov        al, 0xb
0x2a85:  E8 E8 FE          call       WRITECHIPSETREG
EXIT_FUNCTION_C:
0x2a88:  5A                pop        dx
0x2a89:  59                pop        cx
0x2a8a:  5B                pop        bx
0x2a8b:  58                pop        ax
0x2a8c:  C3                ret

; gets page frame index for page al
; read byte at 0x2749 + [al * 3] + 2;

GET_PAGE_FRAME_REGISTER_FOR_INDEX:
0x2a8d:  56                push       si
0x2a8e:  51                push       cx
0x2a8f:  BE 49 27          mov        si, OFFSET page_register_data
0x2a92:  32 E4             xor        ah, ah
0x2a94:  B1 03             mov        cl, 3
0x2a96:  F6 E1             mul        cl
0x2a98:  03 F0             add        si, ax
0x2a9a:  2E 8A 44 02       mov        al, byte ptr cs:[si + 2]
0x2a9e:  59                pop        cx
0x2a9f:  5E                pop        si
0x2aa0:  C3                ret


; read byte at 0x2749 + [al * 3] + 2;
; get byte at 28a1
; if ax == byte at 2749 return bl
; else 
; finds the index of the 3 byte mystery struct with first byte == ax

FIND_PAGE_REGISTER_BY_INDEX:
0x2aa1:  56                push       si
0x2aa2:  53                push       bx
0x2aa3:  51                push       cx
0x2aa4:  B3 00             mov        bl, 0
0x2aa6:  BE 49 27          mov        si, OFFSET page_register_data
0x2aa9:  2E 8B 0E A1 28    mov        cx, word ptr cs:[number_ems_pages]
CHECK_NEXT_PAGE_REGISTER_DATA_2:
0x2aae:  2E 39 04          cmp        word ptr cs:[si], ax
0x2ab1:  74 07             je         FOUND_PAGE_REGISTER_DATA_2
0x2ab3:  FE C3             inc        bl
0x2ab5:  83 C6 03          add        si, 3
0x2ab8:  E2 F4             loop       CHECK_NEXT_PAGE_REGISTER_DATA_2
FOUND_PAGE_REGISTER_DATA_2:
0x2aba:  8A C3             mov        al, bl
0x2abc:  59                pop        cx
0x2abd:  5B                pop        bx
0x2abe:  5E                pop        si
0x2abf:  C3                ret

; reads and writes out first CX pages' EMS register data from page map to ES:DI as words, followed by contents of chipset register 0xb and 0xc
GET_EMS_REGISTER_DATA:
0x2ac0:  50                push       ax
0x2ac1:  51                push       cx
0x2ac2:  52                push       dx
0x2ac3:  56                push       si
0x2ac4:  BE 49 27          mov        si, OFFSET page_register_data
GET_NEXT_PAGE_REGISTER_DATA:
0x2ac7:  2E 8A 44 02       mov        al, byte ptr cs:[si + 2]
0x2acb:  E8 AF FE          call       READEMSPORT
0x2ace:  AB                stosw      word ptr es:[di], ax
0x2acf:  83 C6 03          add        si, 3
0x2ad2:  E2 F3             loop       GET_NEXT_PAGE_REGISTER_DATA
0x2ad4:  B0 0B             mov        al, 0xb
0x2ad6:  E8 8E FE          call       READCHIPSETREG
0x2ad9:  AA                stosb      byte ptr es:[di], al
0x2ada:  B0 0C             mov        al, 0xc
0x2adc:  E8 88 FE          call       READCHIPSETREG
0x2adf:  AA                stosb      byte ptr es:[di], al
0x2ae0:  5E                pop        si
0x2ae1:  5A                pop        dx
0x2ae2:  59                pop        cx
0x2ae3:  58                pop        ax
0x2ae4:  C3                ret

; writes a list of registers (source is cs/ds:si)
WRITE_PAGE_MAP:
0x2ae5:  50                push       ax
0x2ae6:  53                push       bx
0x2ae7:  51                push       cx
0x2ae8:  52                push       dx
0x2ae9:  BB 49 27          mov        bx, OFFSET page_register_data
WRITE_NEXT_EMS_DATA:
0x2aec:  AD                lodsw      ax, word ptr [si]
0x2aed:  8B D0             mov        dx, ax
0x2aef:  2E 8A 47 02       mov        al, byte ptr cs:[bx + 2]
0x2af3:  E8 90 FE          call       WRITEEMSPORT
0x2af6:  83 C3 03          add        bx, 3
0x2af9:  E2 F1             loop       WRITE_NEXT_EMS_DATA
0x2afb:  AC                lodsb      al, byte ptr [si]
0x2afc:  8A E0             mov        ah, al
0x2afe:  B0 0B             mov        al, 0xb
0x2b00:  E8 6D FE          call       WRITECHIPSETREG
0x2b03:  AC                lodsb      al, byte ptr [si]
0x2b04:  8A E0             mov        ah, al
0x2b06:  B0 0C             mov        al, 0xc
0x2b08:  E8 65 FE          call       WRITECHIPSETREG
0x2b0b:  5A                pop        dx
0x2b0c:  59                pop        cx
0x2b0d:  5B                pop        bx
0x2b0e:  58                pop        ax
0x2b0f:  C3                ret   

MAIN_EMS_INTERRUPT_VECTOR:
0x2b10:  51                   push       cx
0x2b11:  56                   push       si
0x2b12:  57                   push       di
0x2b13:  55                   push       bp
0x2b14:  1E                   push       ds
0x2b15:  06                   push       es
0x2b16:  FC                   cld        

; don't support OS function types
0x2b17:  80 FC 5D             cmp        ah, 0x5d
0x2b1a:  77 1F                ja         RETURN_RESULT_84

; don't support 'GET STATUS' call
0x2b1c:  80 FC 40             cmp        ah, 0x40
0x2b1f:  72 1A                jb         RETURN_RESULT_84

; subtract 0x40 - things are now 0x40 indexed..

0x2b21:  80 EC 40             sub        ah, 0x40
0x2b24:  53                   push       bx
0x2b25:  8A DC                mov        bl, ah
0x2b27:  32 FF                xor        bh, bh
0x2b29:  D1 E3                shl        bx, 1          ; get word offset of AH - 0x40
0x2b2b:  2E 8B 9F F8 28       mov        bx, word ptr cs:[bx + 0x28f8]
0x2b30:  2E 89 1E 83 28       mov        word ptr cs:[temporary_jump_addr], bx
0x2b35:  5B                   pop        bx
0x2b36:  2E FF 26 83 28       jmp        word ptr cs:[temporary_jump_addr]

; The function code passed to the memory manager is not defined.
RETURN_RESULT_84:
0x2b3b:  E9 B1 0E             jmp        RETURNINTERRUPTRESULT_84

; MAIN EMS FUNCTIONS BELOW

;          1  Get Status                                     40h      

EMS_FUNCTION_0x40:
0x2b3e:  E9 53 0F             jmp        RETURNINTERRUPTRESULT0

;          2  Get Page Frame Segment Address                 41h       

EMS_FUNCTION_0x41:
0x2b41:  2E 8B 1E 81 28       mov        bx, word ptr cs:[page_frame_segment]
0x2b46:  E9 4B 0F             jmp        RETURNINTERRUPTRESULT0

;          3  Get Unallocated Page Count                     42h       

EMS_FUNCTION_0x42:
;      FUNCTION 3    GET UNALLOCATED PAGE COUNT
0x2b49:  2E 8B 16 95 28       mov        dx, word ptr cs:[unallocated_page_count]
0x2b4e:  2E 8B 1E 89 28       mov        bx, word ptr cs:[total_page_count]
0x2b53:  E9 3E 0F             jmp        RETURNINTERRUPTRESULT0

;          4  Allocate Pages                                 43h      
;           BX = num_of_pages_to_alloc

EMS_FUNCTION_0x43:
0x2b56:  0E                   push       cs
0x2b57:  1F                   pop        ds
0x2b58:  53                   push       bx
0x2b59:  83 FB 00             cmp        bx, 0
0x2b5c:  74 41                je         ARG_BX_IS_0
DO_ALLOCATE_PAGE:
0x2b5e:  3B 1E 95 28          cmp        bx, word ptr [unallocated_page_count]
0x2b62:  77 42                ja         ARG_BX_ABOVE_PAGE_COUNT
0x2b64:  3B 1E 89 28          cmp        bx, word ptr [total_page_count]
0x2b68:  77 2E                ja         ARG_BX_ABOVE_TOTAL_PAGE_COUNT
0x2b6a:  83 3E 85 28 00       cmp        word ptr [handle_count], 0
0x2b6f:  74 20                je         NO_HANDLES_LEFT
0x2b71:  8B 36 79 28          mov        si, word ptr [handle_table_pointer]
0x2b75:  BA 00 00             mov        dx, 0
0x2b78:  B9 FF 00             mov        cx, 0xff
CHECK_NEXT_PAGE_SPACE:
0x2b7b:  83 7C 0A 00          cmp        word ptr [si + 0xa], 0
0x2b7f:  74 2C                je         FOUND_EMPTY_PAGE_SPACE
0x2b81:  83 C6 17             add        si, 0x17               ; increment to the next struct
0x2b84:  42                   inc        dx
0x2b85:  E2 F4                loop       CHECK_NEXT_PAGE_SPACE
0x2b87:  E9 6A 0E             jmp        RETURNINTERRUPTRESULT_85
GET_NEXT_PAGE:
0x2b8a:  BA 00 00             mov        dx, 0
0x2b8d:  5B                   pop        bx
0x2b8e:  E9 54 0E             jmp        RETURNINTERRUPTRESULT_80
NO_HANDLES_LEFT:
0x2b91:  BA 00 00             mov        dx, 0
0x2b94:  5B                   pop        bx
0x2b95:  E9 5C 0E             jmp        RETURNINTERRUPTRESULT_85
ARG_BX_ABOVE_TOTAL_PAGE_COUNT:
0x2b98:  BA 00 00             mov        dx, 0
0x2b9b:  5B                   pop        bx
0x2b9c:  E9 64 0E             jmp        RETURNINTERRUPTRESULT_88
ARG_BX_IS_0:
0x2b9f:  BA 00 00             mov        dx, 0
0x2ba2:  5B                   pop        bx
0x2ba3:  E9 62 0E             jmp        RETURNINTERRUPTRESULT_89
ARG_BX_ABOVE_PAGE_COUNT:
0x2ba6:  BA 00 00             mov        dx, 0
0x2ba9:  5B                   pop        bx
0x2baa:  E9 51 0E             jmp        RETURNINTERRUPTRESULT_87
FOUND_EMPTY_PAGE_SPACE:
0x2bad:  83 3C 00             cmp        word ptr [si], 0
0x2bb0:  75 D8                jne        GET_NEXT_PAGE
0x2bb2:  B0 00                mov        al, 0
0x2bb4:  B9 08 00             mov        cx, 8
0x2bb7:  8B FE                mov        di, si
0x2bb9:  81 C7 02 00          add        di, 2
0x2bbd:  0E                   push       cs
0x2bbe:  07                   pop        es
0x2bbf:  F3 AE                repe scasb al, byte ptr es:[di]   ; scan 8 bytes out of the 23  to see if theyre empty
0x2bc1:  75 C7                jne        GET_NEXT_PAGE
0x2bc3:  BF 0A 00             mov        di, 0xa
0x2bc6:  03 FE                add        di, si ; get the 0xa offset within the struct
0x2bc8:  89 1C                mov        word ptr [si], bx   ; put num pages to allocate in there (??? why doesnt make sense)
0x2bca:  8B 36 7D 28          mov        si, word ptr [backfill_page_map_pointer]
0x2bce:  8B CB                mov        cx, bx
0x2bd0:  83 FB 00             cmp        bx, 0    ; BUG: i don't think bx = 0 can ever make it here. it's caught above..
0x2bd3:  75 03                jne        DECREMENT_UNALLOCATED_PAGES
0x2bd5:  B9 01 00             mov        cx, 1

; really not sure whats going on here
DECREMENT_UNALLOCATED_PAGES:
0x2bd8:  3B 36 7F 28          cmp        si, word ptr [unallocated_page_count_pointer]
0x2bdc:  73 AC                jae        GET_NEXT_PAGE
0x2bde:  3B 36 7D 28          cmp        si, word ptr [backfill_page_map_pointer]
0x2be2:  72 A6                jb         GET_NEXT_PAGE
0x2be4:  83 7C 02 00          cmp        word ptr [si + 2], 0
0x2be8:  74 05                je         DONT_DECREMENT
0x2bea:  83 C6 04             add        si, 4
0x2bed:  EB E9                jmp        DECREMENT_UNALLOCATED_PAGES
DONT_DECREMENT:
0x2bef:  89 35                mov        word ptr [di], si
0x2bf1:  BF 02 00             mov        di, 2
0x2bf4:  03 FE                add        di, si
0x2bf6:  83 C6 04             add        si, 4
0x2bf9:  E2 DD                loop       DECREMENT_UNALLOCATED_PAGES
0x2bfb:  83 FB 00             cmp        bx, 0
0x2bfe:  74 08                je         DO_UNMAP

0x2c00:  C7 05 FF FF    mov word ptr [di], 0xffff
0x2c04:  29 1E 89 28    sub word ptr [total_page_count], bx
DO_UNMAP:
0x2c08:  FF 0E 85 28    dec word ptr [handle_count]
0x2c0c:  5B                   pop        bx
0x2c0d:  E9 84 0E             jmp        RETURNINTERRUPTRESULT0

;          5  Map/Unmap Handle Page                          44h      
EMS_FUNCTION_0x44:

0x2c10:  0E                   push       cs
0x2c11:  1F                   pop        ds
0x2c12:  53                   push       bx
0x2c13:  52                   push       dx
0x2c14:  32 E4                xor        ah, ah
0x2c16:  8B F8                mov        di, ax
0x2c18:  2E 3B 06 A1 28       cmp        ax, word ptr cs:[number_ems_pages]
0x2c1d:  72 03                jb         ENOUGH_PAGES
0x2c1f:  EB 4F                jmp        RETURN_RESULT_8B
0x2c21:  90                   nop        
ENOUGH_PAGES:
0x2c22:  E8 17 FD             call       GET_EMM_HANDLE
0x2c25:  73 03                jae        FOUND_EMM_HANDLE               ; jump if not carry
; couldnt find
0x2c27:  EB 3D                jmp        RETURN_RESULT_83
0x2c29:  90                   nop        
FOUND_EMM_HANDLE:
0x2c2a:  E8 DD FD             call       TURN_OFF_EMS_PAGE
0x2c2d:  83 FB FF             cmp        bx, -1
0x2c30:  74 2A                je         RETURN_RESULT_00
0x2c32:  8B 36 87 28          mov        si, word ptr [get_emm_handle_result_pointer]
0x2c36:  3B 1C                cmp        bx, word ptr [si]
0x2c38:  72 03                jb         FOUND_VALID_EMM_HANDLE_POINTER
0x2c3a:  EB 2F                jmp        RETURN_RESULT_8A
0x2c3c:  90                   nop        
FOUND_VALID_EMM_HANDLE_POINTER:
0x2c3d:  8B 74 0A             mov        si, word ptr [si + 0xa]
0x2c40:  8B CB                mov        cx, bx
0x2c42:  E3 05                jcxz       CX_IS_ZERO               ; jump if cx is 0
LOOP_ADD_TO_SI:
0x2c44:  8B 74 02             mov        si, word ptr [si + 2]
0x2c47:  E2 FB                loop       LOOP_ADD_TO_SI
CX_IS_ZERO:
0x2c49:  3B 36 7F 28          cmp        si, word ptr [unallocated_page_count_pointer]
0x2c4d:  73 12                jae        RETURN_RESULT_80
0x2c4f:  3B 36 7D 28          cmp        si, word ptr [backfill_page_map_pointer]
0x2c53:  72 0C                jb         RETURN_RESULT_80
0x2c55:  8B 1C                mov        bx, word ptr [si]
0x2c57:  8B C7                mov        ax, di
0x2c59:  E8 37 FD             call       TURN_ON_EMS_PAGE
RETURN_RESULT_00:
0x2c5c:  5A                   pop        dx
0x2c5d:  5B                   pop        bx
0x2c5e:  E9 33 0E             jmp        RETURNINTERRUPTRESULT0
RETURN_RESULT_80:
0x2c61:  5A                   pop        dx
0x2c62:  5B                   pop        bx
0x2c63:  E9 7F 0D             jmp        RETURNINTERRUPTRESULT_80

; The memory manager couldn't find the EMM handle your program specified.
RETURN_RESULT_83:
0x2c66:  5A                   pop        dx
0x2c67:  5B                   pop        bx
0x2c68:  E9 7F 0D             jmp        RETURNINTERRUPTRESULT_83

RETURN_RESULT_8A:
0x2c6b:  5A                   pop        dx
0x2c6c:  5B                   pop        bx
0x2c6d:  E9 9D 0D             jmp        RETURNINTERRUPTRESULT_8A

RETURN_RESULT_8B:
0x2c70:  5A                   pop        dx
0x2c71:  5B                   pop        bx
0x2c72:  E9 9D 0D             jmp        RETURNINTERRUPTRESULT_8B

;         6  Deallocate Pages                               45h       

EMS_FUNCTION_0x45:
0x2c75:  0E                   push       cs
0x2c76:  1F                   pop        ds
0x2c77:  53                   push       bx
0x2c78:  52                   push       dx
0x2c79:  E8 C0 FC             call       GET_EMM_HANDLE
0x2c7c:  72 67                jb         NO_EMM_HANDLE_FOUND
0x2c7e:  8B 36 87 28          mov        si, word ptr [get_emm_handle_result_pointer]
0x2c82:  80 7C 0C FF          cmp        byte ptr [si + 0xc], 0xff
0x2c86:  74 62                je         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED
0x2c88:  8B 36 87 28          mov        si, word ptr [get_emm_handle_result_pointer]
0x2c8c:  8B 0C                mov        cx, word ptr [si]
0x2c8e:  83 F9 00             cmp        cx, 0
0x2c91:  74 20                je         GOOD_EMM_HANDLE
0x2c93:  8B 74 0A             mov        si, word ptr [si + 0xa]
; not sure but i think we are looping thru these handles...
CHECK_EMM_HANDLE:
0x2c96:  3B 36 7F 28          cmp        si, word ptr [unallocated_page_count_pointer]
0x2c9a:  73 44                jae        UNSPECIFIED_ERROR
0x2c9c:  3B 36 7D 28          cmp        si, word ptr [backfill_page_map_pointer]
0x2ca0:  72 3E                jb         UNSPECIFIED_ERROR
0x2ca2:  8B 7C 02             mov        di, word ptr [si + 2]
0x2ca5:  C7 44 02 00 00       mov        word ptr [si + 2], 0
0x2caa:  83 FF FF             cmp        di, -1
0x2cad:  74 04                je         GOOD_EMM_HANDLE
0x2caf:  8B F7                mov        si, di
0x2cb1:  EB E3                jmp        CHECK_EMM_HANDLE
GOOD_EMM_HANDLE:
0x2cb3:  8B 3E 87 28          mov        di, word ptr [get_emm_handle_result_pointer]
0x2cb7:  8B 1D                mov        bx, word ptr [di]
0x2cb9:  01 1E 89 28          add        word ptr [total_page_count], bx
0x2cbd:  C7 05 00 00          mov        word ptr [di], 0
0x2cc1:  83 FA 00             cmp        dx, 0
0x2cc4:  74 09                je         SKIP_INC_HANDLE_COUNT    ; don't get this yet
0x2cc6:  FF 06 85 28          inc        word ptr [handle_count]
0x2cca:  C7 45 0A 00 00       mov        word ptr [di + 0xa], 0
SKIP_INC_HANDLE_COUNT:
0x2ccf:  83 C7 02             add        di, 2
0x2cd2:  0E                   push       cs
0x2cd3:  07                   pop        es
0x2cd4:  B0 00                mov        al, 0
0x2cd6:  B9 08 00             mov        cx, 8
0x2cd9:  F3 AA                rep stosb  byte ptr es:[di], al
0x2cdb:  5A                   pop        dx
0x2cdc:  5B                   pop        bx
0x2cdd:  E9 B4 0D             jmp        RETURNINTERRUPTRESULT0
UNSPECIFIED_ERROR:
0x2ce0:  5A                   pop        dx
0x2ce1:  5B                   pop        bx
0x2ce2:  E9 00 0D             jmp        RETURNINTERRUPTRESULT_80
NO_EMM_HANDLE_FOUND:
0x2ce5:  5A                   pop        dx
0x2ce6:  5B                   pop        bx
0x2ce7:  E9 00 0D             jmp        RETURNINTERRUPTRESULT_83
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED:
0x2cea:  5A                   pop        dx
0x2ceb:  5B                   pop        bx
0x2cec:  E9 0A 0D             jmp        RETURNINTERRUPTRESULT_86

;          7  Get Version                                    46h       

EMS_FUNCTION_0x46:
; Get Version, return 4.0
0x2cef:  B0 40                mov        al, 0x40
0x2cf1:  E9 A0 0D             jmp        RETURNINTERRUPTRESULT0

;          8  Save Page Map                                  47h       

EMS_FUNCTION_0x47:
0x2cf4:  0E                   push       cs
0x2cf5:  1F                   pop        ds
0x2cf6:  53                   push       bx
0x2cf7:  52                   push       dx
0x2cf8:  E8 41 FC             call       GET_EMM_HANDLE
0x2cfb:  72 E8                jb         NO_EMM_HANDLE_FOUND
0x2cfd:  8B 36 87 28          mov        si, word ptr [get_emm_handle_result_pointer]
0x2d01:  80 7C 0C FF          cmp        byte ptr [si + 0xc], 0xff
0x2d05:  74 1A                je         STATE_ALREADY_EXISTS
0x2d07:  C6 44 0C FF          mov        byte ptr [si + 0xc], 0xff
0x2d0b:  8B FE                mov        di, si
0x2d0d:  83 C7 0D             add        di, 0xd
0x2d10:  8C C8                mov        ax, cs
0x2d12:  8E C0                mov        es, ax
0x2d14:  51                   push       cx
0x2d15:  B9 04 00             mov        cx, 4
0x2d18:  E8 A5 FD             call       GET_EMS_REGISTER_DATA
0x2d1b:  59                   pop        cx
0x2d1c:  5A                   pop        dx
0x2d1d:  5B                   pop        bx
0x2d1e:  E9 73 0D             jmp        RETURNINTERRUPTRESULT0
STATE_ALREADY_EXISTS:
0x2d21:  5A                   pop        dx
0x2d22:  5B                   pop        bx
0x2d23:  E9 F6 0C             jmp        RETURNINTERRUPTRESULT_8D

;          9  Restore Page Map                               48h       

EMS_FUNCTION_0x48:
0x2d26:  0E                   push       cs
0x2d27:  1F                   pop        ds
0x2d28:  53                   push       bx
0x2d29:  52                   push       dx
0x2d2a:  E8 0F FC             call       GET_EMM_HANDLE
0x2d2d:  72 B6                jb         NO_EMM_HANDLE_FOUND
0x2d2f:  8B 36 87 28          mov        si, word ptr [get_emm_handle_result_pointer]
0x2d33:  80 7C 0C FF          cmp        byte ptr [si + 0xc], 0xff
0x2d37:  75 19                jne        STATE_DOESNT_EXIST
0x2d39:  C6 44 0C 00          mov        byte ptr [si + 0xc], 0
0x2d3d:  83 C6 0D             add        si, 0xd
0x2d40:  51                   push       cx
0x2d41:  B9 04 00             mov        cx, 4
0x2d44:  E8 9E FD             call       WRITE_PAGE_MAP
0x2d47:  59                   pop        cx
0x2d48:  5A                   pop        dx
0x2d49:  5B                   pop        bx
0x2d4a:  E9 47 0D             jmp        RETURNINTERRUPTRESULT0
0x2d4d:  5A                   pop        dx
0x2d4e:  5B                   pop        bx
0x2d4f:  E9 93 0C             jmp        RETURNINTERRUPTRESULT_80
STATE_DOESNT_EXIST:
0x2d52:  5A                   pop        dx
0x2d53:  5B                   pop        bx
0x2d54:  E9 CA 0C             jmp        RETURNINTERRUPTRESULT_8E

;          10 Reserved                                       49h       


EMS_FUNCTION_0x49:
0x2d57:  E9 3A 0D             jmp        RETURNINTERRUPTRESULT0

;          11 Reserved                                       4Ah       

EMS_FUNCTION_0x4A:
0x2d5a:  E9 37 0D             jmp        RETURNINTERRUPTRESULT0

;          12 Get Handle Count                               4Bh       

EMS_FUNCTION_0x4B:
0x2d5d:  BB FF 00             mov        bx, 0xff
0x2d60:  2E 2B 1E 85 28       sub        bx, word ptr cs:[handle_count]
0x2d65:  E9 2C 0D             jmp        RETURNINTERRUPTRESULT0

;          13 Get Handle Pages                               4Ch       

EMS_FUNCTION_0x4C:
0x2d68:  E8 D1 FB             call       GET_EMM_HANDLE
0x2d6b:  72 0B                jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_2
0x2d6d:  2E 8B 1E 87 28       mov        bx, word ptr cs:[get_emm_handle_result_pointer]
0x2d72:  2E 8B 1F             mov        bx, word ptr cs:[bx]
0x2d75:  E9 1C 0D             jmp        RETURNINTERRUPTRESULT0
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_2:
0x2d78:  E9 6F 0C             jmp        RETURNINTERRUPTRESULT_83

;          14 Get All Handle Pages                           4Dh       
; we write all handle pages to es:di
EMS_FUNCTION_0x4D:
0x2d7b:  52                   push       dx
0x2d7c:  0E                   push       cs
0x2d7d:  1F                   pop        ds
0x2d7e:  B9 FF 00             mov        cx, 0xff
0x2d81:  33 C0                xor        ax, ax
0x2d83:  33 D2                xor        dx, dx
0x2d85:  8B 1E 79 28          mov        bx, word ptr [handle_table_pointer]

SEARCH_NEXT_PAGES:
0x2d89:  8B F3                mov        si, bx
0x2d8b:  83 7C 0A 00          cmp        word ptr [si + 0xa], 0
0x2d8f:  74 03                je         SKIP_EMPTY_PAGE  ; this page is empty. don't write it.
0x2d91:  42                   inc        dx
0x2d92:  AB                   stosw      word ptr es:[di], ax
0x2d93:  A5                   movsw      word ptr es:[di], word ptr [si]  ; write page date to es:di

SKIP_EMPTY_PAGE:
0x2d94:  40                   inc        ax
0x2d95:  83 C3 17             add        bx, 0x17
0x2d98:  E2 EF                loop       SEARCH_NEXT_PAGES
0x2d9a:  8B DA                mov        bx, dx
0x2d9c:  5A                   pop        dx
0x2d9d:  E9 F4 0C             jmp        RETURNINTERRUPTRESULT0

;          15 Get Page Map                                   4E00h    
;             Set Page Map                                   4E01h     
;             Get & Set Page Map                             4E02h     
;             Get Size of Page Map Save Array                4E03h     

EMS_FUNCTION_0x4E:
0x2da0:  3C 03                cmp        al, 3
0x2da2:  72 03                jb         ARG_LT_3
0x2da4:  EB 23                jmp        ARG_GTE_3
0x2da6:  90                   nop        
ARG_LT_3
0x2da7:  3C 01                cmp        al, 1
0x2da9:  74 11                je         EMS_FUNCTION_0x4E01
0x2dab:  51                   push       cx
0x2dac:  2E 8B 0E A1 28       mov        cx, word ptr cs:[number_ems_pages]
0x2db1:  E8 0C FD             call       GET_EMS_REGISTER_DATA
0x2db4:  59                   pop        cx
0x2db5:  3C 00                cmp        al, 0
0x2db7:  75 03                jne        EMS_FUNCTION_0x4E02
0x2db9:  E9 D8 0C             jmp        RETURNINTERRUPTRESULT0
EMS_FUNCTION_0x4E02:
EMS_FUNCTION_0x4E01:
0x2dbc:  51                   push       cx
0x2dbd:  2E 8B 0E A1 28       mov        cx, word ptr cs:[number_ems_pages]
0x2dc2:  E8 20 FD             call       WRITE_PAGE_MAP
0x2dc5:  59                   pop        cx
0x2dc6:  E9 CB 0C             jmp        RETURNINTERRUPTRESULT0
ARG_GTE_3:
0x2dc9:  3C 03                cmp        al, 3
0x2dcb:  74 03                je         EMS_FUNCTION_0x4E03
0x2dcd:  E9 56 0C             jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
EMS_FUNCTION_0x4E03:
0x2dd0:  2E A1 A1 28          mov        ax, word ptr cs:[number_ems_pages]
0x2dd4:  D1 E0                shl        ax, 1
0x2dd6:  04 02                add        al, 2
0x2dd8:  32 E4                xor        ah, ah
0x2dda:  E9 B7 0C             jmp        RETURNINTERRUPTRESULT0

; 16 Get Partial Page Map                           4F00h     
;             Set Partial Page Map                           4F01h     
;             Get Size of Partial Page Map Save Array        4F02h     
EMS_FUNCTION_0x4F:
0x2ddd:  3C 00                cmp        al, 0
0x2ddf:  74 03                je         EMS_FUNCTION_0x4F00
0x2de1:  EB 3C                jmp        CHECK_FUNCTION_TYPE_0x4F
0x2de3:  90                   nop        
EMS_FUNCTION_0x4F00:
0x2de4:  53                   push       bx
0x2de5:  52                   push       dx
0x2de6:  8B EF                mov        bp, di
0x2de8:  FC                   cld        
0x2de9:  AD                   lodsw      ax, word ptr [si]
0x2dea:  2E 3B 06 A1 28       cmp        ax, word ptr cs:[number_ems_pages]
0x2def:  77 23                ja         TOO_MANY_PAGES
0x2df1:  AB                   stosw      word ptr es:[di], ax
0x2df2:  8B C8                mov        cx, ax
0x2df4:  E3 0E                jcxz       RESULT_OK
GET_NEXT_PARAM:
0x2df6:  AD                   lodsw      ax, word ptr [si]
0x2df7:  E8 A7 FC             call       FIND_PAGE_REGISTER_BY_INDEX
0x2dfa:  AA                   stosb      byte ptr es:[di], al
0x2dfb:  E8 8F FC             call       GET_PAGE_FRAME_REGISTER_FOR_INDEX
0x2dfe:  E8 7C FB             call       READEMSPORT
0x2e01:  AB                   stosw      word ptr es:[di], ax
0x2e02:  E2 F2                loop       GET_NEXT_PARAM
RESULT_OK:
0x2e04:  5A                   pop        dx
0x2e05:  5B                   pop        bx
0x2e06:  E9 8B 0C             jmp        RETURNINTERRUPTRESULT0
0x2e09:  5A                   pop        dx
0x2e0a:  5B                   pop        bx
0x2e0b:  26 C7 46 00 00 00    mov        word ptr es:[bp], 0
0x2e11:  E9 FE 0B             jmp        RETURNINTERRUPTRESULT_8B
TOO_MANY_PAGES:
0x2e14:  5A                   pop        dx
0x2e15:  5B                   pop        bx
0x2e16:  26 C7 46 00 00 00    mov        word ptr es:[bp], 0
0x2e1c:  E9 6B 0C             jmp        RETURNINTERRUPTRESULT_A3
CHECK_FUNCTION_TYPE_0x4F:
0x2e1f:  3C 01                cmp        al, 1
0x2e21:  74 03                je         EMS_FUNCTION_0x4F01
0x2e23:  EB 2E                jmp        EMS_FUNCTION_0x4F02
0x2e25:  90                   nop        

EMS_FUNCTION_0x4F01:
0x2e26:  53                   push       bx
0x2e27:  52                   push       dx
0x2e28:  FC                   cld        
0x2e29:  AD                   lodsw      ax, word ptr [si]
0x2e2a:  8B C8                mov        cx, ax
0x2e2c:  2E 3B 0E A1 28       cmp        cx, word ptr cs:[number_ems_pages]
0x2e31:  77 16                ja         CORRUPTED_SOURCE_ARRAY
0x2e33:  E3 0A                jcxz       RESULT_OK_2
SET_NEXT_PAGE:
0x2e35:  AC                   lodsb      al, byte ptr [si]
0x2e36:  8A D8                mov        bl, al
0x2e38:  AD                   lodsw      ax, word ptr [si]
0x2e39:  93                   xchg       ax, bx
0x2e3a:  E8 56 FB             call       TURN_ON_EMS_PAGE
0x2e3d:  E2 F6                loop       SET_NEXT_PAGE
RESULT_OK_2:
0x2e3f:  5A                   pop        dx
0x2e40:  5B                   pop        bx
0x2e41:  E9 50 0C             jmp        RETURNINTERRUPTRESULT0
; unused
0x2e44:  5A                   pop        dx
0x2e45:  5B                   pop        bx
0x2e46:  E9 9C 0B             jmp        RETURNINTERRUPTRESULT_80
CORRUPTED_SOURCE_ARRAY:
0x2e49:  5A                   pop        dx
0x2e4a:  5B                   pop        bx
0x2e4b:  E9 3C 0C             jmp        RETURNINTERRUPTRESULT_A3
; unused
0x2e4e:  5A                   pop        dx
0x2e4f:  5B                   pop        bx
0x2e50:  E9 14 0C             jmp        RETURNINTERRUPTRESULT_9C
EMS_FUNCTION_0x4F02:

0x2e53:  3C 02                cmp        al, 2
0x2e55:  74 03                je         CORRECT_SUBFUNCTION
0x2e57:  E9 CC 0B             jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
CORRECT_SUBFUNCTION:
0x2e5a:  2E 3B 1E A1 28       cmp        bx, word ptr cs:[number_ems_pages]
0x2e5f:  77 09                ja         TOO_MANY_PAGES_2
0x2e61:  B0 03                mov        al, 3
0x2e63:  F6 E3                mul        bl
0x2e65:  04 02                add        al, 2
0x2e67:  E9 2A 0C             jmp        RETURNINTERRUPTRESULT0
TOO_MANY_PAGES_2:
0x2e6a:  B0 00                mov        al, 0
0x2e6c:  E9 A3 0B             jmp        RETURNINTERRUPTRESULT_8B

;          17 Map/Unmap Multiple Handle Pages
;             (Physical page number mode)                    5000h     
;             (Segment address mode)                         5001h     

EMS_FUNCTION_0x50:
0x2e6f:  83 F9 00             cmp        cx, 0
0x2e72:  75 03                jne        VALID_SUBFUNCTION_PARAMETER
; invalid subfunction parameter
0x2e74:  E9 AF 0B             jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
VALID_SUBFUNCTION_PARAMETER:
0x2e77:  53                   push       bx
0x2e78:  52                   push       dx
0x2e79:  32 E4                xor        ah, ah
0x2e7b:  2E A3 A5 28          mov        word ptr cs:[stored_ax], ax
DO_NEXT_PAGE:
0x2e7f:  AD                   lodsw      ax, word ptr [si]
0x2e80:  8B D8                mov        bx, ax
0x2e82:  AD                   lodsw      ax, word ptr [si]
0x2e83:  2E 83 3E A5 28 00    cmp        word ptr cs:[stored_ax], 0
0x2e89:  74 03                je         USE_REGISTER_ZERO
0x2e8b:  E8 13 FC             call       FIND_PAGE_REGISTER_BY_INDEX
USE_REGISTER_ZERO:
; no need to find param 0, i guess it's 0
0x2e8e:  E8 0B 00             call       MYSTERY_FUNCTION_6
0x2e91:  0A E4                or         ah, ah     ; test for zero? i think?
0x2e93:  75 02                jne        END_LOOP     ; leave with error
0x2e95:  E2 E8                loop       DO_NEXT_PAGE
; exits if we fall thru loop with no error
END_LOOP:
0x2e97:  5A                   pop        dx
0x2e98:  5B                   pop        bx
0x2e99:  E9 FA 0B             jmp        RETURNINTERRUPTRESULT


; ax is a page register to check..
MYSTERY_FUNCTION_6:
0x2e9c:  1E                   push       ds
0x2e9d:  53                   push       bx
0x2e9e:  51                   push       cx
0x2e9f:  52                   push       dx
0x2ea0:  56                   push       si
0x2ea1:  57                   push       di
0x2ea2:  0E                   push       cs
0x2ea3:  1F                   pop        ds
0x2ea4:  8B F8                mov        di, ax
0x2ea6:  E8 93 FA             call       GET_EMM_HANDLE
0x2ea9:  73 03                jae        FOUND_EMM_HANDLE_2
0x2eab:  EB 3D                jmp        RETURN_RESULT_B_83
0x2ead:  90                   nop        
FOUND_EMM_HANDLE_2:
0x2eae:  E8 59 FB             call       TURN_OFF_EMS_PAGE
0x2eb1:  83 FB FF             cmp        bx, -1
; faled to unmap?
0x2eb4:  74 2A                je         RETURN_RESULT_B_00
0x2eb6:  8B 36 87 28          mov        si, word ptr [get_emm_handle_result_pointer] ; not sure what's going on here yet
0x2eba:  3B 1C                cmp        bx, word ptr [si]
0x2ebc:  72 03                jb         EMM_HANDLE_VALUE_OK
0x2ebe:  EB 2F                jmp        RETURN_RESULT_B_8A
0x2ec0:  90                   nop        
EMM_HANDLE_VALUE_OK:
0x2ec1:  8B 74 0A             mov        si, word ptr [si + 0xa]
0x2ec4:  8B CB                mov        cx, bx
0x2ec6:  E3 05                jcxz       FOUND_EMM_HANDLE_POINTER
FOLLOW_CHAIN_LOOP:
0x2ec8:  8B 74 02             mov        si, word ptr [si + 2]
0x2ecb:  E2 FB                loop       FOLLOW_CHAIN_LOOP
FOUND_EMM_HANDLE_POINTER:
0x2ecd:  3B 36 7F 28          cmp        si, word ptr [unallocated_page_count_pointer]
0x2ed1:  73 12                jae        RETURN_RESULT_B_80
0x2ed3:  3B 36 7D 28          cmp        si, word ptr [backfill_page_map_pointer]
0x2ed7:  72 0C                jb         RETURN_RESULT_B_80
0x2ed9:  8B 1C                mov        bx, word ptr [si]
0x2edb:  8B C7                mov        ax, di
0x2edd:  E8 B3 FA             call       TURN_ON_EMS_PAGE

RETURN_RESULT_B_00:
0x2ee0:  B4 00                mov        ah, 0
0x2ee2:  EB 15                jmp        RETURN_RESULT_B
0x2ee4:  90                   nop        

RETURN_RESULT_B_80:
0x2ee5:  B4 80                mov        ah, 0x80
0x2ee7:  EB 10                jmp        RETURN_RESULT_B
0x2ee9:  90                   nop        

; The memory manager couldn't find the EMM handle your program specified.
RETURN_RESULT_B_83:
0x2eea:  B4 83                mov        ah, 0x83
0x2eec:  EB 0B                jmp        RETURN_RESULT_B
0x2eee:  90                   nop        

RETURN_RESULT_B_8A:
0x2eef:  B4 8A                mov        ah, 0x8a
0x2ef1:  EB 06                jmp        RETURN_RESULT_B
0x2ef3:  90                   nop        

;unused
RETURN_RESULT_B_8B:
0x2ef4:  B4 8B                mov        ah, 0x8b
0x2ef6:  EB 01                jmp        RETURN_RESULT_B
0x2ef8:  90                   nop        

RETURN_RESULT_B:
0x2ef9:  5F                   pop        di
0x2efa:  5E                   pop        si
0x2efb:  5A                   pop        dx
0x2efc:  59                   pop        cx
0x2efd:  5B                   pop        bx
0x2efe:  1F                   pop        ds
0x2eff:  C3                   ret




COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_3
0x2f00:  5A                   pop        dx
0x2f01:  8B 3E 87 28          mov        di, word ptr [get_emm_handle_result_pointer]
0x2f05:  8B 1D                mov        bx, word ptr [di]
0x2f07:  E9 E0 0A             jmp        RETURNINTERRUPTRESULT_83
INSUFFICIENT_PAGES:
0x2f0a:  5A                   pop        dx
0x2f0b:  8B 3E 87 28          mov        di, word ptr [get_emm_handle_result_pointer]
0x2f0f:  8B 1D                mov        bx, word ptr [di]
0x2f11:  E9 EA 0A             jmp        RETURNINTERRUPTRESULT_87

;          18 Reallocate Pages                               51h       
; DX = handle
;BX = reallocation_count                     
EMS_FUNCTION_0x51:
0x2f14:  52                   push       dx
0x2f15:  0E                   push       cs
0x2f16:  1F                   pop        ds
0x2f17:  E8 22 FA             call       GET_EMM_HANDLE
0x2f1a:  72 E4                jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_3
0x2f1c:  81 FB DC 03          cmp        bx, 0x3dc      ; i think this is close to 16 M - 640k or 1M or something.
0x2f20:  77 E8                ja         INSUFFICIENT_PAGES
0x2f22:  8B 36 87 28          mov        si, word ptr [get_emm_handle_result_pointer]
0x2f26:  8B 0C                mov        cx, word ptr [si]
0x2f28:  8B EB                mov        bp, bx
; bx is requested allocation count, cx is current allocation count
0x2f2a:  3B CB                cmp        cx, bx
0x2f2c:  74 74                je         RETURN_OK   ; same number of pages
0x2f2e:  72 03                jb         ADD_PAGES_TO_HANDLE      ; fewer?  need to deallocate
0x2f30:  E9 8D 00             jmp        REMOVE_PAGES_FROM_HANDLE
ADD_PAGES_TO_HANDLE:
0x2f33:  83 F9 00             cmp        cx, 0
0x2f36:  75 08                jne        ADD_TO_MORE_THAN_0
0x2f38:  8B FE                mov        di, si
0x2f3a:  83 C7 0A             add        di, 0xa
0x2f3d:  EB 29                jmp        DO_ALLOCATE_MORE_PAGES_TO_HANDLE
0x2f3f:  90                   nop        
ADD_TO_MORE_THAN_0;
0x2f40:  2B D9                sub        bx, cx   ; page diff
0x2f42:  3B 1E 89 28          cmp        bx, word ptr [total_page_count]
0x2f46:  77 6E                ja         INSUFFICIENT_PAGES_2:
0x2f48:  8B 7C 0A             mov        di, word ptr [si + 0xa]
0x2f4b:  49                   dec        cx
0x2f4c:  E3 11                jcxz       ALLOCATE_OK
; out of pages?
CHECK_NEXT_PAGE_ALLOCATE_OK_LOOP:
0x2f4e:  3B 3E 7F 28          cmp        di, word ptr [unallocated_page_count_pointer]
0x2f52:  73 58                jae        SOME_SORT_OF_MALFUNCTION
0x2f54:  3B 3E 7D 28          cmp        di, word ptr [backfill_page_map_pointer]
0x2f58:  72 52                jb         SOME_SORT_OF_MALFUNCTION
0x2f5a:  8B 7D 02             mov        di, word ptr [di + 2]
0x2f5d:  E2 EF                loop       CHECK_NEXT_PAGE_ALLOCATE_OK_LOOP
ALLOCATE_OK:
0x2f5f:  83 7D 02 FF          cmp        word ptr [di + 2], -1
0x2f63:  75 47                jne        SOME_SORT_OF_MALFUNCTION
0x2f65:  83 C7 02             add        di, 2

DO_ALLOCATE_MORE_PAGES_TO_HANDLE:
; for each new page to allocate, do this stuff...
0x2f68:  8B CB                mov        cx, bx
0x2f6a:  8B 36 7D 28          mov        si, word ptr [backfill_page_map_pointer]
CHECK_NEXT_POINTER:
0x2f6e:  3B 36 7F 28          cmp        si, word ptr [unallocated_page_count_pointer]
0x2f72:  73 38                jae        SOME_SORT_OF_MALFUNCTION
0x2f74:  3B 36 7D 28          cmp        si, word ptr [backfill_page_map_pointer] 
0x2f78:  72 32                jb         SOME_SORT_OF_MALFUNCTION
0x2f7a:  83 7C 02 00          cmp        word ptr [si + 2], 0
0x2f7e:  74 05                je         EXIT_INNER_LOOP
0x2f80:  83 C6 04             add        si, 4
0x2f83:  EB E9                jmp        CHECK_NEXT_POINTER
EXIT_INNER_LOOP:
0x2f85:  89 35                mov        word ptr [di], si
0x2f87:  8B FE                mov        di, si
0x2f89:  83 C7 02             add        di, 2
0x2f8c:  83 C6 04             add        si, 4
0x2f8f:  E2 DD                loop       CHECK_NEXT_POINTER
0x2f91:  C7 05 FF FF          mov        word ptr [di], 0xffff
0x2f95:  29 1E 89 28          sub        word ptr [total_page_count], bx
DO_RETURN_OK:
0x2f99:  8B 3E 87 28          mov        di, word ptr [get_emm_handle_result_pointer]
0x2f9d:  89 2D                mov        word ptr [di], bp
0x2f9f:  EB 01                jmp        RETURN_OK
0x2fa1:  90                   nop        
RETURN_OK:
0x2fa2:  5A                   pop        dx
0x2fa3:  8B 3E 87 28          mov        di, word ptr [get_emm_handle_result_pointer]
0x2fa7:  8B 1D                mov        bx, word ptr [di]
0x2fa9:  E9 E8 0A             jmp        RETURNINTERRUPTRESULT0
SOME_SORT_OF_MALFUNCTION:
0x2fac:  5A                   pop        dx
0x2fad:  8B 3E 87 28          mov        di, word ptr [get_emm_handle_result_pointer]
0x2fb1:  8B 1D                mov        bx, word ptr [di]
0x2fb3:  E9 2F 0A             jmp        RETURNINTERRUPTRESULT_80
INSUFFICIENT_PAGES_2:
0x2fb6:  5A                   pop        dx
0x2fb7:  8B 3E 87 28          mov        di, word ptr [get_emm_handle_result_pointer]
0x2fbb:  8B 1D                mov        bx, word ptr [di]
0x2fbd:  E9 43 0A             jmp        RETURNINTERRUPTRESULT_88
REMOVE_PAGES_FROM_HANDLE:
0x2fc0:  8B CB                mov        cx, bx
0x2fc2:  83 F9 00             cmp        cx, 0
0x2fc5:  75 06                jne        DEALLOCATE_MORE_THAN_0_FROM_HANDLE
0x2fc7:  8B 74 0A             mov        si, word ptr [si + 0xa]
0x2fca:  EB 24                jmp        DO_DEALLOCATE_PAGES_FROM_HANDLE
0x2fcc:  90                   nop        
DEALLOCATE_MORE_THAN_0_FROM_HANDLE:
0x2fcd:  8B 74 0A             mov        si, word ptr [si + 0xa]
0x2fd0:  83 E9 01             sub        cx, 1
0x2fd3:  E3 11                jcxz       SKIP_DEALLCOATE_LOOP:
DEALLOCATE_NEXT_PAGE_LOOP:
0x2fd5:  3B 36 7F 28          cmp        si, word ptr [unallocated_page_count_pointer]
0x2fd9:  73 D1                jae        SOME_SORT_OF_MALFUNCTION
0x2fdb:  3B 36 7D 28          cmp        si, word ptr [backfill_page_map_pointer]
0x2fdf:  72 CB                jb         SOME_SORT_OF_MALFUNCTION
0x2fe1:  8B 74 02             mov        si, word ptr [si + 2]
0x2fe4:  E2 EF                loop       DEALLOCATE_NEXT_PAGE_LOOP
SKIP_DEALLCOATE_LOOP:
0x2fe6:  8B 7C 02             mov        di, word ptr [si + 2]
0x2fe9:  C7 44 02 FF FF       mov        word ptr [si + 2], 0xffff
0x2fee:  8B F7                mov        si, di
DO_DEALLOCATE_PAGES_FROM_HANDLE:
0x2ff0:  3B 36 7F 28          cmp        si, word ptr [unallocated_page_count_pointer]
0x2ff4:  73 B6                jae        SOME_SORT_OF_MALFUNCTION
0x2ff6:  3B 36 7D 28          cmp        si, word ptr [backfill_page_map_pointer]
0x2ffa:  72 B0                jb         SOME_SORT_OF_MALFUNCTION
0x2ffc:  8B 7C 02             mov        di, word ptr [si + 2]
0x2fff:  C7 44 02 00 00       mov        word ptr [si + 2], 0
0x3004:  83 FF FF             cmp        di, -1

0x3007:  74 04          je  FINISH_RETURN
0x3009:  8B F7          mov si, di
0x300b:  EB E3          jmp DO_DEALLOCATE_PAGES_FROM_HANDLE
FINISH_RETURN:
0x300d:  8B 3E 87 28    mov di, OFFSET get_emm_handle_result_pointer
0x3011:  89 2D                mov        word ptr [di], bp
0x3013:  EB 8D                jmp        RETURN_OK


;          19 Get Handle Attribute                           5200h     
;             Set Handle Attribute                           5201h     
;             Get Handle Attribute Capability                5202h     

; it seems this is mostly unsupported.
EMS_FUNCTION_0x52:
0x3015:  3C 00                cmp        al, 0
0x3017:  75 0A                jne        NOT_0x5200
0x3019:  E8 20 F9             call       GET_EMM_HANDLE
0x301c:  72 1E                jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_4
0x301e:  B0 00                mov        al, 0
0x3020:  E9 71 0A             jmp        RETURNINTERRUPTRESULT0
NOT_0x5200:
0x3023:  3C 01                cmp        al, 1
0x3025:  75 1B                jne        NOT_0x5201
0x3027:  E8 12 F9             call       GET_EMM_HANDLE
0x302a:  72 10                jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_4
0x302c:  80 FB 00             cmp        bl, 0
0x302f:  75 03                jne        UNDEFINED_ATTRIBUTE_TYPE
0x3031:  E9 60 0A             jmp        RETURNINTERRUPTRESULT0
UNDEFINED_ATTRIBUTE_TYPE:
0x3034:  80 FB 01             cmp        bl, 1
0x3037:  75 06                jne        UNSUPPORTED_FEATURE
0x3039:  E9 EF 09             jmp        RETURNINTERRUPTRESULT_90
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_4:
0x303c:  E9 AB 09             jmp        RETURNINTERRUPTRESULT_83
UNSUPPORTED_FEATURE:
0x303f:  E9 EE 09             jmp        RETURNINTERRUPTRESULT_91
NOT_0x5201:
0x3042:  3C 02                cmp        al, 2
0x3044:  75 05                jne        BAD_SUBFUNCTION_PARAMETER
0x3046:  B0 00                mov        al, 0
0x3048:  E9 49 0A             jmp        RETURNINTERRUPTRESULT0
BAD_SUBFUNCTION_PARAMETER:
0x304b:  E9 D8 09             jmp        RETURN_BAD_SUBFUNCTION_PARAMETER

;          20 Get Handle Name                                5300h     
;             Set Handle Name                                5301h     

       
EMS_FUNCTION_0x53:
0x304e:  53                   push       bx
0x304f:  52                   push       dx
0x3050:  E8 E9 F8             call       GET_EMM_HANDLE
0x3053:  72 62                jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_5
0x3055:  3C 01                cmp        al, 1
0x3057:  77 63                ja         BAD_SUBFUNCTION_PARAMETER_2
0x3059:  74 14                je         EMS_FUNCTION_0x5301
EMS_FUNCTION_0x5300:
0x305b:  0E                   push       cs
0x305c:  1F                   pop        ds
0x305d:  8B 36 87 28          mov        si, word ptr [get_emm_handle_result_pointer]
0x3061:  81 C6 02 00          add        si, 2
0x3065:  B9 04 00             mov        cx, 4
0x3068:  F3 A5                rep movsw  word ptr es:[di], word ptr [si]
0x306a:  5A                   pop        dx
0x306b:  5B                   pop        bx
0x306c:  E9 25 0A             jmp        RETURNINTERRUPTRESULT0
EMS_FUNCTION_0x5301:
0x306f:  8C D8                mov        ax, ds
0x3071:  8E C0                mov        es, ax
0x3073:  8B FE                mov        di, si
0x3075:  B9 04 00             mov        cx, 4
0x3078:  33 C0                xor        ax, ax
0x307a:  F3 AF                repe scasw ax, word ptr es:[di] ; write four words into name addr
0x307c:  8C C8                mov        ax, cs
0x307e:  8E C0                mov        es, ax
0x3080:  74 20                je         CS_EQUALS_ES   ; 
0x3082:  8B EE                mov        bp, si
0x3084:  2E A1 79 28          mov        ax, word ptr cs:[handle_table_pointer]
0x3088:  05 02 00             add        ax, 2
0x308b:  B9 FF 00             mov        cx, 0xff
CHECK_EXISTING_HANDLE_NAMES_LOOP:
0x308e:  8B F5                mov        si, bp
0x3090:  8B F8                mov        di, ax
0x3092:  8B D9                mov        bx, cx
0x3094:  B9 04 00             mov        cx, 4
0x3097:  F3 A7                repe cmpsw word ptr [si], word ptr es:[di]
0x3099:  74 26                je         HANDLE_WITH_THIS_NAME_EXISTS
0x309b:  05 17 00             add        ax, 0x17
0x309e:  8B CB                mov        cx, bx
0x30a0:  E2 EC                loop       CHECK_EXISTING_HANDLE_NAMES_LOOP
CS_EQUALS_ES:
0x30a2:  2E 8B 3E 87 28       mov        di, word ptr cs:[get_emm_handle_result_pointer]
0x30a7:  81 C7 02 00          add        di, 2
0x30ab:  8B F5                mov        si, bp
0x30ad:  B9 04 00             mov        cx, 4
0x30b0:  F3 A5                rep movsw  word ptr es:[di], word ptr [si]
0x30b2:  5A                   pop        dx
0x30b3:  5B                   pop        bx
0x30b4:  E9 DD 09             jmp        RETURNINTERRUPTRESULT0
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_5:
0x30b7:  5A                   pop        dx
0x30b8:  5B                   pop        bx
0x30b9:  E9 2E 09             jmp        RETURNINTERRUPTRESULT_83
BAD_SUBFUNCTION_PARAMETER_2:
0x30bc:  5A                   pop        dx
0x30bd:  5B                   pop        bx
0x30be:  E9 65 09             jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
HANDLE_WITH_THIS_NAME_EXISTS:
0x30c1:  5A                   pop        dx
0x30c2:  5B                   pop        bx
0x30c3:  E9 BA 09             jmp        RETURNINTERRUPTRESULT_A1

;          21 Get Handle Directory                           5400h     
;             Search for Named Handle                        5401h     
;             Get Total Handles                              5402h     


EMS_FUNCTION_0x54:
0x30c6:  53                   push       bx
0x30c7:  52                   push       dx
0x30c8:  3C 00                cmp        al, 0
0x30ca:  75 2F                jne        NOT_0x5400
EMS_FUNCTION_0x5400:
0x30cc:  0E                   push       cs
0x30cd:  1F                   pop        ds
0x30ce:  33 C0                xor        ax, ax
0x30d0:  33 D2                xor        dx, dx
0x30d2:  8B 1E 79 28          mov        bx, word ptr [handle_table_pointer]
0x30d6:  B9 FF 00             mov        cx, 0xff
CHECK_NEXT_HANDLE_LOOP:
0x30d9:  83 7F 0A 00          cmp        word ptr [bx + 0xa], 0
0x30dd:  74 0F                je         HANDLE_NOT_EMPTY_DONT_COUNT
0x30df:  AB                   stosw      word ptr es:[di], ax
0x30e0:  8B F3                mov        si, bx
0x30e2:  81 C6 02 00          add        si, 2
0x30e6:  51                   push       cx
0x30e7:  B9 04 00             mov        cx, 4
0x30ea:  F3 A5                rep movsw  word ptr es:[di], word ptr [si]
0x30ec:  59                   pop        cx
0x30ed:  42                   inc        dx
HANDLE_NOT_EMPTY_DONT_COUNT:
0x30ee:  83 C3 17             add        bx, 0x17
0x30f1:  40                   inc        ax
0x30f2:  E2 E5                loop       CHECK_NEXT_HANDLE_LOOP
0x30f4:  8A C2                mov        al, dl
0x30f6:  5A                   pop        dx
0x30f7:  5B                   pop        bx
0x30f8:  E9 99 09             jmp        RETURNINTERRUPTRESULT0
NOT_0x5400:
0x30fb:  3C 01                cmp        al, 1
0x30fd:  75 3A                jne        NOT_0x5401
EMS_FUNCTION_0x5401:
0x30ff:  1E                   push       ds
0x3100:  07                   pop        es
0x3101:  8B FE                mov        di, si
0x3103:  B9 04 00             mov        cx, 4
0x3106:  33 C0                xor        ax, ax
0x3108:  F3 AF                repe scasw ax, word ptr es:[di]
0x310a:  74 43                je         NAME_WAS_NULL
0x310c:  0E                   push       cs
0x310d:  07                   pop        es
0x310e:  8B EE                mov        bp, si
0x3110:  33 D2                xor        dx, dx
0x3112:  2E A1 79 28          mov        ax, word ptr cs:[handle_table_pointer]
0x3116:  05 02 00             add        ax, 2
0x3119:  B9 FF 00             mov        cx, 0xff
CHECK_NEXT_NAME_LOOP:
0x311c:  8B F5                mov        si, bp
0x311e:  8B F8                mov        di, ax
0x3120:  8B D9                mov        bx, cx
0x3122:  B9 04 00             mov        cx, 4
0x3125:  F3 A7                repe cmpsw word ptr [si], word ptr es:[di]
0x3127:  74 0B                je         RETURN_NAME
0x3129:  42                   inc        dx
0x312a:  05 17 00             add        ax, 0x17
0x312d:  8B CB                mov        cx, bx
0x312f:  E2 EB                loop       CHECK_NEXT_NAME_LOOP
0x3131:  EB 17                jmp        NAME_NOT_FOUND
0x3133:  90                   nop        
RETURN_NAME:
0x3134:  5A                   pop        dx
0x3135:  5B                   pop        bx
0x3136:  E9 5B 09             jmp        RETURNINTERRUPTRESULT0
NOT_0x5401:
0x3139:  3C 02                cmp        al, 2
0x313b:  75 08                jne        BAD_SUBFUNCTION_PARAMETER_3
EMS_FUNCTION_0x5402:
0x313d:  5A                   pop        dx
0x313e:  5B                   pop        bx
0x313f:  BB FF 00             mov        bx, 0xff ; todo make this a constant
0x3142:  E9 4F 09             jmp        RETURNINTERRUPTRESULT0
BAD_SUBFUNCTION_PARAMETER_3:
0x3145:  5A                   pop        dx
0x3146:  5B                   pop        bx
0x3147:  E9 DC 08             jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
NAME_NOT_FOUND:
0x314a:  5A                   pop        dx
0x314b:  5B                   pop        bx
0x314c:  E9 2C 09             jmp        RETURNINTERRUPTRESULT_A0
NAME_WAS_NULL:
0x314f:  5A                   pop        dx
0x3150:  5B                   pop        bx
0x3151:  E9 2C 09             jmp        RETURNINTERRUPTRESULT_A1

;      22 Alter Page Map & Jump
;             (Physical page number mode)                    5500h     
;             Alter Page Map & Jump
;             (Segment address mode)                         5501h     

EMS_FUNCTION_0x55:
0x3154:  53                   push       bx
0x3155:  52                   push       dx
0x3156:  8B EC                mov        bp, sp
0x3158:  2E 8C 1E AB 28       mov        word ptr cs:[page_map_call_stored_ds], ds
0x315d:  2E 89 36 AD 28       mov        word ptr cs:[page_map_call_stored_si], si
0x3162:  32 ED                xor        ch, ch
0x3164:  8A 4C 04             mov        cl, byte ptr [si + 4]
0x3167:  C5 74 05             lds        si, ptr [si + 5]
0x316a:  B4 50                mov        ah, 0x50     ; call ourselves to alter page
0x316c:  CD 67                int        0x67
0x316e:  80 FC 00             cmp        ah, 0
0x3171:  74 05                je         PAGE_MAP_ALTER_WAS_OK
; return error from the alter page map, don't jump
0x3173:  5A                   pop        dx
0x3174:  5B                   pop        bx
0x3175:  E9 1E 09             jmp        RETURNINTERRUPTRESULT
PAGE_MAP_ALTER_WAS_OK:
; im pretty sure this is stack hacking to manipulate iret into a jmp (?)
0x3178:  2E 8E 1E AB 28       mov        ds, word ptr cs:[page_map_call_stored_ds]
0x317d:  2E 8B 36 AD 28       mov        si, word ptr cs:[page_map_call_stored_si]
0x3182:  16                   push       ss
0x3183:  07                   pop        es
0x3184:  8B FD                mov        di, bp
0x3186:  83 C7 0C             add        di, 0xc
0x3189:  A5                   movsw      word ptr es:[di], word ptr [si]
0x318a:  A5                   movsw      word ptr es:[di], word ptr [si]
0x318b:  5A                   pop        dx
0x318c:  5B                   pop        bx
0x318d:  E9 04 09             jmp        RETURNINTERRUPTRESULT0
EMS_FUNCTION_0x5602:

;   BX = total_handles
; The value returned represents the maximum number of handles
; which a program may request the memory manager to allocate
; memory to.  The value returned includes the operating
; system handle (handle value 0).

0x3190:  BB 20 00             mov        bx, 0x20
0x3193:  E9 FE 08             jmp        RETURNINTERRUPTRESULT0

;          23 Alter Page Map & Call
;             (Physical page number mode)                    5600h     
;             Alter Page Map & Call
;             (Segment address mode)                         5601h     
;             Get Page Map Stack Space Size                  5602h     

EMS_FUNCTION_0x56:
0x3196:  3C 02                cmp        al, 2
0x3198:  74 F6                je         EMS_FUNCTION_0x5602
0x319a:  83 C4 02             add        sp, 2
0x319d:  2E 89 26 B1 28       mov        word ptr cs:[page_map_call_stack_pointer], sp   ; store stack pointer
0x31a2:  51                   push       cx
0x31a3:  56                   push       si
0x31a4:  57                   push       di
0x31a5:  55                   push       bp
0x31a6:  1E                   push       ds
0x31a7:  06                   push       es
0x31a8:  53                   push       bx
0x31a9:  52                   push       dx
0x31aa:  3C 02                cmp        al, 2    ; why would this have changed?
0x31ac:  72 03                jb         PREPARE_CALL
0x31ae:  E9 A4 00             jmp        EXITINTERRUPTA2
PREPARE_CALL:
0x31b1:  2E 8C 1E AB 28       mov        word ptr cs:[page_map_call_stored_ds], ds
0x31b6:  2E 89 36 AD 28       mov        word ptr cs:[page_map_call_stored_si], si
0x31bb:  2E A3 A3 28          mov        word ptr cs:[page_map_call_stored_ax], ax
0x31bf:  2E 89 16 A9 28       mov        word ptr cs:[page_map_call_stored_dx], dx
0x31c4:  32 ED                xor        ch, ch
0x31c6:  8A 4C 04             mov        cl, byte ptr [si + 4]
0x31c9:  8B 7C 05             mov        di, word ptr [si + 5]
0x31cc:  8B 5C 07             mov        bx, word ptr [si + 7]
0x31cf:  8B F7                mov        si, di
0x31d1:  8E DB                mov        ds, bx
0x31d3:  B4 50                mov        ah, 0x50
0x31d5:  CD 67                int        0x67
0x31d7:  80 FC 00             cmp        ah, 0
0x31da:  74 03                je         EMS_FUNCTION_0x5600
0x31dc:  EB 77                jmp        EMS_FUNCTION_0x5601  
0x31de:  90                   nop        
EMS_FUNCTION_0x5600:
0x31df:  2E 8B 2E B1 28       mov        bp, word ptr cs:[page_map_call_stack_pointer]   ; sets up a function pointer to call 0x3211
0x31e4:  C7 46 06 11 32       mov        word ptr [bp + 6], 0x3211   ; replace 0x3211 with PAGE_MAP_CALL syntax?
0x31e9:  8C 4E 08             mov        word ptr [bp + 8], cs
0x31ec:  2E A1 AB 28          mov        ax, word ptr cs:[page_map_call_stored_ds]
0x31f0:  8E D8                mov        ds, ax
0x31f2:  2E 8B 36 AD 28       mov        si, word ptr cs:[page_map_call_stored_si]
0x31f7:  8B 04                mov        ax, word ptr [si]
0x31f9:  89 46 00             mov        word ptr [bp], ax
0x31fc:  8B 44 02             mov        ax, word ptr [si + 2]
0x31ff:  89 46 02             mov        word ptr [bp + 2], ax
0x3202:  8B 46 0E             mov        ax, word ptr [bp + 0xe]
0x3205:  89 46 04             mov        word ptr [bp + 4], ax
0x3208:  5A                   pop        dx
0x3209:  5B                   pop        bx
0x320a:  07                   pop        es
0x320b:  1F                   pop        ds
0x320c:  5D                   pop        bp
0x320d:  5F                   pop        di
0x320e:  5E                   pop        si
0x320f:  59                   pop        cx
0x3210:  CF                   iret

PAGE_MAP_CALL:
0x3211:  52                   push       dx
0x3212:  53                   push       bx
0x3213:  06                   push       es
0x3214:  1E                   push       ds
0x3215:  55                   push       bp
0x3216:  57                   push       di
0x3217:  56                   push       si
0x3218:  51                   push       cx
0x3219:  9C                   pushf      
0x321a:  5D                   pop        bp
0x321b:  2E A1 AB 28          mov        ax, word ptr cs:[page_map_call_stored_ds]
0x321f:  8E D8                mov        ds, ax
0x3221:  2E 8B 36 AD 28       mov        si, word ptr cs:[page_map_call_stored_si]
0x3226:  2E A1 A3 28          mov        ax, word ptr cs:[page_map_call_stored_ax]
0x322a:  2E 8B 16 A9 28       mov        dx, word ptr cs:[page_map_call_stored_dx]
0x322f:  32 ED                xor        ch, ch
0x3231:  8A 4C 09             mov        cl, byte ptr [si + 9]
0x3234:  8B 7C 0A             mov        di, word ptr [si + 0xa]
0x3237:  8B 5C 0C             mov        bx, word ptr [si + 0xc]
0x323a:  8B F7                mov        si, di
0x323c:  8E DB                mov        ds, bx
0x323e:  B4 50                mov        ah, 0x50
0x3240:  CD 67                int        0x67
0x3242:  8B DD                mov        bx, bp
0x3244:  2E 8B 2E B1 28       mov        bp, word ptr cs:[page_map_call_stack_pointer]   ; get stack pointer
0x3249:  89 5E 0E             mov        word ptr [bp + 0xe], bx
0x324c:  59                   pop        cx
0x324d:  5E                   pop        si
0x324e:  5F                   pop        di
0x324f:  5D                   pop        bp
0x3250:  1F                   pop        ds
0x3251:  07                   pop        es
0x3252:  5B                   pop        bx
0x3253:  5A                   pop        dx
0x3254:  CF                   iret
EMS_FUNCTION_0x5601:  ; the stack has been manipulated to make the call happen on iret (? not sure)
EXITINTERRUPTA2:
0x3255:  5A                   pop        dx
0x3256:  5B                   pop        bx
0x3257:  07                   pop        es
0x3258:  1F                   pop        ds
0x3259:  5D                   pop        bp
0x325a:  5F                   pop        di
0x325b:  5E                   pop        si
0x325c:  59                   pop        cx
0x325d:  83 C4 0A             add        sp, 0xa
0x3260:  CF                   iret

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
EMS_FUNCTION_0x57:
0x3261:  53                   push       bx
0x3262:  52                   push       dx
0x3263:  3C 01                cmp        al, 1
0x3265:  77 3C                ja         BAD_SUBFUNCTION_PARAMETER_7
0x3267:  32 E4                xor        ah, ah
0x3269:  2E A3 A5 28          mov        word ptr cs:[stored_ax], ax
0x326d:  8C C8                mov        ax, cs
0x326f:  8E C0                mov        es, ax
0x3271:  BF BB 28             mov        di, OFFSET func_24_region_length_low_word ; copy 18 bytes from source over...
0x3274:  B9 12 00             mov        cx, 0x12  ; BUG: buffer overrun? probably should be 0x10, but whatever...
0x3277:  F3 A4                rep movsb  byte ptr es:[di], byte ptr [si]
0x3279:  0E                   push       cs
0x327a:  1F                   pop        ds
0x327b:  83 3E BD 28 10       cmp        word ptr [func_24_region_length_high_word], 0x10  ; corresponds to an 0x100000 copy, or 1024k
0x3280:  75 05                jne        COPY_1024k
0x3282:  83 3E BB 28 00       cmp        word ptr [func_24_region_length_low_word], 0     ; ok as long as its 1024k + 0..
COPY_1024k:
0x3287:  77 1F                ja         COPY_TOO_BIG
0x3289:  80 3E BF 28 01       cmp        byte ptr [func_24_source_memory_type], 1
0x328e:  77 1D                ja         UNDEFINED_SOURCE_OR_DEST_TYPE
0x3290:  80 3E C6 28 01       cmp        byte ptr [func_24_dest_memory_type], 1
0x3295:  77 16                ja         UNDEFINED_SOURCE_OR_DEST_TYPE
0x3297:  A1 BB 28             mov        ax, word ptr [func_24_region_length_low_word]
0x329a:  0B 06 BD 28          or         ax, word ptr [func_24_region_length_high_word]
0x329e:  75 26                jne        CHECK_MEMORY_TYPE_SOURCE
0x32a0:  E9 E4 00             jmp        COPY_DONE    ; length 0
BAD_SUBFUNCTION_PARAMETER_7:
0x32a3:  5A                   pop        dx
0x32a4:  5B                   pop        bx
0x32a5:  E9 7E 07             jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
COPY_TOO_BIG:
0x32a8:  5A                   pop        dx
0x32a9:  5B                   pop        bx
0x32aa:  E9 9C 07             jmp        RETURNINTERRUPTRESULT_96
;                     The memory source and destination types are undefined.
UNDEFINED_SOURCE_OR_DEST_TYPE:
0x32ad:  5A                   pop        dx
0x32ae:  5B                   pop        bx
0x32af:  E9 A1 07             jmp        RETURNINTERRUPTRESULT_98
SOME_SORT_OF_MALFUNCTION_2:
0x32b2:  5A                   pop        dx
0x32b3:  5B                   pop        bx
0x32b4:  E9 2E 07             jmp        RETURNINTERRUPTRESULT_80
OFFSET_EXCEEDS_PAGE_SIZE:
0x32b7:  5A                   pop        dx
0x32b8:  5B                   pop        bx
0x32b9:  E9 88 07             jmp        RETURNINTERRUPTRESULT_95
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_6:
0x32bc:  5A                   pop        dx
0x32bd:  5B                   pop        bx
0x32be:  E9 29 07             jmp        RETURNINTERRUPTRESULT_83
OUT_OF_RANGE_EMM_HANDLE:
0x32c1:  5A                   pop        dx
0x32c2:  5B                   pop        bx
0x32c3:  E9 47 07             jmp        RETURNINTERRUPTRESULT_8A

CHECK_MEMORY_TYPE_SOURCE:
0x32c6:  80 3E BF 28 01       cmp        byte ptr [func_24_source_memory_type], 1
0x32cb:  75 4F                jne        CONVENTIONAL_MEMORY_TYPE_SOURCE
EXPANDED_MEMORY_TYPE_SOURCE:
0x32cd:  81 3E C2 28 FF 3F    cmp        word ptr [func_24_source_initial_offset], 0x3fff
0x32d3:  77 E2                ja         OFFSET_EXCEEDS_PAGE_SIZE
0x32d5:  8B 16 C0 28          mov        dx, word ptr [func_24_source_handle]
0x32d9:  E8 60 F6             call       GET_EMM_HANDLE
0x32dc:  72 DE                jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_6
0x32de:  A1 87 28             mov        ax, word ptr [get_emm_handle_result_pointer]
0x32e1:  A3 CF 28             mov        word ptr [func_24_emm_handle_result_pointer_2], ax
0x32e4:  8B F0                mov        si, ax
0x32e6:  A1 C4 28             mov        ax, word ptr [func_24_source_initial_seg_page]
0x32e9:  39 04                cmp        word ptr [si], ax
0x32eb:  76 D4                jbe        OUT_OF_RANGE_EMM_HANDLE
0x32ed:  B8 00 40             mov        ax, 0x4000
0x32f0:  F7 26 C4 28          mul        word ptr [func_24_source_initial_seg_page]
0x32f4:  03 06 C2 28          add        ax, word ptr [func_24_source_initial_offset]
0x32f8:  83 D2 00             adc        dx, 0
0x32fb:  03 06 BB 28          add        ax, word ptr [func_24_region_length_low_word]
0x32ff:  13 16 BD 28          adc        dx, word ptr [func_24_region_length_high_word]
0x3303:  2D 01 00             sub        ax, 1
0x3306:  83 DA 00             sbb        dx, 0
0x3309:  B9 00 40             mov        cx, 0x4000
0x330c:  F7 F1                div        cx
0x330e:  39 04                cmp        word ptr [si], ax
0x3310:  76 AF                jbe        OUT_OF_RANGE_EMM_HANDLE
0x3312:  A3 B7 28             mov        word ptr [func_24_temp_storage_3], ax
0x3315:  89 16 B9 28          mov        word ptr [func_24_temp_storage_4], dx
0x3319:  E9 95 00             jmp        CHECK_MEMORY_TYPE_DEST
CONVENTIONAL_MEMORY_TYPE_SOURCE:
0x331c:  A1 C4 28             mov        ax, word ptr [func_24_source_initial_seg_page]
0x331f:  B1 04                mov        cl, 4
0x3321:  32 F6                xor        dh, dh
0x3323:  8A D4                mov        dl, ah
0x3325:  D2 EA                shr        dl, cl
0x3327:  C1 E0 04             shl        ax, 4
0x332a:  03 06 C2 28          add        ax, word ptr [func_24_source_initial_offset]  ; dl:ax now holds source address offset (20 bit addr, no seg)
0x332e:  83 D2 00             adc        dx, 0
0x3331:  89 16 C4 28          mov        word ptr [func_24_source_initial_seg_page], dx
0x3335:  A3 C2 28             mov        word ptr [func_24_source_initial_offset], ax ; page:offset converted to 20 bit addr
0x3338:  03 06 BB 28          add        ax, word ptr [func_24_region_length_low_word]
0x333c:  13 16 BD 28          adc        dx, word ptr [func_24_region_length_high_word]
0x3340:  2D 01 00             sub        ax, 1
0x3343:  83 DA 00             sbb        dx, 0
0x3346:  83 FA 10             cmp        dx, 0x10
0x3349:  75 03                jne        CHECK_MEMORY_LENGTH_CONVENTIONAL_SOURCE
0x334b:  3D 00 00             cmp        ax, 0
CHECK_MEMORY_LENGTH_CONVENTIONAL_SOURCE:
0x334e:  77 5C                ja         WRAP_AROUND_1M_CONVENTIONAL_ERROR
0x3350:  89 16 B7 28          mov        word ptr [func_24_temp_storage_3], dx
0x3354:  A3 B9 28             mov        word ptr [func_24_temp_storage_4], ax
0x3357:  8B 1E 81 28          mov        bx, word ptr [page_frame_segment]
0x335b:  C1 C3 04             rol        bx, 4
0x335e:  8B CB                mov        cx, bx
0x3360:  83 E3 F0             and        bx, 0xfff0
0x3363:  83 E1 0F             and        cx, 0xf
0x3366:  3B D1                cmp        dx, cx
0x3368:  75 02                jne        SKIP_COMPARE
0x336a:  3B C3                cmp        ax, bx
SKIP_COMPARE_1:
0x336c:  72 43                jb         CHECK_MEMORY_TYPE_DEST
0x336e:  8B 16 C4 28          mov        dx, word ptr [func_24_source_initial_seg_page]
0x3372:  A1 C2 28             mov        ax, word ptr [func_24_source_initial_offset]
0x3375:  81 C3 00 C0          add        bx, 0xc000
0x3379:  83 D1 00             adc        cx, 0
0x337c:  3B D1                cmp        dx, cx
0x337e:  75 02                jne        SKIP_COMPARE_2
0x3380:  3B C3                cmp        ax, bx
SKIP_COMPARE_2:
0x3382:  77 2D                ja         CHECK_MEMORY_TYPE_DEST
0x3384:  EB 1C                jmp        OVERLAP_CONVENTIONAL_ERROR
0x3386:  90                   nop        

COPY_DONE:
0x3387:  5A                   pop        dx
0x3388:  5B                   pop        bx
0x3389:  B4 00                mov        ah, 0
0x338b:  2E 80 3E D1 28 FF    cmp        byte ptr cs:[func_24_overlapping_emm_handle], 0xff
0x3391:  75 02                jne        RETURN_NO_ERROR
; not an error, but 0x92 to say handle overlap is ok for move (not exchange)
0x3393:  B4 92                mov        ah, 0x92
RETURN_NO_ERROR:
0x3395:  E9 FE 06             jmp        RETURNINTERRUPTRESULT
COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_7:
0x3398:  5A                   pop        dx
0x3399:  5B                   pop        bx
0x339a:  E9 4D 06             jmp        RETURNINTERRUPTRESULT_83
OUT_OF_RANGE_EMM_HANDLE_2:
0x339d:  5A                   pop        dx
0x339e:  5B                   pop        bx
0x339f:  E9 6B 06             jmp        RETURNINTERRUPTRESULT_8A
OVERLAP_CONVENTIONAL_ERROR:
0x33a2:  5A                   pop        dx
0x33a3:  5B                   pop        bx
0x33a4:  E9 98 06             jmp        RETURNINTERRUPTRESULT_94
OFFSET_EXCEEDS_PAGE_SIZE_2:
0x33a7:  5A                   pop        dx
0x33a8:  5B                   pop        bx
0x33a9:  E9 98 06             jmp        RETURNINTERRUPTRESULT_95
WRAP_AROUND_1M_CONVENTIONAL_ERROR:
0x33ac:  5A                   pop        dx
0x33ad:  5B                   pop        bx
0x33ae:  E9 D4 06             jmp        RETURNINTERRUPTRESULT_A2
CHECK_MEMORY_TYPE_DEST:
0x33b1:  80 3E C6 28 01       cmp        byte ptr [func_24_dest_memory_type], 1
0x33b6:  75 4F                jne        CONVENTIONAL_MEMORY_TYPE_DEST
EXPANDED_MEMORY_TYPE_DEST:
0x33b8:  81 3E C9 28 FF 3F    cmp        word ptr [func_24_dest_initial_offset], 0x3fff
0x33be:  77 E7                ja         OFFSET_EXCEEDS_PAGE_SIZE_2
0x33c0:  8B 16 C7 28          mov        dx, word ptr [func_24_dest_handle]
0x33c4:  E8 75 F5             call       GET_EMM_HANDLE
0x33c7:  72 CF                jb         COULD_NOT_FIND_EMM_HANDLE_SPECIFIED_7
0x33c9:  A1 87 28             mov        ax, word ptr [get_emm_handle_result_pointer]
0x33cc:  A3 CD 28             mov        word ptr [func_24_emm_handle_result_pointer], ax
0x33cf:  8B F0                mov        si, ax
0x33d1:  A1 CB 28             mov        ax, word ptr [func_24_dest_initial_seg_page]
0x33d4:  39 04                cmp        word ptr [si], ax
0x33d6:  76 C5                jbe        OUT_OF_RANGE_EMM_HANDLE_2
0x33d8:  B8 00 40             mov        ax, 0x4000
0x33db:  F7 26 CB 28          mul        word ptr [func_24_dest_initial_seg_page]
0x33df:  03 06 C9 28          add        ax, word ptr [func_24_dest_initial_offset]
0x33e3:  83 D2 00             adc        dx, 0
0x33e6:  03 06 BB 28          add        ax, word ptr [func_24_region_length_low_word]
0x33ea:  13 16 BD 28          adc        dx, word ptr [func_24_region_length_high_word]
0x33ee:  2D 01 00             sub        ax, 1
0x33f1:  83 DA 00             sbb        dx, 0
0x33f4:  B9 00 40             mov        cx, 0x4000
0x33f7:  F7 F1                div        cx
0x33f9:  39 04                cmp        word ptr [si], ax
0x33fb:  76 A0                jbe        OUT_OF_RANGE_EMM_HANDLE_2
0x33fd:  A3 B3 28             mov        word ptr [func_24_temp_storage_5], ax
0x3400:  89 16 B5 28          mov        word ptr [func_24_temp_storage_6], dx
0x3404:  EB 6F                jmp        DO_DESTINATION_COPY
0x3406:  90                   nop        
CONVENTIONAL_MEMORY_TYPE_DEST:
; we're not actually checking for nonzero bad args i guess.
0x3407:  A1 CB 28             mov        ax, word ptr [func_24_dest_initial_seg_page]
0x340a:  B1 04                mov        cl, 4
0x340c:  32 F6                xor        dh, dh
0x340e:  8A D4                mov        dl, ah
0x3410:  D2 EA                shr        dl, cl
0x3412:  C1 E0 04             shl        ax, 4
0x3415:  03 06 C9 28          add        ax, word ptr [func_24_dest_initial_offset]
0x3419:  83 D2 00             adc        dx, 0
0x341c:  89 16 CB 28          mov        word ptr [func_24_dest_initial_seg_page], dx
0x3420:  A3 C9 28             mov        word ptr [func_24_dest_initial_offset], ax
0x3423:  03 06 BB 28          add        ax, word ptr [func_24_region_length_low_word]
0x3427:  13 16 BD 28          adc        dx, word ptr [func_24_region_length_high_word]
0x342b:  2D 01 00             sub        ax, 1
0x342e:  83 DA 00             sbb        dx, 0
0x3431:  83 FA 10             cmp        dx, 0x10
0x3434:  75 03                jne        CHECK_MEMORY_LENGTH_CONVENTIONAL_DEST
0x3436:  3D 00 00             cmp        ax, 0
CHECK_MEMORY_LENGTH_CONVENTIONAL_DEST:

0x3439:  76 03                jbe        MEMORY_LENGTH_OK
0x343b:  E9 6E FF             jmp        WRAP_AROUND_1M_CONVENTIONAL_ERROR
MEMORY_LENGTH_OK:
0x343e:  89 16 B3 28          mov        word ptr [func_24_temp_storage_5], dx
0x3442:  A3 B5 28             mov        word ptr [func_24_temp_storage_6], ax
0x3445:  8B 1E 81 28          mov        bx, word ptr [page_frame_segment]
0x3449:  C1 C3 04             rol        bx, 4
0x344c:  8B CB                mov        cx, bx
0x344e:  83 E3 F0             and        bx, 0xfff0
0x3451:  83 E1 0F             and        cx, 0xf
0x3454:  3B D1                cmp        dx, cx
0x3456:  75 02                jne        SKIP_COMPARE_3
0x3458:  3B C3                cmp        ax, bx
SKIP_COMPARE_3:
0x345a:  72 19                jb         DO_DESTINATION_COPY
0x345c:  8B 16 CB 28          mov        dx, word ptr [func_24_dest_initial_seg_page]
0x3460:  A1 C9 28             mov        ax, word ptr [func_24_dest_initial_offset]
0x3463:  81 C3 00 C0          add        bx, 0xc000
0x3467:  83 D1 00             adc        cx, 0
0x346a:  3B D1                cmp        dx, cx
0x346c:  75 02                jne        SKIP_COMPARE_4
0x346e:  3B C3                cmp        ax, bx
SKIP_COMPARE_4:
0x3470:  77 03                ja         DO_DESTINATION_COPY
0x3472:  E9 2D FF             jmp        OVERLAP_CONVENTIONAL_ERROR

DO_DESTINATION_COPY:
0x3475:  C6 06 D1 28 00       mov        byte ptr [func_24_overlapping_emm_handle], 0
0x347a:  C6 06 D2 28 00       mov        byte ptr [func_24_temp_storage_18], 0
0x347f:  80 3E BF 28 00       cmp        byte ptr [func_24_source_memory_type], 0
0x3484:  75 0A                jne        MEMORY_TYPE_NOT_CONVENTIONAL
0x3486:  80 3E C6 28 00       cmp        byte ptr [func_24_dest_memory_type], 0
0x348b:  74 0D                je         MEMORY_TYPE_CONVENTIONAL
0x348d:  E9 92 00             jmp        CHECK_HANDLE_OVERLAP

MEMORY_TYPE_NOT_CONVENTIONAL:
0x3490:  80 3E C6 28 01       cmp        byte ptr [func_24_dest_memory_type], 1
0x3495:  74 7A                je         MEMORY_TYPE_EXPANDED

0x3497:  E9 88 00             jmp        CHECK_HANDLE_OVERLAP
MEMORY_TYPE_CONVENTIONAL:
0x349a:  8B 0E C4 28          mov        cx, word ptr [func_24_source_initial_seg_page]
0x349e:  8B 1E C2 28          mov        bx, word ptr [func_24_source_initial_offset]
0x34a2:  8B 3E B7 28          mov        di, word ptr [func_24_temp_storage_3]
0x34a6:  8B 36 B9 28          mov        si, word ptr [func_24_temp_storage_4]
0x34aa:  8B 16 CB 28          mov        dx, word ptr [func_24_dest_initial_seg_page]
0x34ae:  A1 C9 28             mov        ax, word ptr [func_24_dest_initial_offset]
0x34b1:  3B D1                cmp        dx, cx
0x34b3:  75 07                jne        SKIP_COMPARE_6
0x34b5:  3B C3                cmp        ax, bx
0x34b7:  75 03                jne        SKIP_COMPARE_6
0x34b9:  E9 D8 05             jmp        RETURNINTERRUPTRESULT0
SKIP_COMPARE_6:
0x34bc:  72 3C                jb         SKIP_COMPARE_7
0x34be:  3B D7                cmp        dx, di
0x34c0:  75 02                jne        SKIP_COMPARE_8
0x34c2:  3B C6                cmp        ax, si
SKIP_COMPARE_8:
0x34c4:  77 5C                ja         CHECK_HANDLE_OVERLAP
0x34c6:  89 3E C4 28          mov        word ptr [func_24_source_initial_seg_page], di
0x34ca:  89 36 C2 28          mov        word ptr [func_24_source_initial_offset], si
0x34ce:  89 0E B7 28          mov        word ptr [func_24_temp_storage_3], cx
0x34d2:  89 1E B9 28          mov        word ptr [func_24_temp_storage_4], bx
0x34d6:  8B 2E B3 28          mov        bp, word ptr [func_24_temp_storage_5]
0x34da:  89 2E CB 28          mov        word ptr [func_24_dest_initial_seg_page], bp
0x34de:  8B 2E B5 28          mov        bp, word ptr [func_24_temp_storage_6]
0x34e2:  89 2E C9 28          mov        word ptr [func_24_dest_initial_offset], bp
0x34e6:  89 16 B3 28          mov        word ptr [func_24_temp_storage_5], dx
0x34ea:  A3 B5 28             mov        word ptr [func_24_temp_storage_6], ax
0x34ed:  C6 06 D1 28 FF       mov        byte ptr [func_24_overlapping_emm_handle], 0xff
0x34f2:  C6 06 D2 28 01       mov        byte ptr [func_24_temp_storage_18], 1
0x34f7:  EB 29                jmp        CHECK_HANDLE_OVERLAP
0x34f9:  90                   nop        
SKIP_COMPARE_7:
0x34fa:  8B 16 B3 28          mov        dx, word ptr [func_24_temp_storage_5]
0x34fe:  A1 B5 28             mov        ax, word ptr [func_24_temp_storage_6]
0x3501:  3B D1                cmp        dx, cx
0x3503:  75 02                jne        SKIP_COMPARE_5
0x3505:  3B C3                cmp        ax, bx
SKIP_COMPARE_5:
0x3507:  72 19                jb         CHECK_HANDLE_OVERLAP
0x3509:  C6 06 D1 28 FF       mov        byte ptr [func_24_overlapping_emm_handle], 0xff
0x350e:  EB 12                jmp        CHECK_HANDLE_OVERLAP
0x3510:  90                   nop        
MEMORY_TYPE_EXPANDED:
0x3511:  A1 C0 28             mov        ax, word ptr [func_24_source_handle]
0x3514:  39 06 C7 28          cmp        word ptr [func_24_dest_handle], ax
0x3518:  75 08                jne        CHECK_HANDLE_OVERLAP
0x351a:  E9 7D FF             jmp        MEMORY_TYPE_CONVENTIONAL
; cant overlap on exchange
HANDLE_OVERLAP_ERROR:
0x351d:  5A                   pop        dx
0x351e:  5B                   pop        bx
0x351f:  E9 2C 05             jmp        RETURNINTERRUPTRESULT_97

CHECK_HANDLE_OVERLAP:
0x3522:  80 3E D1 28 FF       cmp        byte ptr [func_24_overlapping_emm_handle], 0xff
0x3527:  75 07                jne        HANDLE_NOT_OVERLAPPING
0x3529:  A1 A5 28             mov        ax, word ptr [stored_ax]
0x352c:  3C 01                cmp        al, 1
0x352e:  74 ED                je         HANDLE_OVERLAP_ERROR
HANDLE_NOT_OVERLAPPING
0x3530:  FC                   cld        
0x3531:  C7 06 D9 28 00 10    mov        word ptr [func_24_temp_storage_22], 0x1000
0x3537:  C7 06 DB 28 01 00    mov        word ptr [func_24_temp_storage_23], 1
0x353d:  C7 06 D7 28 00 00    mov        word ptr [func_24_temp_storage_21], 0
0x3543:  C7 06 D5 28 00 40    mov        word ptr [func_24_temp_storage_20], 0x4000
0x3549:  C7 06 D3 28 00 00    mov        word ptr [func_24_temp_storage_19], 0
0x354f:  80 3E D2 28 00       cmp        byte ptr [func_24_temp_storage_18], 0
0x3554:  74 1F                je         BEGIN_COPYING
0x3556:  FD                   std        

0x3557:  C7 06 D9 28 00 F0    mov        word ptr [func_24_temp_storage_22], 0xf000
0x355d:  C7 06 DB 28 FF FF    mov        word ptr [func_24_temp_storage_23], 0xffff
0x3563:  C7 06 D7 28 FF FF    mov        word ptr [func_24_temp_storage_21], 0xffff
0x3569:  C7 06 D5 28 FF FF    mov        word ptr [func_24_temp_storage_20], 0xffff
0x356f:  C7 06 D3 28 FF 3F    mov        word ptr [func_24_temp_storage_19], 0x3fff

BEGIN_COPYING:
0x3575:  B0 00                mov        al, 0
0x3577:  E8 13 F5             call       GET_PAGE_FRAME_REGISTER_FOR_INDEX
0x357a:  E8 00 F4             call       READEMSPORT
0x357d:  A3 A9 28             mov        word ptr [page_map_call_stored_dx], ax
0x3580:  B0 01                mov        al, 1
0x3582:  E8 08 F5             call       GET_PAGE_FRAME_REGISTER_FOR_INDEX
0x3585:  E8 F5 F3             call       READEMSPORT
0x3588:  A3 AD 28             mov        word ptr [page_map_call_stored_si], ax
0x358b:  80 3E BF 28 00       cmp        byte ptr [func_24_source_memory_type], 0
0x3590:  75 10                jne        DO_EXPANDED_COPY
0x3592:  A1 C4 28             mov        ax, word ptr [func_24_source_initial_seg_page]
0x3595:  C1 C8 04             ror        ax, 4
0x3598:  8E D8                mov        ds, ax
0x359a:  2E 8B 36 C2 28       mov        si, word ptr cs:[func_24_source_initial_offset]
0x359f:  EB 21                jmp        DO_COPY
0x35a1:  90                   nop        
DO_EXPANDED_COPY:
0x35a2:  2E 8B 36 C2 28       mov        si, word ptr cs:[func_24_source_initial_offset]
0x35a7:  2E 8E 1E 81 28       mov        ds, word ptr cs:[page_frame_segment]
0x35ac:  2E 8B 1E C4 28       mov        bx, word ptr cs:[func_24_source_initial_seg_page]
0x35b1:  2E 8B 16 C0 28       mov        dx, word ptr cs:[func_24_source_handle]
0x35b6:  B8 00 44             mov        ax, 0x4400     ; DO EMS map/unmap page 0
0x35b9:  CD 67                int        0x67
0x35bb:  0A E4                or         ah, ah
0x35bd:  74 03                je         DO_COPY
0x35bf:  E9 F0 FC             jmp        SOME_SORT_OF_MALFUNCTION_2
DO_COPY:
0x35c2:  2E 80 3E C6 28 00    cmp        byte ptr cs:[func_24_dest_memory_type], 0
0x35c8:  75 19                jne        DO_COPY_TO_EXPANDED
0x35ca:  2E A1 CB 28          mov        ax, word ptr cs:[func_24_dest_initial_seg_page]
0x35ce:  C1 C8 04             ror        ax, 4
0x35d1:  8E C0                mov        es, ax
0x35d3:  2E 8B 3E C9 28       mov        di, word ptr cs:[func_24_dest_initial_offset]
0x35d8:  2E 80 3E BF 28 00    cmp        byte ptr cs:[func_24_source_memory_type], 0
0x35de:  74 32                je         HANDLE_NEXT_BYTE_4
0x35e0:  E9 C5 00             jmp        HANDLE_NEXT_BYTE
DO_COPY_TO_EXPANDED:
0x35e3:  2E A1 81 28          mov        ax, word ptr cs:[page_frame_segment]
0x35e7:  05 00 04             add        ax, 0x400
0x35ea:  8E C0                mov        es, ax
0x35ec:  2E 8B 3E C9 28       mov        di, word ptr cs:[func_24_dest_initial_offset]
0x35f1:  2E 8B 1E CB 28       mov        bx, word ptr cs:[func_24_dest_initial_seg_page]
0x35f6:  2E 8B 16 C7 28       mov        dx, word ptr cs:[func_24_dest_handle]
0x35fb:  B8 01 44             mov        ax, 0x4401   ; DO EMS map/unmap page 1
0x35fe:  CD 67                int        0x67
0x3600:  0A E4                or         ah, ah
0x3602:  74 03                je         PAGE_REMAP_WAS_OK
0x3604:  E9 AB FC             jmp        SOME_SORT_OF_MALFUNCTION_2

PAGE_REMAP_WAS_OK:
0x3607:  2E 80 3E BF 28 00    cmp        byte ptr cs:[func_24_source_memory_type], 0
0x360d:  74 55                je         HANDLE_NEXT_BYTE_3
0x360f:  E9 DA 00             jmp        HANDLE_NEXT_BYTE_2

HANDLE_NEXT_BYTE_4:
0x3612:  2E A1 A5 28          mov        ax, word ptr cs:[stored_ax]
0x3616:  3D 00 00             cmp        ax, 0
0x3619:  74 0C                je         OPERATION_IS_COPY_4
0x361b:  26 8A 25             mov        ah, byte ptr es:[di]
0x361e:  8A 04                mov        al, byte ptr [si]
0x3620:  88 24                mov        byte ptr [si], ah
0x3622:  AA                   stosb      byte ptr es:[di], al
0x3623:  AC                   lodsb      al, byte ptr [si]
0x3624:  EB 02                   jmp        OPERATION_IS_EXCHANGE_4
0x3626:  90                      nop        
OPERATION_IS_COPY_4:
0x3627:  A4                      movsb      byte ptr es:[di], byte ptr [si]
OPERATION_IS_EXCHANGE_4:
0x3628:  2E 83 2E BB 28 01       sub        word ptr cs:[func_24_region_length_low_word], 1
0x362e:  2E 83 1E BD 28 00       sbb        word ptr cs:[func_24_region_length_high_word], 0
0x3634:  2E A1 BB 28             mov        ax, word ptr cs:[func_24_region_length_low_word]
0x3638:  2E 0B 06 BD 28          or         ax, word ptr cs:[func_24_region_length_high_word]
0x363d:  75 03                   jne        CONTINUE_IN_SAME_PAGE_4
0x363f:  E9 3A 01                jmp        HANDLE_PAGE_CHANGE
CONTINUE_IN_SAME_PAGE_4:
0x3642:  2E 3B 36 D7 28          cmp        si, word ptr cs:[func_24_temp_storage_21]
0x3647:  75 09                   jne        SKIP_SOMETHING_NOT_SURE_4
0x3649:  8C D8                   mov        ax, ds
0x364b:  2E 03 06 D9 28          add        ax, word ptr cs:[func_24_temp_storage_22]
0x3650:  8E D8                   mov        ds, ax
SKIP_SOMETHING_NOT_SURE_4:
0x3652:  2E 3B 3E D7 28          cmp        di, word ptr cs:[func_24_temp_storage_21]
0x3657:  75 B9                   jne        HANDLE_NEXT_BYTE_4
0x3659:  8C C0                   mov        ax, es
0x365b:  2E 03 06 D9 28          add        ax, word ptr cs:[func_24_temp_storage_22]
0x3660:  8E C0                   mov        es, ax
0x3662:  EB AE                   jmp        HANDLE_NEXT_BYTE_4

HANDLE_NEXT_BYTE_3:
0x3664:  2E A1 A5 28             mov        ax, word ptr cs:[stored_ax]
0x3668:  3C 00                   cmp        al, 0
0x366a:  74 0C                   je         OPERATION_IS_COPY_3
0x366c:  26 8A 25                mov        ah, byte ptr es:[di]
0x366f:  8A 04                   mov        al, byte ptr [si]
0x3671:  88 24                   mov        byte ptr [si], ah
0x3673:  AA                      stosb      byte ptr es:[di], al
0x3674:  AC                      lodsb      al, byte ptr [si]
0x3675:  EB 02                   jmp        OPERATION_IS_EXCHANGE_3
0x3677:  90                      nop        
OPERATION_IS_COPY_3:
0x3678:  A4                      movsb      byte ptr es:[di], byte ptr [si]
OPERATION_IS_EXCHANGE_3:
0x3679:  2E 83 2E BB 28 01       sub        word ptr cs:[func_24_region_length_low_word], 1
0x367f:  2E 83 1E BD 28 00       sbb        word ptr cs:[func_24_region_length_high_word], 0
0x3685:  2E A1 BB 28             mov        ax, word ptr cs:[func_24_region_length_low_word]
0x3689:  2E 0B 06 BD 28          or         ax, word ptr cs:[func_24_region_length_high_word]
0x368e:  75 03                   jne        CONTINUE_IN_SAME_PAGE_3
0x3690:  E9 E9 00                jmp        HANDLE_PAGE_CHANGE
CONTINUE_IN_SAME_PAGE_3:
0x3693:  E8 BC 00                call       MYSTERY_FUNCTION_7
0x3696:  2E 3B 36 D7 28          cmp        si, word ptr cs:[func_24_temp_storage_21]
0x369b:  75 C7                   jne        HANDLE_NEXT_BYTE_3
0x369d:  8C D8                   mov        ax, ds
0x369f:  2E 03 06 D9 28          add        ax, word ptr cs:[func_24_temp_storage_22]
0x36a4:  8E D8                   mov        ds, ax
0x36a6:  EB BC                   jmp        HANDLE_NEXT_BYTE_3

HANDLE_NEXT_BYTE:
0x36a8:  2E A1 A5 28             mov        ax, word ptr cs:[stored_ax]
0x36ac:  3C 00                   cmp        al, 0
0x36ae:  74 0C                   je         OPERATION_IS_COPY
; operation is exchange..
0x36b0:  26 8A 25                mov        ah, byte ptr es:[di]
0x36b3:  8A 04                   mov        al, byte ptr [si]
0x36b5:  88 24                   mov        byte ptr [si], ah
0x36b7:  AA                      stosb      byte ptr es:[di], al
0x36b8:  AC                      lodsb      al, byte ptr [si]
0x36b9:  EB 02                   jmp        OPERATION_IS_EXCHANGE
0x36bb:  90                      nop        

; byte is copied, so the exchange still happens but 'exchanges' nothing
OPERATION_IS_COPY:
0x36bc:  A4                      movsb      byte ptr es:[di], byte ptr [si]
OPERATION_IS_EXCHANGE:
0x36bd:  2E 83 2E BB 28 01       sub        word ptr cs:[func_24_region_length_low_word], 1     ; decrement counter
0x36c3:  2E 83 1E BD 28 00       sbb        word ptr cs:[func_24_region_length_high_word], 0    ; with carry
0x36c9:  2E A1 BB 28             mov        ax, word ptr cs:[func_24_region_length_low_word]    ; get addr
0x36cd:  2E 0B 06 BD 28          or         ax, word ptr cs:[func_24_region_length_high_word]
0x36d2:  75 03                   jne        DO_FUNC_8_1
0x36d4:  E9 A5 00                jmp        HANDLE_PAGE_CHANGE
DO_FUNC_8_1:
0x36d7:  E8 4A 00                call       MYSTERY_FUNCTION_8
0x36da:  2E 3B 3E D7 28          cmp        di, word ptr cs:[func_24_temp_storage_21]
0x36df:  75 C7                   jne        HANDLE_NEXT_BYTE
0x36e1:  8C C0                   mov        ax, es
0x36e3:  2E 03 06 D9 28          add        ax, word ptr cs:[func_24_temp_storage_22]
0x36e8:  8E C0                   mov        es, ax
0x36ea:  EB BC                   jmp        HANDLE_NEXT_BYTE

HANDLE_NEXT_BYTE_2:
0x36ec:  2E A1 A5 28             mov        ax, word ptr cs:[stored_ax]
0x36f0:  3D 00 00                cmp        ax, 0
0x36f3:  74 0C                   je         OPERATION_IS_COPY_2
0x36f5:  26 8A 25                mov        ah, byte ptr es:[di]
0x36f8:  8A 04                   mov        al, byte ptr [si]
0x36fa:  88 24                   mov        byte ptr [si], ah
0x36fc:  AA                      stosb      byte ptr es:[di], al
0x36fd:  AC                      lodsb      al, byte ptr [si]
0x36fe:  EB 02                   jmp        OPERATION_IS_EXCHANGE_2
0x3700:  90                      nop        
OPERATION_IS_COPY_2:
0x3701:  A4                      movsb      byte ptr es:[di], byte ptr [si]
OPERATION_IS_EXCHANGE_2:
0x3702:  2E 83 2E BB 28 01       sub        word ptr cs:[func_24_region_length_low_word], 1
0x3708:  2E 83 1E BD 28 00       sbb        word ptr cs:[func_24_region_length_high_word], 0
0x370e:  2E A1 BB 28             mov        ax, word ptr cs:[func_24_region_length_low_word]
0x3712:  2E 0B 06 BD 28          or         ax, word ptr cs:[func_24_region_length_high_word]
0x3717:  75 03                   jne        DO_FUNC_7_8
0x3719:  EB 61                   jmp        HANDLE_PAGE_CHANGE
0x371b:  90                      nop        
DO_FUNC_7_8:
0x371c:  E8 33 00                call       MYSTERY_FUNCTION_7
0x371f:  E8 02 00                call       MYSTERY_FUNCTION_8
0x3722:  EB C8                   jmp        HANDLE_NEXT_BYTE_2

; seems to check bounds and change pages if necessary
MYSTERY_FUNCTION_8:
0x3724:  2E 3B 36 D5 28          cmp        si, word ptr cs:[func_24_temp_storage_20]
0x3729:  75 22                   jne        POINTER_NOT_EQUAL_1
0x372b:  2E 8B 1E C4 28          mov        bx, word ptr cs:[func_24_source_initial_seg_page]
0x3730:  2E 03 1E DB 28          add        bx, word ptr cs:[func_24_temp_storage_23]
0x3735:  2E 89 1E C4 28          mov        word ptr cs:[func_24_source_initial_seg_page], bx
0x373a:  2E 8B 16 C0 28          mov        dx, word ptr cs:[func_24_source_handle]
0x373f:  B8 00 44                mov        ax, 0x4400      ; DO EMS map/unmap page 0
0x3742:  CD 67                   int        0x67
0x3744:  0A E4                   or         ah, ah
0x3746:  75 06                   jne        POP_AND_RETURN
0x3748:  2E 8B 36 D3 28          mov        si, word ptr cs:[func_24_temp_storage_19]
POINTER_NOT_EQUAL_1:
0x374d:  C3                      ret
POP_AND_RETURN:
0x374e:  58                      pop        ax
0x374f:  E9 60 FB                jmp        SOME_SORT_OF_MALFUNCTION_2

; seems to check bounds and change pages if necessary
MYSTERY_FUNCTION_7:
0x3752:  2E 3B 3E D5 28          cmp        di, word ptr cs:[func_24_temp_storage_20]
0x3757:  75 22                   jne        POINTER_NOT_EQUAL_2
0x3759:  2E 8B 1E CB 28          mov        bx, word ptr cs:[func_24_dest_initial_seg_page]
0x375e:  2E 03 1E DB 28          add        bx, word ptr cs:[func_24_temp_storage_23]
0x3763:  2E 89 1E CB 28          mov        word ptr cs:[func_24_dest_initial_seg_page], bx
0x3768:  2E 8B 16 C7 28          mov        dx, word ptr cs:[func_24_dest_handle]
0x376d:  B8 01 44                mov        ax, 0x4401   ; DO EMS map/unmap page 1
0x3770:  CD 67                   int        0x67
0x3772:  0A E4                   or         ah, ah
0x3774:  75 D8                   jne        POP_AND_RETURN
0x3776:  2E 8B 3E D3 28          mov        di, word ptr cs:[func_24_temp_storage_19]
POINTER_NOT_EQUAL_2
0x377b:  C3                      ret

HANDLE_PAGE_CHANGE:
0x377c:  0E                      push       cs
0x377d:  1F                      pop        ds
0x377e:  B0 00                   mov        al, 0
0x3780:  8B 1E A9 28             mov        bx, word ptr [page_map_call_stored_dx]
0x3784:  E8 0C F2                call       TURN_ON_EMS_PAGE
0x3787:  B0 01                   mov        al, 1
0x3789:  8B 1E A9 28             mov        bx, word ptr [page_map_call_stored_dx]
0x378d:  E8 03 F2                call       TURN_ON_EMS_PAGE
0x3790:  E9 F4 FB                jmp        COPY_DONE

;          25 Get Mappable Physical Address Array            5800h     
;             Get Mappable Physical Address Array Entries    5801h     


EMS_FUNCTION_0x58:
0x3793:  83 C4 0C                add        sp, 0xc
0x3796:  3C 00                   cmp        al, 0
0x3798:  75 28                   jne        EXITINTERRUPTB
0x379a:  1E                      push       ds
0x379b:  06                      push       es
0x379c:  56                      push       si
0x379d:  57                      push       di
0x379e:  53                      push       bx
0x379f:  0E                      push       cs
0x37a0:  1F                      pop        ds
0x37a1:  BE BF 27                mov        si, OFFSET page_register_data_pointers
0x37a4:  2E 8B 0E A1 28          mov        cx, word ptr cs:[number_ems_pages]
0x58_LOOP:
0x37a9:  8B 04                   mov        ax, word ptr [si]
0x37ab:  AB                      stosw      word ptr es:[di], ax
0x37ac:  8B 44 02                mov        ax, word ptr [si + 2]
0x37af:  AB                      stosw      word ptr es:[di], ax
0x37b0:  83 C6 04                add        si, 4
0x37b3:  E2 F4                   loop       0x58_LOOP
0x37b5:  2E 8B 0E A1 28          mov        cx, word ptr cs:[number_ems_pages]
0x37ba:  B4 00                   mov        ah, 0
0x37bc:  5B                      pop        bx
0x37bd:  5F                      pop        di
0x37be:  5E                      pop        si
0x37bf:  07                      pop        es
0x37c0:  1F                      pop        ds
0x37c1:  CF                      iret
EXITINTERRUPTB:
0x37c2:  3C 01                   cmp        al, 1
0x37c4:  75 09                   jne        EXITINTERRUPTB_RESULT8F
0x37c6:  2E 8B 0E A1 28          mov        cx, word ptr cs:[number_ems_pages]
0x37cb:  B8 00 00                mov        ax, 0
0x37ce:  CF                      iret
EXITINTERRUPTB_RESULT8F:
0x37cf:  B4 8F                   mov        ah, 0x8f
0x37d1:  CF                      iret

;          26 Get Hardware Configuration Array               5900h     
;             Get Unallocated Raw Page Count                 5901h     

EMS_FUNCTION_0x59:
0x37d2:  3C 00                   cmp        al, 0
0x37d4:  75 25                   jne        NOT_0x5900
EMS_FUNCTION_0x5900:
0x37d6:  0E                      push       cs
0x37d7:  1F                      pop        ds
0x37d8:  80 3E DD 28 FF          cmp        byte ptr [ose_function_set_enabled_1], 0xff
0x37dd:  75 19                   jne        DENIED_BY_OS
0x37df:  8D 36 E3 28             lea        si, [hardware_configuration_array]
0x37e3:  50                      push       ax
0x37e4:  2E A1 A1 28             mov        ax, word ptr cs:[number_ems_pages]
0x37e8:  D1 E0                   shl        ax, 1
0x37ea:  89 44 04                mov        word ptr [si + 4], ax
0x37ed:  58                      pop        ax
0x37ee:  51                      push       cx
0x37ef:  B9 05 00                mov        cx, 5
0x37f2:  F3 A5                   rep movsw  word ptr es:[di], word ptr [si]
0x37f4:  59                      pop        cx
0x37f5:  E9 9C 02                jmp        RETURNINTERRUPTRESULT0
DENIED_BY_OS:
0x37f8:  E9 94 02                jmp        RETURNINTERRUPTRESULT_A4
NOT_0x5900:
0x37fb:  3C 01                   cmp        al, 1
0x37fd:  75 0D                   jne        BAD_SUBFUNCTION_PARAMETER_4
EMS_FUNCTION_0x5901:
0x37ff:  2E 8B 16 95 28          mov        dx, word ptr cs:[unallocated_page_count]
0x3804:  2E 8B 1E 89 28          mov        bx, word ptr cs:[total_page_count]
0x3809:  E9 88 02                jmp        RETURNINTERRUPTRESULT0
BAD_SUBFUNCTION_PARAMETER_4:
0x380c:  E9 17 02                jmp        RETURN_BAD_SUBFUNCTION_PARAMETER


;          27 Allocate Standard Pages                        5A00h     
;             Allocate Raw Pages                             5A01h     

EMS_FUNCTION_0x5a:
0x380f:  0E                      push       cs
0x3810:  1F                      pop        ds
0x3811:  3C 01                   cmp        al, 1
0x3813:  77 04                   ja         BAD_SUBFUNCTION_PARAMETER_5
0x3815:  53                      push       bx
0x3816:  E9 45 F3                jmp        DO_ALLOCATE_PAGE   ; i guess this maps to function 04??
BAD_SUBFUNCTION_PARAMETER_5:
0x3819:  E9 0A 02                jmp        RETURN_BAD_SUBFUNCTION_PARAMETER

;          28 Get Alternate Map Register Set                 5B00h     
;             Set Alternate Map Register Set                 5B01h     
;             Get Alternate Map Save Array Size              5B02h     
;             Allocate Alternate Map Register Set            5B03h     
;             Deallocate Alternate Map Register Set          5B04h     
;             Allocate DMA Register Set                      5B05h     
;             Enable DMA on Alternate Map Register Set       5B06h     
;             Disable DMA on Alternate Map Register Set      5B07h     
;             Deallocate DMA Register Set                    5B08h     



EMS_FUNCTION_0x5B:
0x381c:  2E 80 3E DD 28 FF       cmp        byte ptr cs:[ose_function_set_enabled_1], 0xff
0x3822:  75 2E                   jne        DENIED_BY_OS_1
0x3824:  3C 00                   cmp        al, 0
0x3826:  75 2D                   jne        NOT_0x5B00
EMS_FUNCTION_0x5B00:
0x3828:  83 C4 0C                add        sp, 0xc
0x382b:  2E 8E 06 DF 28          mov        es, word ptr cs:[stored_es]
0x3830:  2E 8B 3E E1 28          mov        di, word ptr cs:[stored_di]
0x3835:  8C C0                   mov        ax, es
0x3837:  0B C7                   or         ax, di
0x3839:  74 0A                   je         JUMP_TO_RETURN
0x383b:  51                      push       cx
0x383c:  2E 8B 0E A1 28          mov        cx, word ptr cs:[number_ems_pages]
0x3841:  E8 7C F2                call       GET_EMS_REGISTER_DATA
0x3844:  59                      pop        cx
JUMP_TO_RETURN:
0x3845:  2E 8E 06 DF 28          mov        es, word ptr cs:[stored_es]
0x384a:  2E 8B 3E E1 28          mov        di, word ptr cs:[stored_di]
0x384f:  B3 00                   mov        bl, 0
0x3851:  CF                      iret
DENIED_BY_OS_1:
0x3852:  E9 3A 02                jmp        RETURNINTERRUPTRESULT_A4
NOT_0x5B00:
0x3855:  3C 01                   cmp        al, 1
0x3857:  74 03                   je         EMS_FUNCTION_0x5B01
0x3859:  EB 34                   jmp        NOT_0x5B01
0x385b:  90                      nop        
EMS_FUNCTION_0x5B01:
0x385c:  53                      push       bx
0x385d:  52                      push       dx
0x385e:  80 FB 00                cmp        bl, 0
0x3861:  75 25                   jne        DMA_REGISTER_SET_ERROR_2
0x3863:  2E 89 3E E1 28          mov        word ptr cs:[stored_di], di
0x3868:  2E 8C 06 DF 28          mov        word ptr cs:[stored_es], es
0x386d:  8C C0                   mov        ax, es
0x386f:  0B C7                   or         ax, di
0x3871:  74 0E                   je         RETURN_OK_2
0x3873:  06                      push       es
0x3874:  1F                      pop        ds
0x3875:  8B F7                   mov        si, di
0x3877:  51                      push       cx
0x3878:  2E 8B 0E A1 28          mov        cx, word ptr cs:[number_ems_pages]
0x387d:  E8 65 F2                call       WRITE_PAGE_MAP
0x3880:  59                      pop        cx
RETURN_OK_2:
0x3881:  5A                      pop        dx
0x3882:  5B                      pop        bx
0x3883:  B4 00                   mov        ah, 0
0x3885:  E9 0C 02                jmp        RETURNINTERRUPTRESULT0
DMA_REGISTER_SET_ERROR_2:
0x3888:  5A                      pop        dx
0x3889:  5B                      pop        bx
0x388a:  B4 9C                   mov        ah, 0x9c
0x388c:  E9 D8 01                jmp        RETURNINTERRUPTRESULT_9C
NOT_0x5B01:

0x388f:  3C 02                   cmp        al, 2
0x3891:  75 13                   jne        NOT_0x5B02
EMS_FUNCTION_0x5B02:

0x3893:  2E A1 A1 28             mov        ax, word ptr cs:[number_ems_pages]
0x3897:  D1 E0                   shl        ax, 1
0x3899:  05 02 00                add        ax, 2
0x389c:  05 02 00                add        ax, 2
0x389f:  8B D0                   mov        dx, ax
0x38a1:  B4 00                   mov        ah, 0
0x38a3:  E9 EE 01                jmp        RETURNINTERRUPTRESULT0
NOT_0x5B02:
0x38a6:  3C 03                   cmp        al, 3
0x38a8:  75 07                   jne        NOT_0x5B03
0x38aa:  B3 00                   mov        bl, 0
0x38ac:  B4 00                   mov        ah, 0
0x38ae:  E9 E3 01                jmp        RETURNINTERRUPTRESULT0
NOT_0x5B03:
0x38b1:  3C 04                   cmp        al, 4
0x38b3:  75 0D                   jne        NOT_0x5B04
0x38b5:  80 FB 00                cmp        bl, 0
0x38b8:  75 05                   jne        DMA_REGISTER_SET_ERROR
0x38ba:  B4 00                   mov        ah, 0
0x38bc:  E9 D5 01                jmp        RETURNINTERRUPTRESULT0
DMA_REGISTER_SET_ERROR:
0x38bf:  E9 A5 01                jmp        RETURNINTERRUPTRESULT_9C
NOT_0x5B04:
0x38c2:  3C 05                   cmp        al, 5
0x38c4:  75 07                   jne        NOT_0x5B05
0x38c6:  B3 00                   mov        bl, 0
0x38c8:  B4 00                   mov        ah, 0
0x38ca:  E9 C7 01                jmp        RETURNINTERRUPTRESULT0
NOT_0x5B05:
0x38cd:  3C 06                   cmp        al, 6
0x38cf:  75 0A                   jne        NOT_0x5B06
0x38d1:  80 FB 00                cmp        bl, 0
0x38d4:  75 E9                   jne        DMA_REGISTER_SET_ERROR
0x38d6:  B4 00                   mov        ah, 0
0x38d8:  E9 B9 01                jmp        RETURNINTERRUPTRESULT0
NOT_0x5B06:
0x38db:  3C 07                   cmp        al, 7
0x38dd:  75 0A                   jne        NOT_0x5B07
0x38df:  80 FB 00                cmp        bl, 0
0x38e2:  75 DB                   jne        DMA_REGISTER_SET_ERROR
0x38e4:  B4 00                   mov        ah, 0
0x38e6:  E9 AB 01                jmp        RETURNINTERRUPTRESULT0
NOT_0x5B07:
0x38e9:  3C 08                   cmp        al, 8
0x38eb:  75 0A                   jne        NOT_0x5B08
0x38ed:  80 FB 00                cmp        bl, 0
0x38f0:  75 CD                   jne        DMA_REGISTER_SET_ERROR
0x38f2:  B4 00                   mov        ah, 0
0x38f4:  E9 9D 01                jmp        RETURNINTERRUPTRESULT0
NOT_0x5B08:
0x38f7:  EB FE                   jmp        NOT_0x5B08   ; BUG:  infinite loop?

;          29 Prepare Expanded Memory Hardware for Warmboot  5Ch       

EMS_FUNCTION_0x5C:
0x38f9:  53                      push       bx
0x38fa:  8C C8                   mov        ax, cs
0x38fc:  8E D8                   mov        ds, ax
0x38fe:  8E C0                   mov        es, ax
0x3900:  8D 3E BD 00             lea        di, OFFSET handle_table
0x3904:  57                      push       di
0x3905:  32 C0                   xor        al, al
0x3907:  BB FF 00                mov        bx, 0xff
ZERO_OUT_HANDLE_TABLE_LOOP:
0x390a:  B9 17 00                mov        cx, 0x17
0x390d:  F3 AA                   rep stosb  byte ptr es:[di], al
0x390f:  4B                      dec        bx
0x3910:  75 F8                   jne        ZERO_OUT_HANDLE_TABLE_LOOP
0x3912:  5F                      pop        di
0x3913:  81 C7 02 00             add        di, 2
0x3917:  8D 36 F0 28             lea        si, [warmboot_data]
0x391b:  B9 08 00                mov        cx, 8
0x391e:  F3 A4                   rep movsb  byte ptr es:[di], byte ptr [si]
0x3920:  8D 06 CD 17             lea        ax, OFFSET backfill_page_map
0x3924:  AB                      stosw      word ptr es:[di], ax
0x3925:  8D 3E CD 17             lea        di, OFFSET backfill_page_map
0x3929:  33 C0                   xor        ax, ax
0x392b:  B9 DC 03                mov        cx, 0x3dc
ZERO_OUT_BACKFILL_PAGE_MAP_LOOP:
0x392e:  81 C7 02 00             add        di, 2
0x3932:  AB                      stosw      word ptr es:[di], ax
0x3933:  E2 F9                   loop       ZERO_OUT_BACKFILL_PAGE_MAP_LOOP
0x3935:  B8 FF 00                mov        ax, 0xff
0x3938:  48                      dec        ax
0x3939:  A3 85 28                mov        word ptr [handle_count], ax
0x393c:  A1 95 28                mov        ax, word ptr [unallocated_page_count]
0x393f:  A3 89 28                mov        word ptr [total_page_count], ax
0x3942:  5B                      pop        bx
0x3943:  E9 4E 01                jmp        RETURNINTERRUPTRESULT0

;          30 Enable OS/E Function Set                       5D00h     
;             Disable OS/E Function Set                      5D01h     
;             Return OS/E Access Key                         5D02h     


EMS_FUNCTION_0x5D:
0x3946:  0E                      push       cs
0x3947:  1F                      pop        ds
0x3948:  83 C4 0C                add        sp, 0xc
0x394b:  3C 00                   cmp        al, 0
0x394d:  75 2B                   jne        NOT_0x5D00
EMS_FUNCTION_0x5D00:
0x394f:  80 3E DE 28 FF          cmp        byte ptr [ose_function_set_enabled_2], 0xff
0x3954:  74 0B                   je         CHECK_OS_RIGHTS_PASSWORD_2
0x3956:  8B 1E 75 28             mov        bx, word ptr [os_password_low]
0x395a:  8B 0E 77 28             mov        cx, word ptr [os_password_high]
0x395e:  EB 0D                   jmp        PASSWORD_OK_2
0x3960:  90                      nop        
CHECK_OS_RIGHTS_PASSWORD_2:
0x3961:  3B 1E 75 28             cmp        bx, word ptr [os_password_low]
0x3965:  75 42                   jne        DENIED_BY_OS_2
0x3967:  3B 0E 77 28             cmp        cx, word ptr [os_password_high]
0x396b:  75 3C                   jne        DENIED_BY_OS_2
PASSWORD_OK_2:
0x396d:  C6 06 DD 28 FF          mov        byte ptr [ose_function_set_enabled_1], 0xff
0x3972:  C6 06 DE 28 FF          mov        byte ptr [ose_function_set_enabled_2], 0xff
0x3977:  B4 00                   mov        ah, 0
0x3979:  CF                      iret
NOT_0x5D00:
0x397a:  3C 01                   cmp        al, 1
0x397c:  75 31                   jne        NOT_0x5D01
EMS_FUNCTION_0x5D01:
0x397e:  80 3E DE 28 FF          cmp        byte ptr [ose_function_set_enabled_2], 0xff
0x3983:  74 0B                   je         CHECK_OS_RIGHTS_PASSWORD
0x3985:  8B 1E 75 28             mov        bx, word ptr [os_password_low]
0x3989:  8B 0E 77 28             mov        cx, word ptr [os_password_high]
0x398d:  EB 0D                   jmp        PASSWORD_OK
0x398f:  90                      nop        
CHECK_OS_RIGHTS_PASSWORD:
0x3990:  3B 1E 75 28             cmp        bx, word ptr [os_password_low]
0x3994:  75 13                   jne        DENIED_BY_OS_2
0x3996:  3B 0E 77 28             cmp        cx, word ptr [os_password_high]
0x399a:  75 0D                   jne        DENIED_BY_OS_2
PASSWORD_OK:
0x399c:  C6 06 DD 28 00          mov        byte ptr [ose_function_set_enabled_1], 0
0x39a1:  C6 06 DE 28 FF          mov        byte ptr [ose_function_set_enabled_2], 0xff
0x39a6:  B4 00                   mov        ah, 0
0x39a8:  CF                      iret

DENIED_BY_OS_2:
0x39a9:  B4 A4                   mov        ah, 0xa4
0x39ab:  CF                      iret

BAD_SUBFUNCTION_PARAMETER_6:
0x39ac:  B4 8F                   mov        ah, 0x8f
0x39ae:  CF                      iret
NOT_0x5D01:
0x39af:  3C 02                   cmp        al, 2
0x39b1:  75 F9                   jne        BAD_SUBFUNCTION_PARAMETER_6
EMS_FUNCTION_0x5D02:
0x39b3:  80 3E DE 28 FF          cmp        byte ptr [ose_function_set_enabled_2], 0xff
0x39b8:  75 EF                   jne        DENIED_BY_OS_2
0x39ba:  3B 1E 75 28             cmp        bx, word ptr [os_password_low]
0x39be:  75 E9                   jne        DENIED_BY_OS_2
0x39c0:  3B 0E 77 28             cmp        cx, word ptr [os_password_high]
0x39c4:  75 E3                   jne        DENIED_BY_OS_2
0x39c6:  02 F9                   add        bh, cl
0x39c8:  2A EB                   sub        ch, bl
0x39ca:  86 FD                   xchg       ch, bh
0x39cc:  D1 C3                   rol        bx, 1
0x39ce:  D1 C9                   ror        cx, 1
0x39d0:  89 1E 75 28             mov        word ptr [os_password_low], bx
0x39d4:  89 0E 77 28             mov        word ptr [os_password_high], cx
0x39d8:  C6 06 DD 28 FF          mov        byte ptr [ose_function_set_enabled_1], 0xff
0x39dd:  C6 06 DE 28 00          mov        byte ptr [ose_function_set_enabled_2], 0
0x39e2:  B4 00                   mov        ah, 0
0x39e4:  CF                      iret

; JUMP TABLE FOR EMS RETURN VALUES

; The manager detected a malfunction in the memory manager software.
RETURNINTERRUPTRESULT_80:
0x39e5:  B4 80                   mov        ah, 0x80
0x39e7:  E9 AC 00                jmp        RETURNINTERRUPTRESULT

; The memory manager couldn't find the EMM handle your program specified.
RETURNINTERRUPTRESULT_83:
0x39ea:  B4 83                   mov        ah, 0x83
0x39ec:  E9 A7 00                jmp        RETURNINTERRUPTRESULT

; The function code passed to the memory manager is not defined.
RETURNINTERRUPTRESULT_84:
0x39ef:  B4 84                   mov        ah, 0x84
0x39f1:  E9 A2 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_85:
0x39f4:  B4 85                   mov        ah, 0x85
0x39f6:  E9 9D 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_86:
0x39f9:  B4 86                   mov        ah, 0x86
0x39fb:  E9 98 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_87:
0x39fe:  B4 87                   mov        ah, 0x87
0x3a00:  E9 93 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_88:
0x3a03:  B4 88                   mov        ah, 0x88
0x3a05:  E9 8E 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_89:
0x3a08:  B4 89                   mov        ah, 0x89
0x3a0a:  E9 89 00                jmp        RETURNINTERRUPTRESULT
RETURNINTERRUPTRESULT_8A:
0x3a0d:  B4 8A                   mov        ah, 0x8a
0x3a0f:  E9 84 00                jmp        RETURNINTERRUPTRESULT

RETURNINTERRUPTRESULT_8B:
0x3a12:  B4 8B                   mov        ah, 0x8b
0x3a14:  E9 7F 00                jmp        RETURNINTERRUPTRESULT

;unused
; There is no room in the save area to store the state of the page mapping registers.  The state of the map registers has not been saved.
RETURNINTERRUPTRESULT_8C:
0x3a17:  B4 8C                   mov        ah, 0x8c
0x3a19:  EB 7B                   jmp        RETURNINTERRUPTRESULT
0x3a1b:  90                      nop        

; The save area already contains the page mapping register state for the EMM handle your program specified.
RETURNINTERRUPTRESULT_8D:
0x3a1c:  B4 8D                   mov        ah, 0x8d
0x3a1e:  EB 76                   jmp        RETURNINTERRUPTRESULT
0x3a20:  90                      nop        

; There is no page mapping register state in the save area for the specified EMM handle.  Your program didn't save the contents of the page mapping hardware, so Restore Page Map can't restore it.
RETURNINTERRUPTRESULT_8E:
0x3a21:  B4 8E                   mov        ah, 0x8e
0x3a23:  EB 71                   jmp        RETURNINTERRUPTRESULT
0x3a25:  90                      nop        

;The subfunction parameter is invalid.
RETURN_BAD_SUBFUNCTION_PARAMETER:
0x3a26:  B4 8F                   mov        ah, 0x8f
0x3a28:  EB 6C                   jmp        RETURNINTERRUPTRESULT
0x3a2a:  90                      nop        

; The attribute type is undefined.
RETURNINTERRUPTRESULT_90:
0x3a2b:  B4 90                   mov        ah, 0x90
0x3a2d:  EB 67                   jmp        RETURNINTERRUPTRESULT
0x3a2f:  90                      nop        

; This feature is not supported.
RETURNINTERRUPTRESULT_91:
0x3a30:  B4 91                   mov        ah, 0x91
0x3a32:  EB 62                   jmp        RETURNINTERRUPTRESULT
0x3a34:  90                      nop        

; unused
; The source and destination expanded memory regions have the same handle and overlap.  This is valid for a move.  The move has been completed and the destination region has a
; full copy of the source region.  However, at least a portion of the source region has been overwritten by the move.  Note that the source and destination expanded memory
; regions with different handles will never physically overlap because the different handles specify totally different regions of expanded memory.
RETURNINTERRUPTRESULT_92:
0x3a35:  B4 92                   mov        ah, 0x92
0x3a37:  EB 5D                   jmp        RETURNINTERRUPTRESULT
0x3a39:  90                      nop        

; unused
; The length of the source or destination expanded memory region specified exceeds the length of the expanded memory region allocated either the source or destination handle.
; Insufficient pages are allocated to this handle to move a region of the size specified.  The program can recover from this condition by allocating additional pages to the
; destination or source handle and attempting to execute the function again.  However, if the application program allocated as much expanded memory as it thought it needed,
; this may be a program error and is not recoverable.
RETURNINTERRUPTRESULT_93:
0x3a3a:  B4 93                   mov        ah, 0x93
0x3a3c:  EB 58                   jmp        RETURNINTERRUPTRESULT
0x3a3e:  90                      nop        

; The conventional memory region and expanded memory region overlap.  This is invalid, the conventional memory region cannot overlap the expanded memory region.
RETURNINTERRUPTRESULT_94:
0x3a3f:  B4 94                   mov        ah, 0x94
0x3a41:  EB 53                   jmp        RETURNINTERRUPTRESULT
0x3a43:  90                      nop        

; The offset within the logical page exceeds the length of the logical page.  The initial source or destination offsets within an expanded memory region must be between 0000h and 3FFFh (16383 or (length of a logical page - 1)).
RETURNINTERRUPTRESULT_95:
0x3a44:  B4 95                   mov        ah, 0x95
0x3a46:  EB 4E                   jmp        RETURNINTERRUPTRESULT
0x3a48:  90                      nop        

; Region length exceeds 1M byte.
RETURNINTERRUPTRESULT_96:
0x3a49:  B4 96                   mov        ah, 0x96
0x3a4b:  EB 49                   jmp        RETURNINTERRUPTRESULT
0x3a4d:  90                      nop        

; The source and destination expanded memory regions have the same handle and overlap.  This is invalid, the source and destination expanded memory regions cannot have the same
; handle and overlap when they are being exchanged. Note that the source and destination expanded memory regions which have different handles will never physically overlap
; because the different handles specify totally different regions of expanded memory.
RETURNINTERRUPTRESULT_97:
0x3a4e:  B4 97                   mov        ah, 0x97
0x3a50:  EB 44                   jmp        RETURNINTERRUPTRESULT
0x3a52:  90                      nop        

; The memory source and destination types are undefined.
RETURNINTERRUPTRESULT_98:
0x3a53:  B4 98                   mov        ah, 0x98
0x3a55:  EB 3F                   jmp        RETURNINTERRUPTRESULT
0x3a57:  90                      nop        

; unused, nonexistant in spec
RETURNINTERRUPTRESULT_99:
0x3a58:  B4 99                   mov        ah, 0x99
0x3a5a:  EB 3A                   jmp        RETURNINTERRUPTRESULT
0x3a5c:  90                      nop        

; unused
; Alternate map register sets are supported, but the alternate map register set specified is not supported.
; Alternate DMA register sets are supported, but the alternate DMA register set specified is not supported.
RETURNINTERRUPTRESULT_9A:
0x3a5d:  B4 9A                   mov        ah, 0x9a
0x3a5f:  EB 35                   jmp        RETURNINTERRUPTRESULT
0x3a61:  90                      nop        

; unused
; Alternate map register sets are supported.  However, all alternate map register sets are currently allocated.
; Alternate DMA register sets are supported.  However, all alternate DMA register sets are currently allocated.
RETURNINTERRUPTRESULT_9B:
0x3a62:  B4 9B                   mov        ah, 0x9b
0x3a64:  EB 30                   jmp        RETURNINTERRUPTRESULT
0x3a66:  90                      nop        

; Alternate map register sets are not supported and the alternate map register set specified is not zero.
; Alternate DMA register sets are not supported and the alternate DMA register set specified is not zero.
RETURNINTERRUPTRESULT_9C:
0x3a67:  B4 9C                   mov        ah, 0x9c
0x3a69:  EB 2B                   jmp        RETURNINTERRUPTRESULT
0x3a6b:  90                      nop        

; unused
; Alternate map register sets are supported, but the alternate map register set specified is either not defined or not allocated.
; DMA register sets are supported, but the DMA register set specified is either not defined or not allocated.
RETURNINTERRUPTRESULT_9D:
0x3a6c:  B4 9D                   mov        ah, 0x9d
0x3a6e:  EB 26                   jmp        RETURNINTERRUPTRESULT
0x3a70:  90                      nop        

; unused
; Dedicated DMA channels are not supported.
RETURNINTERRUPTRESULT_9E:
0x3a71:  B4 9E                   mov        ah, 0x9e
0x3a73:  EB 21                   jmp        RETURNINTERRUPTRESULT
0x3a75:  90                      nop        

; unused
; Dedicated DMA channels are supported, but the DMA channel specified is not supported.
RETURNINTERRUPTRESULT_9f:
0x3a76:  B4 9F                   mov        ah, 0x9f
0x3a78:  EB 1C                   jmp        RETURNINTERRUPTRESULT
0x3a7a:  90                      nop        

; No corresponding handle could be found for the handle name specified.
RETURNINTERRUPTRESULT_A0:
0x3a7b:  B4 A0                   mov        ah, 0xa0
0x3a7d:  EB 17                   jmp        RETURNINTERRUPTRESULT
0x3a7f:  90                      nop        

; A handle found had no name (all ASCII nulls).
; A handle with this name already exists.  The specified handle was not assigned a name.
RETURNINTERRUPTRESULT_A1:
0x3a80:  B4 A1                   mov        ah, 0xa1
0x3a82:  EB 12                   jmp        RETURNINTERRUPTRESULT
0x3a84:  90                      nop        

; An attempt was made to wrap around the 1M-byte address space of conventional memory during the move.  The combination of source/destination 
; starting address and length of the region to be moved exceeds 1M byte.  No data was moved.
; An attempt was made to wrap around the 1M-byte address space of conventional memory during the exchange.  The source starting address together 
; with the length of the region to be exchanged exceeds 1M byte.  No data was exchanged.
RETURNINTERRUPTRESULT_A2:
0x3a85:  B4 A2                   mov        ah, 0xa2
0x3a87:  EB 0D                   jmp        RETURNINTERRUPTRESULT
0x3a89:  90                      nop        

; The contents of the source array have been corrupted, or the pointer passed to the subfunction is invalid.
RETURNINTERRUPTRESULT_A3:
0x3a8a:  B4 A3                   mov        ah, 0xa3
0x3a8c:  EB 08                   jmp        RETURNINTERRUPTRESULT
0x3a8e:  90                      nop        

; The operating system has denied access to this function. The function cannot be used at this time.
RETURNINTERRUPTRESULT_A4:
0x3a8f:  B4 A4                   mov        ah, 0xa4
0x3a91:  EB 03                   jmp        RETURNINTERRUPTRESULT
0x3a93:  90                      nop        

RETURNINTERRUPTRESULT0:
0x3a94:  B4 00                   mov        ah, 0
RETURNINTERRUPTRESULT:
0x3a96:  07                      pop        es
0x3a97:  1F                      pop        ds
0x3a98:  5D                      pop        bp
0x3a99:  5F                      pop        di
0x3a9a:  5E                      pop        si
0x3a9b:  59                      pop        cx
0x3a9c:  CF                      iret

; STRINGS
;0x3A9D
STRING db 'DATATECH EMM PROGRAM END'
; 0x3ab5: 3 byte structs, 0xE of them.
;010004 020006 030008 040008 050010 060018 070020 080020 09803F 0A0020 0B803F 0C000C 0D0014 0E0030
memory_configs db 01h, 00h, 04h
db 02h, 00h, 06h
db 03h, 00h, 08h
db 04h, 00h, 08h
db 05h, 00h, 10h
db 06h, 00h, 18h
db 07h, 00h, 20h
db 08h, 00h, 20h
db 09h, 80h, 3Fh
db 0Ah, 00h, 20h
db 0Bh, 00h, 3Fh
db 0Ch, 00h, 0Ch
db 0Dh, 00h, 14h
db 0Eh, 00h, 30h
; 0x3adf  seems to be a dupe of mappable_384K_conventional?
mappable_384K_conventional_dupe dw 0000h
; 0x3ae1  stored to seemingly never used again
mystery_value dw 0000h
; 0x3ae3  stores slot pointer * 4
slotpointer_byte_times_4_word dw 0000h
; 0x3ae5  stores cursor ending area from bios (0x0040:0060)
cursor_ending_area dw 0000h
; 0x3ae7  stores slot pointer byte
slotpointer_byte db 00h
; 0x3ae8  amount of mappable memory in 256k-640k region. seems to either store 0 or 384 decimal (0x180)
mappable_384K_conventional dw 0000h
; 0x3aea  
string_driver_exists STRING DB 0Dh, 0Ah, ' VL82C311 EMS has existed.',0Dh, 0Ah,0Dh, 0Ah '$'
; 0x3B0B  
string_main_header STRING DB 0Dh, 0Ah, '===================================================', 0Dh, 0Ah, 'DTK VL82C311 Expanded Memory Manager  Ver 1.03 1992', 0Dh, 0Ah, '(C) Copyright Datatech Enterprise Co.,Ltd', 0Dh, 0Ah, 'All Rights Reserved', 0Dh, 0Ah, '#10062992', 0Dh, 0Ah, '===================================================', 0Dh, 0Ah,'$'
; 0x3BF8
string_ems_not_enabled STRING DB 0Dh, 0Ah, '     EMS Disable ! $',0Dh, 0Ah,0Dh, 0Ah '$'
; 0x3C0E
string_config_sys_page_frame_error STRING DB 0Dh, 0Ah, '     CONFIG.SYS parameter PAGE FRAME error.$'
; 0x3C3C
string_config_sys_page_port_error STRING DB 0Dh, 0Ah, '     CONFIG.SYS parameter PAGE PORT error.$'
; 0x3C69
string_config_sys_ems_memory_error STRING DB 0Dh, 0Ah, '     CONFIG.SYS parameter EMS MEMORY error.$'
; 0x3C97
string_ems_page_frame_prefix STRING DB 0Dh, 0Ah, '     User specified PAGE FRAME = $'

; 0x3CBB
string_user_specified_ems_memory STRING DB 0Dh, 0Ah, '     User specified EMS MEMORY $'
; 0x3CDD
string_user_specified_ems_backfill STRING DB 0Dh, 0Ah, '     User specified EMS backfill area = $'
; 0x3D07
string_program_set_page_frame STRING DB 0Dh, 0Ah, '     Program set PAGE FRAME   = $'
; 0x3D2B
string_ems_page_frame_string STRING DB 0Dh, 0Ah, '1234H$'
; 0x3D31
string_system_ram_specified_error STRING DB 0Dh, 0Ah, '     SYSTEM RAM specified error.$'
; 0x3D54
string_memory_relocate_error STRING DB 0Dh, 0Ah, '     MEMORY RELOCATE specified error.$'
; 0x3D7C
string_ems_memory_specified_error STRING DB 0Dh, 0Ah, '     EMS MEMORY specified error.$'
; 0x3D9F
string_page_frame_specified_error STRING DB 0Dh, 0Ah, '     PAGE FRAME specified error.$'
; 0x3DC2
string_shadow_ram_in_page_frame STRING DB 0Dh, 0Ah, '     There are SHADOW RAM in PAGE FRAME.$'

; 0x3DED
string_rom_in_page_frame STRING DB 0Dh, 0Ah, '     There are ROM ENABLE in PAGE FRAME.$'
; 0x3E18
string_error_in_page STRING DB 0Dh, 0Ah, '     ERROR PAGE $'
; 0x3E2B
string_driver_successfully_installed STRING DB 0Dh, 0Ah, '     VL82C311 EMS has been installed.', 0Ah, 0Ah, 0Ah, 0Ah, 0Dh, '$'
; 0x3E58
string_driver_failed_installing STRING DB 0Dh, 0Ah, '     VL82C311 EMS is not installed.', 0Ah, 0Ah, 0Ah, 0Ah, 0Dh, '$'
; 0x3E83
string_testing_page STRING  '     Test Expanded Memory Page '
; note this carries over
; 0x3EA3
string_page_number STRING DB 0000$', ODh
; 0x3EA8
string_press_esc_to_bypass_testing STRING '  .... Press [Esc] to bypass testing$'
; 0x3ECD
string_testing_bypassed STRING DB '  .... Testing bypassed.            $'
; 0x3EF2
string_there_are STRING DB 0Ah, '     There are$', ODh

; 0x3F03
string_pages_for_ems STRING DB ' PAGEs for EMS.$'
; 0x3F13
string_newline STRING DB 0Ah, '$'
; 0x3F15
string_newline2 STRING DB 0Dh, 0Ah, '$'
; 0x3F18
string_page_frames STRING DB 'C000H$C400H$C800H$CC00H$D000H$D400H$D800H$DC00H$E000H$'
; 0x3f4e
page_frame_index_byte db 04h
; 0x3F4F
string_off_on STRING DB 'OFF$ON$'
; 0x3f56
skip_testing_memory db 00h


DRIVER_INIT:
0x3f57:  8C C8                   mov        ax, cs
0x3f59:  8E D8                   mov        ds, ax
0x3f5b:  C7 06 48 00 A5 00       mov        word ptr [pointer_to_ems_init], 0xa5     ; overwrite pointer to this init function with pointer to "failed to install" (0x3fa5)
0x3f61:  8D 16 0B 3B             lea        dx, [string_main_header]
0x3f65:  E8 67 05                call       PRINT_STRING
; get interrupt vector. check it's header/string
0x3f68:  B8 67 35                mov        ax, 0x3567
0x3f6b:  CD 21                   int        0x21
0x3f6d:  BF 0A 00                mov        di, 0xa
0x3f70:  8B F7                   mov        si, di
0x3f72:  B9 08 00                mov        cx, 8
0x3f75:  F3 A6                   repe cmpsb byte ptr [si], byte ptr es:[di]
 
0x3f77:  75 07                   jne        EMS_INTERRUPT_FREE
; an ems driver is already installed
0x3f79:  8D 16 EA 3A             lea        dx, [string_driver_exists]
0x3f7d:  E9 37 05                jmp        DRIVER_NOT_INSTALLED_2

EMS_INTERRUPT_FREE:
0x3f80:  B0 03                   mov        al, 3           ; register 03h  DRAM Map Register 
0x3f82:  E8 E2 E9                call       READCHIPSETREG
0x3f85:  8A E0                   mov        ah, al
0x3f87:  24 0F                   and        al, 0xf
0x3f89:  3C 00                   cmp        al, 0
0x3f8b:  72 14                   jb         INIT_ERROR_RAM
0x3f8d:  3C 0F                   cmp        al, 0xf
0x3f8f:  7D 10                   jge        INIT_ERROR_RAM  ; 0x0f (1111) is an invalid value for MEMAP0-3

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

0x3f91:  B9 0E 00                mov        cx, 0xe
0x3f94:  8D 36 B5 3A             lea        si, OFFSET memory_configs
CHECK_NEXT_STRUCT:
0x3f98:  38 04                   cmp        byte ptr [si], al
0x3f9a:  74 0C                   je         FOUND_RAM_CONFIG:
0x3f9c:  83 C6 03                add        si, 3
0x3f9f:  E2 F7                   loop       CHECK_NEXT_STRUCT

"System ram specified error"
INIT_ERROR_RAM:
0x3fa1:  8D 16 31 3D             lea        dx, [string_system_ram_specified_error]
0x3fa5:  E9 08 05                jmp        DRIVER_NOT_INSTALLED


FOUND_RAM_CONFIG:
; ah = RAMMAP register
0x3fa8:  F6 C4 10                test       ah, 0x10
0x3fab:  74 17                   je         FOUND_REMAP_384K
0x3fad:  81 7C 01 00 08          cmp        word ptr [si + 1], 0x800
0x3fb2:  74 19                   je         FOUND_COMPATIBLEMEMMAP
0x3fb4:  81 7C 01 00 0C          cmp        word ptr [si + 1], 0xc00
0x3fb9:  74 12                   je         FOUND_COMPATIBLEMEMMAP
0x3fbb:  81 7C 01 00 10          cmp        word ptr [si + 1], 0x1000
0x3fc0:  74 0B                   je         FOUND_COMPATIBLEMEMMAP
0x3fc2:  EB DD                   jmp        INIT_ERROR_RAM

; REMP384 is set. 384k is remapped. This might be incompatible with many ems features?
FOUND_REMAP_384K:
0x3fc4:  C7 06 E8 3A 00 00       mov        word ptr [mappable_384K_conventional], 0
0x3fca:  EB 07                   jmp        NO_384k
0x3fcc:  90                      nop        

;
FOUND_COMPATIBLEMEMMAP:
0x3fcd:  C7 06 E8 3A 80 01       mov        word ptr [mappable_384K_conventional], 0x180  ; equal to 384 decimal
NO_384k:

0x3fd3:  8B 44 01                mov        ax, word ptr [si + 1]
0x3fd6:  03 06 E8 3A             add        ax, word ptr [mappable_384K_conventional]
0x3fda:  A3 DF 3A                mov        word ptr [mappable_384K_conventional_dupe], ax

0x3fdd:  B0 02                   mov        al, 2     ; register 02h  SLTPTR 
0x3fdf:  E8 85 E9                call       READCHIPSETREG
0x3fe2:  3C 10                   cmp        al, 0x10            ; 0x10 slotpointer means at least 1M
0x3fe4:  73 02                   jae        AT_LEAST_1_MEG_SLOT_POINTER
0x3fe6:  B0 10                   mov        al, 0x10            ; adjust slot pointer downward. not sure if this actually works....

AT_LEAST_1_MEG_SLOT_POINTER:
0x3fe8:  A2 E7 3A                mov        byte ptr [slotpointer_byte], al
0x3feb:  32 E4                   xor        ah, ah
0x3fed:  C1 E0 02                shl        ax, 2
0x3ff0:  A3 E3 3A                mov        word ptr [slotpointer_byte_times_4_word], ax
0x3ff3:  C1 E0 04                shl        ax, 4
0x3ff6:  3B 06 DF 3A             cmp        ax, word ptr [mappable_384K_conventional_dupe]

0x3ffa:  72 0C                   jb         EMS_CONFIGURED_PROPERLY
0x3ffc:  74 03                   je         EMS_NOT_ENABLED
0x3ffe:  E9 DE 00                jmp        EMS_SPECIFIED_ERROR

EMS_NOT_ENABLED:
0x4001:  8D 16 F8 3B             lea        dx, [string_ems_not_enabled]
0x4005:  E9 A8 04                jmp        DRIVER_NOT_INSTALLED

EMS_CONFIGURED_PROPERLY:
0x4008:  93                      xchg       ax, bx
0x4009:  A1 DF 3A                mov        ax, word ptr [mappable_384K_conventional_dupe]
0x400c:  2B C3                   sub        ax, bx
0x400e:  A3 E1 3A                mov        word ptr [mystery_value], ax ; never accessed again?
0x4011:  B1 04                   mov        cl, 4
0x4013:  D3 E8                   shr        ax, cl
0x4015:  A3 95 28                mov        word ptr [unallocated_page_count], ax    ; store unallocated page count
0x4018:  B0 0B                   mov        al, 0xb     ; register 0Bh EMS Configuration Register 1
0x401a:  E8 4A E9                call       READCHIPSETREG
0x401d:  0C 80                   or         al, 0x80
0x401f:  8A E0                   mov        ah, al      ; store copy with high bit on
0x4021:  B0 0B                   mov        al, 0xb     ; just write the same value back to 0xb register. mot sure why...
0x4023:  E8 4A E9                call       WRITECHIPSETREG
0x4026:  C4 36 71 28             les        si, ptr [driver_arguments]            ; load pointer to driver arguments
0x402a:  26 C4 74 12             les        si, ptr es:[si + 0x12]
0x402e:  EB 02                   jmp        FIND_PAGE_FRAME_PARAM
0x4030:  90                      nop        

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
0x4031:  46                      inc        si

FIND_PAGE_FRAME_PARAM:
0x4032:  26 80 3C 20             cmp        byte ptr es:[si], 0x20
0x4036:  74 F9                   je         GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR


; Check for end of parameter list...
0x4038:  26 80 3C 0D             cmp        byte ptr es:[si], 0xd
0x403c:  75 03                   jne        NOT_0xD
0x403e:  EB 59                   jmp        FINISHED_PARSING_DRIVER_PARAMS
0x4040:  90                      nop        
NOT_0xD:
0x4041:  26 80 3C 0A             cmp        byte ptr es:[si], 0xa
0x4045:  75 03                   jne        NOT_0xA
0x4047:  EB 50                   jmp        FINISHED_PARSING_DRIVER_PARAMS
0x4049:  90                      nop        
NOT_0xA:
0x404a:  26 80 3C 1A             cmp        byte ptr es:[si], 0x1a
0x404e:  75 03                   jne        NOT_0x1A
0x4050:  EB 47                   jmp        FINISHED_PARSING_DRIVER_PARAMS
0x4052:  90                      nop        
NOT_0x1A:

; look for es:si to contain string 'F:0' to 'F:8'.
FIND_F0_F8:
0x4053:  26 80 24 DF             and        byte ptr es:[si], 0xdf      ; 0xDF = 1101 1111
0x4057:  26 80 3C 46             cmp        byte ptr es:[si], 0x46      ; 0x46 = 'F'
0x405b:  74 02                   je         FOUND_ASCII_F
0x405d:  EB D2                   jmp        GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR
FOUND_ASCII_F:
0x405f:  26 80 7C 01 3A          cmp        byte ptr es:[si + 1], 0x3a
0x4064:  75 CB                   jne        GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR
0x4066:  26 80 7C 02 30          cmp        byte ptr es:[si + 2], 0x30
0x406b:  72 C4                   jb         GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR
0x406d:  26 80 7C 02 38          cmp        byte ptr es:[si + 2], 0x38
0x4072:  77 BD                   ja         GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR
; ES:SI points to 'F:0' to 'F:8'
0x4074:  26 8A 44 02             mov        al, byte ptr es:[si + 2]
0x4078:  2C 30                   sub        al, 0x30                    ; ascii to hex
0x407a:  8A F8                   mov        bh, al
0x407c:  A2 4E 3F                mov        byte ptr [page_frame_index_byte], al       ; store the 0-8 as page frame string offset
0x407f:  83 C6 03                add        si, 3
0x4082:  EB AE                   jmp        FIND_PAGE_FRAME_PARAM

; UNUSED ERROR CODES
0x4084:  8D 16 0E 3C             lea        dx, [string_config_sys_page_frame_error]
0x4088:  E9 25 04                jmp        DRIVER_NOT_INSTALLED
0x408b:  8D 16 3C 3C             lea        dx, [string_config_sys_page_port_error]
0x408f:  E9 1E 04                jmp        DRIVER_NOT_INSTALLED
0x4092:  8D 16 69 3C             lea        dx, [string_config_sys_ems_memory_error]
0x4096:  E9 17 04                jmp        DRIVER_NOT_INSTALLED

FINISHED_PARSING_DRIVER_PARAMS:
0x4099:  8D 16 97 3C             lea        dx, [string_ems_page_frame_prefix]
0x409d:  E8 2F 04                call       PRINT_STRING
0x40a0:  A0 4E 3F                mov        al, byte ptr [page_frame_index_byte]   ; store page frame string offset
0x40a3:  B3 06                   mov        bl, 6                   ; 6 bytes per string... used to get string offset.
0x40a5:  F6 E3                   mul        bl
0x40a7:  8D 16 18 3F             lea        dx, [string_page_frames]            ; get EMS page frame string
0x40ab:  03 D0                   add        dx, ax                  ; add offset to get the exact page frame string
0x40ad:  E8 1F 04                call       PRINT_STRING
0x40b0:  32 E4                   xor        ah, ah
0x40b2:  8A C7                   mov        al, bh
0x40b4:  E8 E3 04                call       FIND_BIOSES
0x40b7:  32 E4                   xor        ah, ah
0x40b9:  A0 4E 3F                mov        al, byte ptr [page_frame_index_byte]
0x40bc:  E8 85 04                call       CHECK_IF_VALID_PAGE_FRAME
0x40bf:  A3 81 28                mov        word ptr [page_frame_segment], ax                 ; store used page frame
0x40c2:  8D 16 08 3D             lea        dx, [string_program_set_page_frame]   ;  Program set PAGE FRAME   = $1234H$
0x40c6:  E8 06 04                call       PRINT_STRING

0x40c9:  06                      push       es
0x40ca:  57                      push       di
0x40cb:  0E                      push       cs
0x40cc:  07                      pop        es
0x40cd:  BF 2B 3D                mov        di, offset string_ems_page_frame_string        ; 
0x40d0:  E8 39 04                call       HEX_WORD_TO_ASCII
0x40d3:  8D 16 2B 3D             lea        dx, [string_ems_page_frame_string]
0x40d7:  E8 F5 03                call       PRINT_STRING
0x40da:  5F                      pop        di
0x40db:  07                      pop        es
0x40dc:  EB 35                   jmp        DONE_PRINTING_PAGE_FRAME
0x40de:  90                      nop        

; EMS SPECIFIED ERROR
EMS_SPECIFIED_ERROR:
0x40df:  8D 16 7C 3D             lea        dx, [string_ems_memory_specified_error]
0x40e3:  E9 CA 03                jmp        DRIVER_NOT_INSTALLED


;UNUSED CHECK FOR BACKFILL PARAMETER!!!
; look for es:si to contain string 'B:0' or 'B:1'. store 0 or 1 into 0x28ed. then increment si by 3
FIND_B0_B1:
0x40e6:  E9 48 FF                jmp        GET_NEXT_NONSPACE_DRIVER_ARGUMENT_CHAR
0x40e9:  26 80 3C 42             cmp        byte ptr es:[si], 0x42
0x40ed:  75 F7                   jne        FIND_B0_B1
0x40ef:  26 80 7C 01 3A          cmp        byte ptr es:[si + 1], 0x3a
0x40f4:  75 F0                   jne        FIND_B0_B1
0x40f6:  26 80 7C 02 30          cmp        byte ptr es:[si + 2], 0x30
0x40fb:  72 E9                   jb         FIND_B0_B1
0x40fd:  26 80 7C 02 31          cmp        byte ptr es:[si + 2], 0x31
0x4102:  77 E2                   ja         FIND_B0_B1
0x4104:  26 8A 44 02             mov        al, byte ptr es:[si + 2]
0x4108:  2C 30                   sub        al, 0x30
0x410a:  A2 ED 28                mov        byte ptr [backfill_enabled], al
0x410d:  83 C6 03                add        si, 3
0x4110:  E9 1F FF                jmp        FIND_PAGE_FRAME_PARAM

DONE_PRINTING_PAGE_FRAME:
0x4113:  80 3E ED 28 00          cmp        byte ptr [backfill_enabled], 0
0x4118:  74 09                   je         BACKFILL_NOT_ENABLED
0x411a:  C7 06 A1 28 24 00       mov        word ptr [number_ems_pages], 0x24  ; has backfill, 36 pages
0x4120:  EB 07                   jmp        BACKFILL_ENABLED
0x4122:  90                      nop        

BACKFILL_NOT_ENABLED:
0x4123:  C7 06 A1 28 0C 00       mov        word ptr [number_ems_pages], 0xc  ; no backfill, only 12 pages
BACKFILL_ENABLED:

0x4129:  C7 06 A6 17 00 00       mov        word ptr [upper_C000toEC00_non_rom_pages], 0
0x412f:  BB B5 17                mov        bx, bios_in_upper_pages
0x4132:  B9 0C 00                mov        cx, 0xc
; loop 0xc times, check bytes for bios presence
CHECK_NEXT_PAGE_SETTING:
0x4135:  2E 80 3F FF             cmp        byte ptr cs:[bx], 0xff
0x4139:  75 08                   jne        MARK_NON_BIOS_PAGE
0x413b:  83 2E A1 28 01          sub        word ptr [number_ems_pages], 1      ; bios page so subtract 1 from total pages
0x4140:  EB 07                   jmp        CONTINUE_LOOP_A
0x4142:  90                      nop        

MARK_NON_BIOS_PAGE:
; add one free page found
0x4143:  2E 83 06 A6 17 01       add        word ptr cs:[upper_C000toEC00_non_rom_pages], 1
CONTINUE_LOOP_A:
0x4149:  43                      inc        bx
0x414a:  E2 E9                   loop       CHECK_NEXT_PAGE_SETTING


; The following segment of code fills up the 0x2749 structure with the ems register to page frame segment map.
; first four will be the page frame. then the next entries will be the other mappable upper memory pages.
; first the pages before the page frame (unless its c000) will be added, then the ones after

0x414c:  A1 81 28                mov        ax, word ptr [page_frame_segment]
0x414f:  BE 49 27                mov        si, OFFSET page_register_data
0x4152:  B9 04 00                mov        cx, 4
CONTINUE_WRITING_PAGE_FRAME_INFO:
0x4155:  8B D8                   mov        bx, ax
0x4157:  81 EB 00 C0             sub        bx, 0xc000
0x415b:  C1 EB 0A                shr        bx, 0xa             ; bx has the page frame index (i.e. 0 is c000, 4 is d000)
0x415e:  89 04                   mov        word ptr [si], ax
0x4160:  88 5C 02                mov        byte ptr [si + 2], bl
0x4163:  83 C6 03                add        si, 3
0x4166:  05 00 04                add        ax, 0x400
0x4169:  E2 EA                   loop       CONTINUE_WRITING_PAGE_FRAME_INFO

0x416b:  8B D0                   mov        dx, ax
0x416d:  81 3E 81 28 00 C0       cmp        word ptr [page_frame_segment], 0xc000
0x4173:  74 2C                   je         CONTINUE_FINDING_ROM_SEGMENTS_AFTER_PAGE_FRAME

; initial condition
0x4175:  B8 00 C0                mov        ax, 0xc000
CONTINUE_FINDING_ROM_SEGMENTS_BEFORE_PAGE_FRAME:
0x4178:  8B D8                   mov        bx, ax
0x417a:  81 EB 00 C0             sub        bx, 0xc000
0x417e:  C1 EB 0A                shr        bx, 0xa

0x4181:  2E 80 BF B5 17 FF       cmp        byte ptr cs:[bx + bios_in_upper_pages], 0xff
0x4187:  74 08                je         PAGE_IS_ROM:

0x4189:  89 04                mov        word ptr [si], ax
0x418b:  88 5C 02             mov        byte ptr [si + 2], bl
0x418e:  83 C6 03             add        si, 3

PAGE_IS_ROM:
0x4191:  05 00 04             add        ax, 0x400
0x4194:  3B 06 81 28          cmp        ax, word ptr [page_frame_segment]
0x4198:  75 DE                jne        CONTINUE_FINDING_ROM_SEGMENTS_BEFORE_PAGE_FRAME
0x419a:  8B C2                mov        ax, dx
0x419c:  3D 00 F0             cmp        ax, 0xf000
0x419f:  74 21                je         FINISHED_SEARCHING_PRE_PAGE_FRAME_ROM_SEGMENTS

CONTINUE_FINDING_ROM_SEGMENTS_AFTER_PAGE_FRAME:
0x41a1:  8B D8                mov        bx, ax
0x41a3:  81 EB 00 C0          sub        bx, 0xc000
0x41a7:  C1 EB 0A             shr        bx, 0xa
0x41aa:  2E 80 BF B5 17 FF    cmp        byte ptr cs:[bx + bios_in_upper_pages], 0xff
0x41b0:  74 08                je         FOUND_LAST_ENTRY
0x41b2:  89 04                mov        word ptr [si], ax
0x41b4:  88 5C 02             mov        byte ptr [si + 2], bl
0x41b7:  83 C6 03             add        si, 3
FOUND_LAST_ENTRY:
0x41ba:  05 00 04             add        ax, 0x400
0x41bd:  3D 00 F0             cmp        ax, 0xf000
0x41c0:  75 DF                jne        CONTINUE_FINDING_ROM_SEGMENTS_AFTER_PAGE_FRAME

FINISHED_SEARCHING_PRE_PAGE_FRAME_ROM_SEGMENTS:
0x41c2:  80 3E ED 28 00       cmp        byte ptr [backfill_enabled], 0
0x41c7:  74 17                je         SKIP_BACKFILL_REGISTERS

0x41c9:  B3 0C                mov        bl, 0xc
0x41cb:  B8 00 40             mov        ax, 0x4000
0x41ce:  B9 18 00             mov        cx, 0x18
CONTINUE_WRITING_BACKFILL_REGISTERS:
0x41d1:  88 5C 02             mov        byte ptr [si + 2], bl
0x41d4:  89 04                mov        word ptr [si], ax
0x41d6:  FE C3                inc        bl
0x41d8:  83 C6 03             add        si, 3
0x41db:  05 00 04             add        ax, 0x400
0x41de:  E2 F1                loop       CONTINUE_WRITING_BACKFILL_REGISTERS

SKIP_BACKFILL_REGISTERS:
0x41e0:  A1 81 28             mov        ax, word ptr [page_frame_segment]
0x41e3:  8E C0                mov        es, ax
0x41e5:  B0 80                mov        al, 0x80
0x41e7:  E6 61                out        0x61, al           ; clear keyboard port (?)
0x41e9:  1E                   push       ds
0x41ea:  6A 40                push       0x40
0x41ec:  1F                   pop        ds
; 0x400 is BDA (BIOS data area)
;0x41ed:  A1 60 00             mov        ax, word ptr [0x60]   ; 	bios data segment "Cursor ending (bottom) scan line"
db 0b8h, 060h, 000h 
0x41f0:  1F                   pop        ds
0x41f1:  A3 E5 3A             mov        word ptr [cursor_ending_area], ax
0x41f4:  B9 00 0F             mov        cx, 0xf00
0x41f7:  B4 01                mov        ah, 1
0x41f9:  CD 10                int        0x10               ; Set Cursor Type 0x0f00
0x41fb:  8B 0E 95 28          mov        cx, word ptr [unallocated_page_count]
0x41ff:  8B 1E E3 3A          mov        bx, word ptr [slotpointer_byte_times_4_word]

; going to mark all pageable memory FFEE all over

MARK_NEXT_PAGE_FFFE:
0x4203:  32 C0                xor        al, al
0x4205:  E8 8B E7             call       TURN_ON_EMS_PAGE  ; turn on ems page 0...
0x4208:  51                   push       cx
0x4209:  B9 00 20             mov        cx, 0x2000   ; do this for 8192 words or 16384 bytes
0x420c:  B8 FE FF             mov        ax, 0xfffe
0x420f:  33 FF                xor        di, di
0x4211:  F3 AB                rep stosw  word ptr es:[di], ax ; es points to page frame segment. BUG: Never gets updated for backfill segment?
0x4213:  59                   pop        cx
0x4214:  43                   inc        bx
0x4215:  E2 EC                loop       MARK_NEXT_PAGE_FFFE

0x4217:  8B 2E 95 28          mov        bp, word ptr [unallocated_page_count]
0x421b:  33 C0                xor        ax, ax
0x421d:  A3 95 28             mov        word ptr [unallocated_page_count], ax
0x4220:  8D 36 CD 17          lea        si, OFFSET backfill_page_map                     ; we arent using this pointer for anything right now...
0x4224:  80 3E ED 28 00       cmp        byte ptr [backfill_enabled], 0
0x4229:  74 03                je         NO_BACKFILL_ENABLED
0x422b:  83 C6 60             add        si, 0x60
NO_BACKFILL_ENABLED:
; bunch of stuff to print page frame...
0x422e:  B8 00 00             mov        ax, 0
0x4231:  B1 04                mov        cl, 4
0x4233:  F6 E1                mul        cl
0x4235:  03 F0                add        si, ax
0x4237:  8B 1E E3 3A          mov        bx, word ptr [slotpointer_byte_times_4_word]
0x423b:  8D 16 13 3F          lea        dx, [string_newline]
0x423f:  E8 8D 02             call       PRINT_STRING
0x4242:  A1 95 28             mov        ax, word ptr [unallocated_page_count]
0x4245:  8D 16 83 3E          lea        dx, [string_testing_page]
0x4249:  E8 83 02             call       PRINT_STRING
0x424c:  8D 16 A8 3E          lea        dx, [string_press_esc_to_bypass_testing]
0x4250:  E8 7C 02             call       PRINT_STRING
NEXT_PAGE_MEMORY_TEST_ITER:
0x4253:  40                   inc        ax
0x4254:  50                   push       ax
0x4255:  E8 82 02             call       SET_UP_STRING_DIGITS
0x4258:  8D 16 83 3E          lea        dx, [string_testing_page]
0x425c:  E8 70 02             call       PRINT_STRING
0x425f:  80 3E 56 3F 01       cmp        byte ptr [skip_testing_memory], 1
0x4264:  75 03                jne        NOT_SKIPPING_MEMORY_TEST
0x4266:  E9 B5 00             jmp        CURRENT_PAGE_FINISHED_TESTING

NOT_SKIPPING_MEMORY_TEST:
0x4269:  B4 01                mov        ah, 1
0x426b:  CD 16                int        0x16
0x426d:  74 1B                je         BREAK_KEY_NOT_PRESSED
0x426f:  B4 00                mov        ah, 0
0x4271:  CD 16                int        0x16       ; int 16,1 get keyboard status
0x4273:  3C 1B                cmp        al, 0x1b   ; check for break key
0x4275:  75 13                jne        BREAK_KEY_NOT_PRESSED
0x4277:  C6 06 56 3F 01       mov        byte ptr [skip_testing_memory], 1 ; skip testing
0x427c:  8D 16 83 3E          lea        dx, [string_testing_page]
0x4280:  E8 4C 02             call       PRINT_STRING
0x4283:  8D 16 CD 3E          lea        dx, [string_testing_bypassed]
0x4287:  E8 45 02             call       PRINT_STRING

BREAK_KEY_NOT_PRESSED:
0x428a:  B9 04 00             mov        cx, 4
0x428d:  32 C0                xor        al, al
TURN_ON_NEXT_PAGE:
0x428f:  E8 01 E7             call       TURN_ON_EMS_PAGE
0x4292:  FE C0                inc        al
0x4294:  E2 F9                loop       TURN_ON_NEXT_PAGE
; scan for word 0x1234 in page. this wont be there. i assume this is to check that the memory is mapped and readable.
; some interrupt would fire on a bad read?
0x4296:  B8 34 12             mov        ax, 0x1234
0x4299:  B9 00 20             mov        cx, 0x2000
0x429c:  33 FF                xor        di, di
0x429e:  F3 AF                repe scasw ax, word ptr es:[di]

; lets do it again for some reason. 
0x42a0:  B8 34 12             mov        ax, 0x1234
0x42a3:  B9 00 20             mov        cx, 0x2000
0x42a6:  33 FF                xor        di, di
0x42a8:  F3 AF                repe scasw ax, word ptr es:[di]

0x42aa:  E4 61                in         al, 0x61
0x42ac:  8A E0                mov        ah, al
0x42ae:  80 CC 0C             or         ah, 0xc    ; ; turn on the keypress bits from 61h
0x42b1:  24 F3                and        al, 0xf3   
0x42b3:  B9 02 00             mov        cx, 2
;check for keypress twice or something? not sure? not important?
OUT_LOOP:
0x42b6:  86 C4                xchg       ah, al
0x42b8:  E6 61                out        0x61, al     ; 
0x42ba:  EB 00                jmp        NOP_1     ; nop
NOP_1:
0x42bc:  EB 00                jmp        NOP_2     ; nop
NOP_2:
0x42be:  E2 F6                loop       OUT_LOOP 

0x42c0:  B8 FE FF             mov        ax, 0xfffe
0x42c3:  33 FF                xor        di, di


; Up ahead we are basically going to check the page to make sure its all 0xFFFE. this was written above.
; then we will write all 0xAA55 and check for that. then we will write all 0x55AA and check for that. Then 0x0101.
; then finally we zero out memory in the page.

CHECK_PAGE_FOR_PATTERN:
0x42c5:  B9 00 20             mov        cx, 0x2000
; check that the last write made it thru

LOOP_CHECK_PAGE_FOR_PATTERN:
0x42c8:  26 39 05             cmp        word ptr es:[di], ax
0x42cb:  75 13                jne        READ_MISMATCH
READ_OK:
0x42cd:  83 C7 02             add        di, 2
0x42d0:  E2 F6                loop       LOOP_CHECK_PAGE_FOR_PATTERN

0x42d2:  EB 15                jmp        DETERMINE_NEXT_PATTERN
0x42d4:  90                   nop        
0x42d5:  50                   push       ax
0x42d6:  E4 61                in         al, 0x61
0x42d8:  A8 C0                test       al, 0xc0
0x42da:  58                   pop        ax
0x42db:  74 0C                je         DETERMINE_NEXT_PATTERN
0x42dd:  EB 50                jmp        PRINT_MEMORY_ERROR_FOUND
0x42df:  90                   nop        


; earlier write of 0xfffe was not found. but we are checkign a second time for some reason.
READ_MISMATCH:
0x42e0:  26 39 05             cmp        word ptr es:[di], ax
0x42e3:  EB 00                jmp        NOP_3
NOP_3:
0x42e5:  75 48                jne        PRINT_MEMORY_ERROR_FOUND
0x42e7:  EB E4                jmp        READ_OK
DETERMINE_NEXT_PATTERN:
0x42e9:  3D FE FF             cmp        ax, 0xfffe
0x42ec:  74 0D                je         AX_WAS_FFFE
0x42ee:  3D 55 AA             cmp        ax, 0xaa55
0x42f1:  74 0E                je         AX_WAS_AA55
0x42f3:  3D AA 55             cmp        ax, 0x55aa
0x42f6:  74 0F                je         AX_WAS_55AA
0x42f8:  EB 1B                jmp        AX_WAS_SOMETHING_ELSE
0x42fa:  90                   nop        

AX_WAS_FFFE:
; next we do 0xAA55
0x42fb:  B8 55 AA             mov        ax, 0xaa55
0x42fe:  EB 0A                jmp        WRITE_AX_TO_PAGE
0x4300:  90                   nop        
AX_WAS_AA55:
; next we do 0x55AA
0x4301:  B8 AA 55             mov        ax, 0x55aa
0x4304:  EB 04                jmp        WRITE_AX_TO_PAGE
0x4306:  90                   nop        
AX_WAS_55AA:
; next we do 0x0101
0x4307:  B8 01 01             mov        ax, 0x101

WRITE_AX_TO_PAGE:
0x430a:  81 EF 00 40          sub        di, 0x4000
0x430e:  B9 00 20             mov        cx, 0x2000
0x4311:  F3 AB                rep stosw  word ptr es:[di], ax
0x4313:  EB B0                jmp        CHECK_PAGE_FOR_PATTERN
AX_WAS_SOMETHING_ELSE:
; now lets finally zero out memory
0x4315:  33 FF                xor        di, di
0x4317:  33 C0                xor        ax, ax
0x4319:  B9 00 20             mov        cx, 0x2000
0x431c:  F3 AB                rep stosw  word ptr es:[di], ax

CURRENT_PAGE_FINISHED_TESTING:
; this page is done.
0x431e:  89 1C                mov        word ptr [si], bx
0x4320:  83 C6 04             add        si, 4
0x4323:  FF 06 95 28          inc        word ptr [unallocated_page_count]

DO_NEXT_PAGE_MEMORY_TEST_ITER:
0x4327:  58                   pop        ax
0x4328:  4D                   dec        bp
0x4329:  74 14                je         MEMORY_TEST_DONE
0x432b:  43                   inc        bx
0x432c:  E9 24 FF             jmp        NEXT_PAGE_MEMORY_TEST_ITER

; print memory error found but continue the loop
PRINT_MEMORY_ERROR_FOUND:
0x432f:  8D 16 18 3E          lea        dx, [string_error_in_page]
0x4333:  E8 99 01             call       PRINT_STRING
0x4336:  8D 16 A3 3E          lea        dx, [string_page_number]
0x433a:  E8 92 01             call       PRINT_STRING
0x433d:  EB E8                jmp        DO_NEXT_PAGE_MEMORY_TEST_ITER

MEMORY_TEST_DONE:
; print how many pages there are
0x433f:  8D 16 F2 3E          lea        dx, [string_there_are]
0x4343:  E8 89 01             call       PRINT_STRING
0x4346:  A1 95 28             mov        ax, word ptr [unallocated_page_count]
0x4349:  A3 89 28             mov        word ptr [total_page_count], ax
0x434c:  E8 8B 01             call       SET_UP_STRING_DIGITS
0x434f:  8D 16 A3 3E          lea        dx, [string_page_number]
0x4353:  E8 79 01             call       PRINT_STRING
0x4356:  8D 16 03 3F          lea        dx, [string_pages_for_ems]
0x435a:  E8 72 01             call       PRINT_STRING
0x435d:  E4 61                in         al, 0x61
0x435f:  EB 01                jmp        NOP_4
0x4361:  90                   nop        
NOP_4:
0x4362:  0C 0C                or         al, 0xc
0x4364:  E6 61                out        0x61, al
0x4366:  EB 01                jmp        NOP_5
0x4368:  90                   nop        
NOP_5:
0x4369:  24 F3                and        al, 0xf3
0x436b:  E6 61                out        0x61, al
0x436d:  90                   nop        
0x436e:  90                   nop        
; undo cursor stuff
0x436f:  B0 0F                mov        al, 0xf
0x4371:  E6 70                out        0x70, al
0x4373:  8B 0E E5 3A          mov        cx, word ptr [cursor_ending_area]
0x4377:  B4 01                mov        ah, 1
0x4379:  CD 10                int        0x10
0x437b:  B9 04 00             mov        cx, 4
0x437e:  B0 00                mov        al, 0

TURN_OFF_NEXT_PAGE_LOOP:
0x4380:  E8 87 E6             call       TURN_OFF_EMS_PAGE
0x4383:  FE C0                inc        al
0x4385:  E2 F9                loop       TURN_OFF_NEXT_PAGE_LOOP


; now we are mostly calculating allocatable pages...

0x4387:  A1 95 28             mov        ax, word ptr [unallocated_page_count]
0x438a:  A3 89 28             mov        word ptr [total_page_count], ax
0x438d:  80 3E ED 28 00       cmp        byte ptr [backfill_enabled], 0
0x4392:  74 05                je         NO_BACKFILL_FOR_PAGE_COUNT
; add 24 pages to unallocated count for the backfill registers.
0x4394:  83 06 95 28 18       add        word ptr [unallocated_page_count], 0x18
NO_BACKFILL_FOR_PAGE_COUNT:
0x4399:  8D 36 CD 17          lea        si, OFFSET backfill_page_map

0x439d:  80 3E ED 28 00       cmp        byte ptr [backfill_enabled], 0
0x43a2:  74 22                je         NO_BACKFILL_HERE_EITHER
; backfill is enabled..
0x43a4:  B9 18 00             mov        cx, 0x18
0x43a7:  BB 00 00             mov        bx, 0
0x43aa:  B8 00 40             mov        ax, 0x4000
0x43ad:  C1 E8 0A             shr        ax, 0xa                ; page register index (not ems page index)
WRITE_NEXT_BACKFILL_PAGE_DATA:
0x43b0:  89 04                mov        word ptr [si], ax
0x43b2:  89 74 02             mov        word ptr [si + 2], si
0x43b5:  83 44 02 04          add        word ptr [si + 2], 4
0x43b9:  05 01 00             add        ax, 1
0x43bc:  83 C6 04             add        si, 4
0x43bf:  E2 EF                loop       WRITE_NEXT_BACKFILL_PAGE_DATA
0x43c1:  C7 44 FE FF FF       mov        word ptr [si - 2], 0xffff    ; why is this happening

NO_BACKFILL_HERE_EITHER:
0x43c6:  83 3E E8 3A 00       cmp        word ptr [mappable_384K_conventional], 0
0x43cb:  75 22                jne        384K_IS_MAPPABLE
0x43cd:  B8 00 C0             mov        ax, 0xc000
0x43d0:  C1 E8 0A             shr        ax, 0xa
0x43d3:  BB B5 17             mov        bx, bios_in_upper_pages
0x43d6:  B9 0C 00             mov        cx, 0xc

CHECK_NEXT_PAGE_FOR_ROM:
0x43d9:  2E 80 3F FF          cmp        byte ptr cs:[bx], 0xff
0x43dd:  74 0A                je         PAGE_IS_ROM_B
0x43df:  89 04                mov        word ptr [si], ax
0x43e1:  83 C6 04             add        si, 4
0x43e4:  83 06 95 28 01       add        word ptr [unallocated_page_count], 1
PAGE_IS_ROM_B:
0x43e9:  05 01 00             add        ax, 1
0x43ec:  43                   inc        bx
0x43ed:  E2 EA                loop       CHECK_NEXT_PAGE_FOR_ROM

384K_IS_MAPPABLE:
0x43ef:  8D 36 BD 00          lea        si, OFFSET handle_table
0x43f3:  89 36 79 28          mov        word ptr [handle_table_pointer], si
0x43f7:  8D 06 CD 17          lea        ax, OFFSET backfill_page_map
0x43fb:  89 44 0A             mov        word ptr [si + 0xa], ax
0x43fe:  80 3E ED 28 00       cmp        byte ptr [backfill_enabled], 0
0x4403:  74 24                je         BACKFILL_NOT_ENABLED_2

; do this only for backfill..
; we are initializing the EMS registers for backfill areas to point to their default locations. (pages 0x10....)
; this seems like a weird place to start, but ok. they shouild probably default to -1 (conventional) or 0xC... since there are 0xC upper pages, max.
0x4405:  C7 04 18 00          mov        word ptr [si], 0x18
0x4409:  B9 18 00             mov        cx, 0x18
0x440c:  BA 10 00             mov        dx, 0x10
0x440f:  B0 0C                mov        al, 0xc
LOOP_WRITE_TO_EMS_PORT:
0x4411:  E8 72 E5             call       WRITEEMSPORT
0x4414:  04 01                add        al, 1
0x4416:  83 C2 01             add        dx, 1
0x4419:  E2 F6                loop       LOOP_WRITE_TO_EMS_PORT
0x441b:  B0 0B                mov        al, 0xb
; here we write EMSENAB to register 0x0B again for some reason. this shouldn't be here unless it were already on?
0x441d:  E8 47 E5             call       READCHIPSETREG
0x4420:  0C 40                or         al, 0x40
0x4422:  8A E0                mov        ah, al
0x4424:  B0 0B                mov        al, 0xb
0x4426:  E8 47 E5             call       WRITECHIPSETREG

BAKCFILL_NOT_ENABLED_2:
0x4429:  B8 FF 00             mov        ax, 0xff
0x442c:  48                   dec        ax
0x442d:  A3 85 28             mov        word ptr [handle_count], ax
0x4430:  8D 36 CD 17          lea        si, OFFSET backfill_page_map
0x4434:  89 36 7D 28          mov        word ptr [backfill_page_map_pointer], si
0x4438:  A1 95 28             mov        ax, word ptr [unallocated_page_count]
0x443b:  BB 04 00             mov        bx, 4
0x443e:  F7 E3                mul        bx
0x4440:  03 F0                add        si, ax
0x4442:  89 36 7F 28          mov        word ptr [unallocated_page_count_pointer], si
0x4446:  BE BF 27             mov        si, OFFSET page_register_data_pointers
0x4449:  B8 00 40             mov        ax, 0x4000
LOOK_FOR_NEXT_PAGE_REGISTER:
0x444c:  8B 0E A1 28          mov        cx, word ptr [number_ems_pages]
0x4450:  BB 49 27             mov        bx, OFFSET page_register_data
0x4453:  BA 00 00             mov        dx, 0
LOOK_FOR_PAGE_REGISTER_DATA_LOOP:
0x4456:  3B 07                cmp        ax, word ptr [bx]
0x4458:  74 09                je         FOUND_PAGE_REGISTER_DATA
0x445a:  83 C3 03             add        bx, 3
0x445d:  42                   inc        dx
0x445e:  E2 F6                loop       LOOK_FOR_PAGE_REGISTER_DATA_LOOP
0x4460:  EB 09                jmp        NO_PAGE_REGISTER_DATA:
0x4462:  90                   nop        
FOUND_PAGE_REGISTER_DATA:
0x4463:  89 04                mov        word ptr [si], ax
0x4465:  89 54 02             mov        word ptr [si + 2], dx
0x4468:  83 C6 04             add        si, 4
NO_PAGE_REGISTER_DATA:
0x446b:  05 00 04             add        ax, 0x400
0x446e:  3D 00 F0             cmp        ax, 0xf000
0x4471:  75 D9                jne        LOOK_FOR_NEXT_PAGE_REGISTER

; generate OS rights password
0x4473:  B4 00                mov        ah, 0
0x4475:  CD 1A                int        0x1a       ; Read System Clock Counter
0x4477:  02 F1                add        dh, cl
0x4479:  2A EA                sub        ch, dl
0x447b:  86 F5                xchg       ch, dh
0x447d:  8B D9                mov        bx, cx
0x447f:  89 1E 75 28          mov        word ptr [os_password_low], bx
0x4483:  8B CA                mov        cx, dx
0x4485:  89 0E 77 28          mov        word ptr [os_password_high], cx

; set interrupt vector  0x67
0x4489:  8D 16 10 2B          lea        dx, OFFSET MAIN_EMS_INTERRUPT_VECTOR
0x448d:  B0 67                mov        al, 0x67
0x448f:  B4 25                mov        ah, 0x25
0x4491:  CD 21                int        0x21

DRIVER_INSTALLED:
0x4493:  8D 16 2B 3E          lea        dx, [string_driver_successfully_installed]
0x4497:  E8 35 00             call       PRINT_STRING
0x449a:  C4 1E 71 28          les        bx, ptr [driver_arguments]
0x449e:  26 C7 47 03 00 01    mov        word ptr es:[bx + 3], 0x100
0x44a4:  B8 B5 3A             mov        ax, OFFSET memory_configs
0x44a7:  26 89 47 0E          mov        word ptr es:[bx + 0xe], ax
0x44ab:  26 8C 4F 10          mov        word ptr es:[bx + 0x10], cs
0x44af:  C3                   ret

; DRIVER NOT INSTALLED
; preloaded with string 'reason' for the print string
DRIVER_NOT_INSTALLED:
0x44b0:  E8 1C 00             call       PRINT_STRING 
0x44b3:  8D 16 58 3E          lea        dx, [string_driver_failed_installing]
DRIVER_NOT_INSTALLED_2:
0x44b7:  E8 15 00             call       PRINT_STRING
0x44ba:  C4 1E 71 28          les        bx, ptr [driver_arguments]
0x44be:  26 C7 47 03 0C 81    mov        word ptr es:[bx + 3], 0x810c
0x44c4:  26 C7 47 0E 00 00    mov        word ptr es:[bx + 0xe], 0
0x44ca:  26 8C 4F 10          mov        word ptr es:[bx + 0x10], cs
0x44ce:  C3                   ret

; prints string ending in '$' in DS:DX
PRINT_STRING:
0x44cf:  1E                   push       ds
0x44d0:  50                   push       ax
0x44d1:  0E                   push       cs
0x44d2:  1F                   pop        ds
0x44d3:  B4 09                mov        ah, 9
0x44d5:  CD 21                int        0x21
0x44d7:  58                   pop        ax
0x44d8:  1F                   pop        ds
0x44d9:  C3                   ret

; takes string_page_number string offset and sets it up in format of spaces and 0s according to input AX's digit count in decimal.
; i.e. input AX = 0x110 = 272. string becomes ' 000'. input 20 because '  00'.
SET_UP_STRING_DIGITS:
0x44da:  50                   push       ax
0x44db:  53                   push       bx
0x44dc:  51                   push       cx
0x44dd:  52                   push       dx
0x44de:  57                   push       di
0x44df:  06                   push       es
0x44e0:  0E                   push       cs
0x44e1:  07                   pop        es
0x44e2:  50                   push       ax
0x44e3:  8D 3E A3 3E          lea        di, [string_page_number]
0x44e7:  B8 20 20             mov        ax, 0x2020
0x44ea:  B9 02 00             mov        cx, 2
0x44ed:  FC                   cld        
0x44ee:  F3 AB                rep stosw  word ptr es:[di], ax       ; write two spaces (0x20) to string two times. four in total (overwriting old string)
0x44f0:  58                   pop        ax
DO_NEXT_DIGIT:
0x44f1:  33 D2                xor        dx, dx
0x44f3:  BB 0A 00             mov        bx, 0xa
0x44f6:  F7 F3                div        bx                         ; divide by AX input by 10
0x44f8:  92                   xchg       ax, dx                     ; dx = ax / 10. AX = 0.
0x44f9:  04 30                add        al, 0x30                   ; al = '0'
0x44fb:  4F                   dec        di                         ; move backward in string a character
0x44fc:  88 05                mov        byte ptr [di], al          
0x44fe:  8B C2                mov        ax, dx                     ; ax = ax / 10
0x4500:  83 FA 00             cmp        dx, 0                      ; if dx > 0
0x4503:  75 EC                jne        DO_NEXT_DIGIT              ; then do this for one more digit..
0x4505:  07                   pop        es
0x4506:  5F                   pop        di
0x4507:  5A                   pop        dx
0x4508:  59                   pop        cx
0x4509:  5B                   pop        bx
0x450a:  58                   pop        ax
0x450b:  C3                   ret


; calls GET_ASCII_CHAR four four nibbles of the word to generate four ascii values. result stored in es:di
HEX_WORD_TO_ASCII:
0x450c:  50                   push       ax
0x450d:  53                   push       bx
0x450e:  51                   push       cx
0x450f:  52                   push       dx
0x4510:  8B D8                mov        bx, ax
0x4512:  8A C7                mov        al, bh
0x4514:  C0 E8 04             shr        al, 4
0x4517:  E8 1B 00             call       GET_ASCII_CHAR
0x451a:  8A C7                mov        al, bh
0x451c:  24 0F                and        al, 0xf
0x451e:  E8 14 00             call       GET_ASCII_CHAR
0x4521:  8A C3                mov        al, bl
0x4523:  C0 E8 04             shr        al, 4
0x4526:  E8 0C 00             call       GET_ASCII_CHAR
0x4529:  8A C3                mov        al, bl
0x452b:  24 0F                and        al, 0xf
0x452d:  E8 05 00             call       GET_ASCII_CHAR
0x4530:  5A                   pop        dx
0x4531:  59                   pop        cx
0x4532:  5B                   pop        bx
0x4533:  58                   pop        ax
0x4534:  C3                   ret

; seems like alphanumeric encoding. 0-9 value is '0' indexed ascii, 0xA and up is 'a' indexed ascii
; Hexadecimal nibble to ascii char function. result stored in es:di
GET_ASCII_CHAR:
0x4535:  3C 0A                cmp        al, 0xa
0x4537:  73 05                jae        CHAR_A_TO_F
0x4539:  04 30                add        al, 0x30
0x453b:  EB 05                jmp        CHAR_CONVERTED
0x453d:  90                   nop        
CHAR_A_TO_F:
0x453e:  2C 0A                sub        al, 0xa
0x4540:  04 41                add        al, 0x41
CHAR_CONVERTED:
0x4542:  AA                   stosb      byte ptr es:[di], al
0x4543:  C3                   ret


; Takes in page frame index in al  (0 = c000h, 1 = c400h... 8 = e000h);
; checks to see if there are no pageable frames from [al ... al+3] with rom fragments.
; if there are rom fragments, a scan of c000 to ec00 is done to try and find four consecutive fragments.
; returns page frame start segment in AX  
; doesn't seem to gracefully handly any error case
CHECK_IF_VALID_PAGE_FRAME:
0x4544:  1E                   push       ds
0x4545:  53                   push       bx
0x4546:  51                   push       cx
0x4547:  52                   push       dx

; this seems to do nothing. bh is clobbered the next line anyway

0x4548:  3C 04                cmp        al, 4
0x454a:  76 02                jbe        AL_LTE_4
0x454c:  B7 00                mov        bh, 0

AL_LTE_4:
0x454e:  8B D8                mov        bx, ax
0x4550:  B9 04 00             mov        cx, 4

; scan desired 64k page region four four non-rom pages.
KEEP_SEARCHING_FOR_ROM_PAGE_B:
0x4553:  80 BF B5 17 FF       cmp        byte ptr [bx + bios_in_upper_pages], 0xff
0x4558:  74 11                je         FOUND_ROM_PAGE_B
0x455a:  83 C3 01             add        bx, 1
0x455d:  E2 F4                loop       KEEP_SEARCHING_FOR_ROM_PAGE_B

; didnt find FF
0x455f:  8B D8                mov        bx, ax
0x4561:  D1 E3                shl        bx, 1
0x4563:  2E 8B 87 5B 28       mov        ax, word ptr cs:[bx + page_frame_segment_values]  ; set ax equal to c000 c400 etc
0x4568:  EB 2B                jmp        EXIT_FUNCTION_A
0x456a:  90                   nop        

; there was a ROM in the desired 64k page frame range. lets scan the whole pageable upper region for four consecutive free pages.
FOUND_ROM_PAGE_B:
; this is a page with ROM
0x456b:  33 DB                xor        bx, bx
0x456d:  8B D3                mov        dx, bx
RESTART_LOOP:
0x456f:  B9 04 00             mov        cx, 4      ; look for four consecutive clear pages again
CHECK_NEXT_PAGE:
0x4572:  2E 80 BF B5 17 FF    cmp        byte ptr cs:[bx + bios_in_upper_pages], 0xff
0x4578:  74 11                je         FOUND_ROM_PAGE
0x457a:  83 C3 01             add        bx, 1
0x457d:  E2 F3                loop       CHECK_NEXT_PAGE
0x457f:  8B DA                mov        bx, dx
0x4581:  D1 E3                shl        bx, 1
0x4583:  2E 8B 87 5B 28       mov        ax, word ptr cs:[bx + page_frame_segment_values]
0x4588:  EB 0B                jmp        EXIT_FUNCTION_B
0x458a:  90                   nop        
FOUND_ROM_PAGE:
0x458b:  83 C2 01             add        dx, 1
0x458e:  8B DA                mov        bx, dx
0x4590:  83 FB 04             cmp        bx, 4
0x4593:  76 DA                jbe        RESTART_LOOP
EXIT_FUNCTION_B:
0x4595:  5A                   pop        dx
0x4596:  59                   pop        cx
0x4597:  5B                   pop        bx
0x4598:  1F                   pop        ds
0x4599:  C3                   ret


FIND_BIOSES:
0x459a:  50                   push       ax
0x459b:  53                   push       bx
0x459c:  B8 00 C0             mov        ax, 0xc000
LOOP_DO_CHECKSUM:
0x459f:  E8 36 00             call       DO_CHECKSUM
0x45a2:  73 2C                jae        NO_BIOS_FOUND
0x45a4:  50                   push       ax
0x45a5:  53                   push       bx
0x45a6:  51                   push       cx
0x45a7:  50                   push       ax
0x45a8:  50                   push       ax
0x45a9:  2D 00 C0             sub        ax, 0xc000
0x45ac:  C1 E8 0A             shr        ax, 0xa        ; ax is now page frame index..
0x45af:  59                   pop        cx             ; cx is tested bios fragment
0x45b0:  C1 E1 06             shl        cx, 6          ; page frame part is shifted out. if zero then we have c400 c800 etc segment
0x45b3:  74 01                je         HAVE_SEGMENT        
0x45b5:  40                   inc        ax             ; otherwise we have a segment like c480 c880 etc. so we are incrementing the page frame index
HAVE_SEGMENT:
0x45b6:  5B                   pop        bx             ; bx is now tested bios segment
0x45b7:  2B DA                sub        bx, dx         ; dx is byte size of last segment
0x45b9:  81 EB 00 C0          sub        bx, 0xc000     ; subtract page frame... we have an offset.
0x45bd:  C1 EB 0A             shr        bx, 0xa        ; shift right
; based on size of bios and how many page frames it carries over, lets mark all those pages as having bios in them
CONTINUE_RECORDING_BIOS_FRAGMENT:
0x45c0:  3B D8                cmp        bx, ax         ; bx and ax are both some page frame segments.
0x45c2:  73 09                jae        DONE_RECORDING_BIOS_FRAGMENT         
0x45c4:  2E C6 87 B5 17 FF    mov        byte ptr cs:[bx + bios_in_upper_pages], 0xff ; mark bios found
0x45ca:  43                   inc        bx             ; inc fragment
0x45cb:  EB F3                jmp        CONTINUE_RECORDING_BIOS_FRAGMENT
DONE_RECORDING_BIOS_FRAGMENT:
0x45cd:  59                   pop        cx
0x45ce:  5B                   pop        bx
0x45cf:  58                   pop        ax
NO_BIOS_FOUND:
; stop before F000
0x45d0:  3D 80 EF             cmp        ax, 0xef80
0x45d3:  76 CA                jbe        LOOP_DO_CHECKSUM

0x45d5:  5B                   pop        bx
0x45d6:  58                   pop        ax
0x45d7:  C3                   ret


; this checks to see if the segment in AX points to a BIOS.
; return carry flag if it is
; dx returns bios segment size. 0x80 if nothing (test next one) otherwise numbers of segments. 
DO_CHECKSUM:
0x45d8:  1E                   push       ds
0x45d9:  53                   push       bx
0x45da:  51                   push       cx
0x45db:  56                   push       si
0x45dc:  8E D8                mov        ds, ax
0x45de:  33 DB                xor        bx, bx
0x45e0:  81 3F 55 AA          cmp        word ptr [bx], 0xaa55
0x45e4:  75 1E                jne        RETURN_NO_CARRY_FLAG_2
0x45e6:  33 F6                xor        si, si
0x45e8:  33 C9                xor        cx, cx
0x45ea:  8A 4F 02             mov        cl, byte ptr [bx + 2]      ; cl * 512 = bios size
0x45ed:  C1 E1 09             shl        cx, 9
0x45f0:  8B D1                mov        dx, cx
CONTINUE_CHECKSUMMING:
0x45f2:  AC                   lodsb      al, byte ptr [si]
0x45f3:  02 D8                add        bl, al
0x45f5:  E2 FB                loop       CONTINUE_CHECKSUMMING
0x45f7:  75 0B                jne        RETURN_NO_CARRY_FLAG_2
0x45f9:  C1 EA 04             shr        dx, 4
0x45fc:  8C D8                mov        ax, ds
0x45fe:  03 C2                add        ax, dx
RETURN_CARRY_FLAG_2:
0x4600:  F9                   stc        
0x4601:  EB 09                jmp        CONTINUE_RETURN
0x4603:  90                   nop        
RETURN_NO_CARRY_FLAG_2:
0x4604:  BA 80 00             mov        dx, 0x80
0x4607:  8C D8                mov        ax, ds
0x4609:  03 C2                add        ax, dx
0x460b:  F8                   clc        
CONTINUE_RETURN:
0x460c:  5E                   pop        si
0x460d:  59                   pop        cx
0x460e:  5B                   pop        bx
0x460f:  1F                   pop        ds
0x4610:  C3                   ret     