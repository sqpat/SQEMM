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
 
CONST_HANDLE_TABLE_LENGTH = 0FFh
CONST_PAGE_COUNT = 128
; as low as 43h seems to work? not sure why this isnt just 28h
CONST_PAGE_OFFSET_AMT = 50h


 

; 027bfh 
; Two-word pairs. first word is page frame (04000h, 04400h... etc) up to f000.  
;                 second word its physical ems index port
; 144 bytes long 
; i think a clone of the above struct in practice except pre-formatted for return in function 5800h (2nd arg a word, ordered lowest segment first)

; CHIPSET SPECIFIC START

; you can hardcode the chipset's mappable page list here for call 5800

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

 
; CHIPSET SPECIFIC END


;0284Fh
db 'MAP_PAGE_END'



; 02871h: 32-bit pointer to arguments to driver
driver_arguments dd 00000000h 






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


; 028F8h: EMS Function pointer table
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
push cx
push bx
push si

;cmp        cx, 0
;jne        VALID_SUBFUNCTION_PARAMETER
; invalid subfunction parameter
;jmp        RETURN_BAD_SUBFUNCTION_PARAMETER
;VALID_SUBFUNCTION_PARAMETER:
;push       bx
;xor        ah, ah
;cmp        ah, 1
;je         EMS_FUNCTION_05001h

; physical page number mode
DO_NEXT_PAGE_5000:
; next page in ax....
lodsw
mov        bx, ax
lodsw
; read two words - bx and ax

cmp ax, 12
jae NOT_CONVENTIONAL_REGISTER_5000
add ax, 4 ; need to add 4 for d000 case for scamp...  c000, e000  not supported
out        0E8h, al   ; select EMS page
sub ax, 4
xchg  ax, bx
cmp   ax, 0FFFFh   ; -1 check
je    handle_default_page
add   ax, CONST_PAGE_OFFSET_AMT   ; offset by default starting page
out   0EAh, ax   ; write 16 bit page num. 

loop       DO_NEXT_PAGE_5000

; exits if we fall thru loop with no error
xor        ax, ax
pop si
pop bx
pop cx
iret

NOT_CONVENTIONAL_REGISTER_5000:
 
out        0E8h, al   ; select EMS page

xchg  ax, bx
cmp   ax, 0FFFFh   ; -1 check
je    handle_default_page

add   ax, CONST_PAGE_OFFSET_AMT   ; offset by default starting page
out   0EAh, ax   ; write 16 bit page num. 


loop       DO_NEXT_PAGE_5000

; exits if we fall thru loop with no error
xor        ax, ax
pop si
pop bx
pop cx
iret

handle_default_page:
; mapping to page -1
mov  ax,   bx   ; retrieve page number
add  ax,   4
out  0EAh, ax   ; write 16 bit page num. 
loop       DO_NEXT_PAGE_5000
; fall thru if done..

xor        ax, ax
pop si
pop bx
pop cx
iret

NOT_FUNC_50h:
cmp      ah, 044h
jne      NOT_FUNC_44h

; page one function

EMS_FUNCTION_044h:
xor        ah, ah
cmp        ax, word ptr cs:[number_ems_pages]
jb         ENOUGH_PAGES
jmp        RETURN_RESULT_8B

ENOUGH_PAGES:
cmp        dx,  1
jne        RETURN_RESULT_83
 
; call TURN_OFF_EMS_PAGE
; al and bx are still the args

; dumb hack. internally c000 - ec00 are pages 0-11 in order.
; but if you want d000 to be page frame, outwardly we must expose it as 0-4.
; so we are assuming 0-4 and adding by 4 to get the real internal offset
; and assume 4-12 not used.

cmp   ax, 12
jae   NOT_CONVENTIONAL_REGISTER
add   ax, 4 ; need to add 4 for d000 case for scamp...  we do this branch knowing it may need to undone eventually
out   0E8h, al   ; select EMS page
sub   ax, 4      ; subtract because we may need this later for handle default page (TODO only do this then)
xchg  ax, bx
cmp   ax, 0FFFFh   ; -1 check
je    handle_default_page_44h
mov   bx, ax     ; restore bx for return
add   ax, CONST_PAGE_OFFSET_AMT   ; offset by default starting page
out   0EAh, ax   ; write 16 bit page num. 
mov   ah, 000h
iret

NOT_CONVENTIONAL_REGISTER:


; write ems port... select chipset register
out   0E8h, al   ; select EMS page
xchg  ax, bx
cmp   ax, 0FFFFh   ; -1 check
je    handle_default_page_44h
mov   bx, ax     ; restore bx for return
add   ax, CONST_PAGE_OFFSET_AMT   ; offset by default starting page
out   0EAh, ax   ; write 16 bit page num. 


RETURN_RESULT_00:

mov        ah, 000h
iret

handle_default_page_44h:
; mapping to page -1
xchg  ax,   bx   ; retrieve page number, restore bx at same time
; add four to get the default page value for the page 
add   ax, 4
out   0EAh, ax   ; write 16 bit page num. 
mov   ah, 000h
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
 
out        0E8h, al   ; select EMS page
xchg ax, ax  ; nop delays
xchg ax, ax
xchg ax, ax
mov  ax, bx

; ??? seems this must be on, not sure why actually...
mov  ah, 1    

out  0EAh, ax   ; write 16 bit page num. 




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
; 03ae3h  stores slot pointer * 4
slotpointer_byte_times_4_word dw 0000h
; 03ae7h  stores slot pointer byte
slotpointer_byte db 00h
; 03ae8h  amount of mappable memory in 256k-640k region. seems to either store 0 or 384 decimal (0180h)
mappable_384K_conventional dw 0000h
; 03aeah  
string_driver_exists db 0Dh, 0Ah, ' EMS Driver already exists (chaining not supported).',0Dh, 0Ah,0Ah, 0Ah, '$'
; 03B0Bh  
string_main_header db 0Dh, 0Ah, 'SQEMM v 0.1 for VL82C311', 0Dh, 0Ah,'$'
 

; 03E2Bh
string_driver_successfully_installed db 0Dh, 0Ah, 'SQEMM successfully initialized.', 0Ah, 0Dh, '$'
; 03E58h
string_driver_failed_installing db 0Dh, 0Ah, '     VL82C311 EMS is not installed.', 0Ah, 0Ah, 0Ah, 0Ah, 0Dh, '$'





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

; do actual driver preparation here
; todotodo

; CHIPSET SPECIFIC START

; for porting to other chipsets, prepare chipset registers
; and driver variables here. In this case we set page frame
; to D000, set 36 mappable pages, we are only allowing a
; single handle, and set 128 mappable pages. we also prepare
; ems registers to initial values and enable EMS and backfill.


; hard coded to d000 for now
mov        word ptr [page_frame_segment], 0D000h

; 128 pages hardcoded for now
mov        word ptr [unallocated_page_count], CONST_PAGE_COUNT
mov        word ptr [total_page_count], CONST_PAGE_COUNT

; ok?
mov        word ptr [number_ems_pages], 36

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
out   0E8h, al
sub   ax, 4
xchg  ax, ax
xchg  ax, ax
out   0EAh, ax
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
out   0E8h, al
add   ax, 4
xchg  ax, ax
xchg  ax, ax
out   0EAh, ax
sub   ax, 3       ; inc included..
loop enablebackfillloop

; note: we must treat 'set page to default/-1' case as these values
; and we must offset every page set offset by 28h otherwise to avoid these defaults.

; CHIPSET SPECIFIC END




; set interrupt vector  067h

lea        dx, MAIN_EMS_INTERRUPT_VECTOR

mov        al, 067h
mov        ah, 025h
int        021h

DRIVER_INSTALLED:

lea        dx, [string_driver_successfully_installed]

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

lea        dx, [string_driver_failed_installing]

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