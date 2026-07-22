.8086
.MODEL tiny

PUSHA_MACRO MACRO

    push  ax	
    push  cx
    push  dx
    push  bx
    push  si
    push  di
ENDM


POPA_MACRO MACRO

    pop   di
    pop   si
    pop   bx
    pop   dx
    pop   cx
    pop   ax	
ENDM

PRINT_STRING MACRO  string_loc
    mov dx, OFFSET &string_loc
    mov ah, 9
    int 021h
ENDM

TEST_RESULT_AX MACRO testax
    push bx
    mov  word ptr ds:[expected_value], testax
    mov  word ptr ds:[string_register_name_offset], "XA" ; endian
    mov  bx, ax
    call print_hex_register
    cmp  ax, word ptr ds:[expected_value]
    je   $+5
    call prompt_for_key
    pop  bx
ENDM

TEST_RESULT_DX MACRO testdx
    push bx
    mov  word ptr ds:[expected_value], testdx
    mov  word ptr ds:[string_register_name_offset], "XD" ; endian
    mov  bx, dx
    call print_hex_register
    cmp  dx, word ptr ds:[expected_value]
    je   $+5
    call prompt_for_key
    pop  bx
ENDM

TEST_RESULT_DX_NO_VAL MACRO testdx
    cmp  dx, word ptr ds:[expected_value]
    je   $+18
    push bx
    mov  word ptr ds:[string_register_name_offset], "XD" ; endian
    mov  bx, dx
    call print_hex_register
    call prompt_for_key
    pop  bx
    ; jump here
ENDM


TEST_RESULT_BX MACRO testbx

    mov  word ptr ds:[expected_value], testbx
    mov  word ptr ds:[string_register_name_offset], "XB" ; endian

    call print_hex_register
    cmp  bx, word ptr ds:[expected_value]
    je   $+5
    call prompt_for_key


ENDM

TEST_EMS_REGISTER_CALL_ALL MACRO testax
    mov  word ptr ds:[VARIABLE_expected_register_ax], testax
    call do_ems_call_and_register_test
ENDM

TEST_EMS_REGISTER_CALL_AH MACRO testah
    mov  byte ptr ds:[VARIABLE_expected_register_ax+1], testah
    mov  byte ptr ds:[VARIABLE_expected_register_ax+0], al
    call do_ems_call_and_register_test
ENDM

TEST_EMS_REGISTER_CALL_NO_AL MACRO testah
    mov  byte ptr ds:[VARIABLE_expected_register_ax+1], testah
    call do_ems_call_and_register_test_no_al
ENDM


TEST_EMS_REGISTER_CALL_NO_BX MACRO testax
    mov  word ptr ds:[VARIABLE_expected_register_ax], testax
    call do_ems_call_and_register_test_no_bx
ENDM

TEST_EMS_REGISTER_CALL_NO_DX MACRO testax
    mov  word ptr ds:[VARIABLE_expected_register_ax], testax
    call do_ems_call_and_register_test_no_dx
ENDM

TEST_EMS_REGISTER_CALL_NO_CX MACRO testax
    mov  word ptr ds:[VARIABLE_expected_register_ax], testax
    call do_ems_call_and_register_test_no_cx
ENDM

TEST_EMS_REGISTER_CALL_NO_BX_DX MACRO testax
    mov  word ptr ds:[VARIABLE_expected_register_ax], testax
    call do_ems_call_and_register_test_no_bx_dx
ENDM

TEST_EMS_REGISTER_CALL_NO_BX_CX MACRO testax
    mov  word ptr ds:[VARIABLE_expected_register_ax], testax
    call do_ems_call_and_register_test_no_bx_cx
ENDM

TEST_EMS_REGISTER_CALL_NO_DI MACRO testax
    mov  word ptr ds:[VARIABLE_expected_register_ax], testax
    call do_ems_call_and_register_test_no_di
ENDM

PRINT_HANDLE MACRO
    ; call  print_handle
ENDM

PRINT_RUNNING_TEST MACRO testimmediate
    mov   word ptr ds:[_test_num], &testimmediate
    call  show_running_test
ENDM


PRINT_HEX_VALUE_BX MACRO addressstring, addresshex
    push dx
    push ax
    push si

    mov   si, OFFSET &addresshex
    call  print_hex_word_bx 

    PRINT_STRING addressstring



    pop  si
    pop  ax
    pop  dx

ENDM

.code

; EXECUTABLE STARTS HERE.


PUSHA_MACRO
push  ds
push  es

push  cs
push  cs
pop   ds
pop   es

mov  word ptr ds:[VARIABLE_exit_sp], sp


; BASIC TESTS START
; BASIC TESTS START
; BASIC TESTS START
; BASIC TESTS START
; BASIC TESTS START
; BASIC TESTS START

;     FUNCTION 1    GET STATUS

PRINT_RUNNING_TEST 1
mov   ax, 04001h

TEST_EMS_REGISTER_CALL_ALL 0001h




;     FUNCTION 2    GET PAGE FRAME ADDRESS

PRINT_RUNNING_TEST 2
mov   ax, 04102h

TEST_EMS_REGISTER_CALL_NO_BX 0002h

PRINT_HEX_VALUE_BX string_hex_page_frame_address string_hex_page_frame_address_offset
mov   word ptr ds:[VARIABLE_page_frame+2], bx
mov   word ptr ds:[partial_pagemap_1_func_16_page_frame+0], bx
add   bh, 04h
mov   word ptr ds:[VARIABLE_page_frame+6], bx
add   bh, 04h
mov   word ptr ds:[partial_pagemap_1_func_16_page_frame+2], bx
mov   word ptr ds:[VARIABLE_page_frame+10], bx
add   bh, 04h
mov   word ptr ds:[VARIABLE_page_frame+14], bx



;     FUNCTION 7    GET VERSION
PRINT_RUNNING_TEST 3
mov   ax, 04607h

TEST_EMS_REGISTER_CALL_ALL 0040h


;     FUNCTION 3    GET UNALLOCATED PAGE COUNT

PRINT_RUNNING_TEST 4
mov   ax, 04203h
TEST_EMS_REGISTER_CALL_NO_BX_DX 0003h

mov   word ptr ds:[VARIABLE_unallocated_page_count], bx
mov   word ptr ds:[VARIABLE_unallocated_total_page_count], dx

call  print_page_count



;     FUNCTION 12   GET HANDLE COUNT

mov   ax, 04B40h
TEST_EMS_REGISTER_CALL_NO_BX 0040h

mov   word ptr ds:[VARIABLE_total_handle_count], bx

; just look this variable up for now

mov   ax, 05400h
mov   di, OFFSET func_21_handle_directory 
TEST_EMS_REGISTER_CALL_NO_AL 000h  
mov   word ptr ds:[VARIABLE_handle_directory_count], ax




;     FUNCTION 4    ALLOCATE PAGES


PRINT_RUNNING_TEST 5
mov   ax, 04304h
mov   bx, 1

TEST_EMS_REGISTER_CALL_NO_DX 0004h
PRINT_HANDLE

;     FUNCTION 13   GET HANDLE PAGES

mov   ax, 04C41h
TEST_EMS_REGISTER_CALL_NO_BX 0041h

TEST_RESULT_BX  1


mov   ax, 04B40h
TEST_EMS_REGISTER_CALL_NO_BX 0040h
mov   ax, word ptr ds:[VARIABLE_total_handle_count]
inc   ax
TEST_RESULT_BX  AX  ; handle count shout be decreased by 1

mov   ax, 05400h
mov   di, OFFSET func_21_handle_directory 
TEST_EMS_REGISTER_CALL_NO_AL 000h  
mov   bx, word ptr ds:[VARIABLE_handle_directory_count]
inc   bx
TEST_RESULT_BX  AX  ; should be increased by 1



; dx maintains index


;     FUNCTION 6    DEALLOCATE PAGES


PRINT_RUNNING_TEST 6
mov   ax, 04505h
TEST_EMS_REGISTER_CALL_ALL 0005h



mov   ax, 04C10h
TEST_EMS_REGISTER_CALL_ALL 08310h  ; dead handle

mov   ax, 04B40h
TEST_EMS_REGISTER_CALL_NO_BX 0040h
mov   ax, word ptr ds:[VARIABLE_total_handle_count]
TEST_RESULT_BX  AX





; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END





; HANDLE MAPPING STRESS TESTS START
; HANDLE MAPPING STRESS TESTS START
; HANDLE MAPPING STRESS TESTS START
; HANDLE MAPPING STRESS TESTS START
; HANDLE MAPPING STRESS TESTS START
; HANDLE MAPPING STRESS TESTS START



; TEST 7: Allocate 3 handles of 4 pages each. confirm 12 pages came out.

PRINT_RUNNING_TEST 7
mov   cx, 4
mov   ax, 04307h
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_DX 0007h
PRINT_HANDLE
mov   word ptr ds:[VARIABLE_saved_handle_1], dx

mov   ax, 04308h
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_DX 0008h
PRINT_HANDLE
mov   word ptr ds:[VARIABLE_saved_handle_2], dx

mov   ax, 04309h
mov   bx, cx
TEST_EMS_REGISTER_CALL_NO_DX 0009h
PRINT_HANDLE
mov   word ptr ds:[VARIABLE_saved_handle_3], dx

mov   ax, 0420Ah

TEST_EMS_REGISTER_CALL_NO_BX_DX 000Ah
mov   ax, word ptr ds:[VARIABLE_unallocated_page_count]
sub   ax, 12
mov   word ptr ds:[expected_value], ax
mov   dx, bx
TEST_RESULT_DX_NO_VAL

; TEST 8: Reallocate pages back and forth. confirm page count remains correct.
PRINT_RUNNING_TEST 8

;     FUNCTION 18   REALLOCATE PAGES
mov   cx, 3
mov   dx, word ptr ds:[VARIABLE_saved_handle_1]
mov   ax, 0510Bh
mov   bx, cx
TEST_EMS_REGISTER_CALL_NO_BX 000Bh
mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
mov   ax, 0510Ch
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_BX 000Ch
mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
mov   ax, 0510Dh
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_BX 000Dh

mov   ax, 0420Ah

TEST_EMS_REGISTER_CALL_NO_BX_DX 000Ah
mov   ax, word ptr ds:[VARIABLE_unallocated_page_count]
sub   ax, 9
mov   word ptr ds:[expected_value], ax
mov   dx, bx
TEST_RESULT_DX_NO_VAL

mov   cx, 0
mov   dx, word ptr ds:[VARIABLE_saved_handle_1]
mov   ax, 0510Bh
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_BX 000Bh
mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
mov   ax, 0510Ch
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_BX 000Ch
mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
mov   ax, 0510Dh
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_BX 000Dh

mov   ax, 0420Ah

TEST_EMS_REGISTER_CALL_NO_BX_DX 000Ah
mov   ax, word ptr ds:[VARIABLE_unallocated_page_count]
mov   word ptr ds:[expected_value], ax
mov   dx, bx
TEST_RESULT_DX_NO_VAL


mov   cx, 12
mov   dx, word ptr ds:[VARIABLE_saved_handle_1]
mov   ax, 0510Bh
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_BX 000Bh
mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
mov   ax, 0510Ch
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_BX 000Ch
mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
mov   ax, 0510Dh
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_BX 000Dh

mov   ax, 0420Ah

TEST_EMS_REGISTER_CALL_NO_BX_DX 000Ah
mov   ax, word ptr ds:[VARIABLE_unallocated_page_count]
sub   ax, 36
mov   word ptr ds:[expected_value], ax
mov   dx, bx
TEST_RESULT_DX_NO_VAL





; deallocate

mov   dx, word ptr ds:[VARIABLE_saved_handle_1]
mov   ax, 0450Eh
TEST_EMS_REGISTER_CALL_ALL 000Eh

mov   dx, word ptr ds:[VARIABLE_saved_handle_2]

mov   ax, 0450Eh
TEST_EMS_REGISTER_CALL_ALL 000Eh

mov   dx, word ptr ds:[VARIABLE_saved_handle_3]

mov   ax, 0450Eh
TEST_EMS_REGISTER_CALL_ALL 000Eh



; test 0 pages

mov   ax, 04309h
xor   bx, bx

TEST_EMS_REGISTER_CALL_ALL 08909h ; zero page should fail





; TEST 9: allocate pages and put stuff in them. then page around and confirm their contents are ok
PRINT_RUNNING_TEST 9


;     FUNCTION 5    MAP/UNMAP HANDLE PAGES
mov   cx, 4
mov   ax, 04307h
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_DX 0007h
PRINT_HANDLE
mov   word ptr ds:[VARIABLE_saved_handle_1], dx

mov   ax, 04308h
mov   bx, cx
TEST_EMS_REGISTER_CALL_NO_DX 0008h
PRINT_HANDLE
mov   word ptr ds:[VARIABLE_saved_handle_2], dx

mov   ax, 04309h
mov   bx, cx
TEST_EMS_REGISTER_CALL_NO_DX 0009h
PRINT_HANDLE
mov   word ptr ds:[VARIABLE_saved_handle_3], dx

mov   ax, 04309h
mov   bx, cx
TEST_EMS_REGISTER_CALL_NO_DX 0009h
PRINT_HANDLE
mov   word ptr ds:[VARIABLE_saved_handle_4], dx

mov   ax, 04309h
mov   bx, 64
TEST_EMS_REGISTER_CALL_NO_DX 0009h
PRINT_HANDLE
mov   word ptr ds:[VARIABLE_saved_handle_5], dx

mov   ax, 0420Ah
TEST_EMS_REGISTER_CALL_NO_BX_DX 000Ah

mov   ax, word ptr ds:[VARIABLE_unallocated_page_count]
sub   ax, 64 + 16
mov   word ptr ds:[expected_value], ax
mov   dx, bx
TEST_RESULT_DX_NO_VAL

here:
public here

;     FUNCTION 27   ALLOCATE STANDARD/RAW PAGES

mov   ax, 05A02h
TEST_EMS_REGISTER_CALL_ALL 08F02h ; bad subfunction
xor   bx, bx  ; zero page allocation should be ok
mov   ax, 05A00h
TEST_EMS_REGISTER_CALL_NO_DX 00000h ; ok?

push  dx  ; store handle

; make sure none were allocated...
mov   ax, 0420Ah
TEST_EMS_REGISTER_CALL_NO_BX_DX 000Ah
mov   ax, word ptr ds:[VARIABLE_unallocated_page_count]
sub   ax, 64 + 16
mov   word ptr ds:[expected_value], ax
mov   dx, bx
TEST_RESULT_DX_NO_VAL

pop   dx ; retrieve handle for deallocation

mov   ax, 0450Eh
TEST_EMS_REGISTER_CALL_ALL 000Eh

; and test none were deallocated once more
; make sure none were allocated...
mov   ax, word ptr ds:[VARIABLE_unallocated_page_count]
sub   ax, 64 + 16
mov   word ptr ds:[expected_value], ax
mov   dx, bx
TEST_RESULT_DX_NO_VAL




mov   dx, word ptr ds:[VARIABLE_saved_handle_5]

call fill_in_64_pages

mov   dx, word ptr ds:[VARIABLE_saved_handle_4]
xor   ax, ax
call  page_in_four_pages_starting_at_ax
mov   ax, 64
call  fill_in_four_pages_increment_ax

mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
xor   ax, ax
call  page_in_four_pages_starting_at_ax
mov   ax, 68
call  fill_in_four_pages_increment_ax


mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
xor   ax, ax
call  page_in_four_pages_starting_at_ax
mov   ax, 72
call  fill_in_four_pages_increment_ax


mov   dx, word ptr ds:[VARIABLE_saved_handle_1]
xor   ax, ax
call  page_in_four_pages_starting_at_ax
mov   ax, 76
call  fill_in_four_pages_increment_ax



mov   dx, word ptr ds:[VARIABLE_saved_handle_5]
call  test_64_pages_in_reverse

;;;; done testing pages one by one. 




; create a dead handle

mov   ax, 04311h
mov   bx, 1
TEST_EMS_REGISTER_CALL_NO_DX 0011h

PRINT_HANDLE
mov   word ptr ds:[VARIABLE_dead_handle], dx  ; dx handle should be unallocated and bad as long as we dont allocate any more after this.

mov   ax, 04B40h
TEST_EMS_REGISTER_CALL_NO_BX 0040h
mov   ax, word ptr ds:[VARIABLE_total_handle_count]
add   ax, 6
TEST_RESULT_BX  AX  ; handle count shout be increased by 6


mov   ax, 04511h
TEST_EMS_REGISTER_CALL_ALL 0011h

; TODO more bad handle tests and bad subfunction


; NOTE: this assumes handles currently allocated 1-5 which is... iffy.  but true for sqemm
; NOTE: this assumes handles currently allocated 1-5 which is... iffy.  but true for sqemm
; NOTE: this assumes handles currently allocated 1-5 which is... iffy.  but true for sqemm

;     FUNCTION 14   GET ALL HANDLES PAGES

mov   di, OFFSET func_1400_handle_page_list  ; a lot of space here
mov   ax, 04D4Ch
TEST_EMS_REGISTER_CALL_NO_BX 004Ch
mov   ax, word ptr ds:[VARIABLE_total_handle_count]
add   ax, 5
TEST_RESULT_BX  AX  ; handle count shout be increased by 5

mov   cx, ax
mov   si, di

loop_test_next_page_contents:
    lodsw  
    xchg  ax, bx  ; emm handle.
    shl   bx, 1
    lodsw ; get page count
    cmp   ax, word ptr ds:[bx + func_14_page_counts]
    loop loop_test_next_page_contents



; TEST 10: test pages in page frame via function 8/9 stack
PRINT_RUNNING_TEST 10

;     FUNCTION 8    SAVE PAGE MAP
;     FUNCTION 9    RESTORE PAGE MAP

mov   dx, word ptr ds:[VARIABLE_saved_handle_5]
mov   ax, 20
call  page_in_four_pages_starting_at_ax
call  test_four_pages


mov   dx, word ptr ds:[VARIABLE_dead_handle]
mov   ax, 04712h
TEST_EMS_REGISTER_CALL_ALL 08312h  ; bad handle

mov   ax, 04822h
TEST_EMS_REGISTER_CALL_ALL 08322h  ; bad handle

; should be page 20 21 22 23

mov   dx, word ptr ds:[VARIABLE_saved_handle_5]

mov   ax, 04823h
TEST_EMS_REGISTER_CALL_ALL 08E23h  ; no context


mov   ax, 04713h
TEST_EMS_REGISTER_CALL_ALL 00013h ; good

mov   ax, 04510h
TEST_EMS_REGISTER_CALL_ALL 08610h  ; cant delete handle with stack context..



mov   ax, 04714h
TEST_EMS_REGISTER_CALL_ALL 08D14h  ; already have a state.


mov   ax, 10
call  page_in_four_pages_starting_at_ax
call  test_four_pages

mov   ax, 04824h
TEST_EMS_REGISTER_CALL_ALL 00024h  ; good context

mov   ax, 20
call  test_four_pages

; now lets do 3 handles on stack

mov   ax, 04713h
TEST_EMS_REGISTER_CALL_ALL 00013h ; good

mov   dx, word ptr ds:[VARIABLE_saved_handle_4]
mov   ax, 04713h
TEST_EMS_REGISTER_CALL_ALL 00013h ; good

xor   ax, ax
call  page_in_four_pages_starting_at_ax
mov   ax, 64
call  test_four_pages

mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
mov   ax, 04713h
TEST_EMS_REGISTER_CALL_ALL 00013h ; good

xor   ax, ax
call  page_in_four_pages_starting_at_ax
mov   ax, 68
call  test_four_pages

mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
mov   ax, 04713h
TEST_EMS_REGISTER_CALL_ALL 00013h ; good

xor   ax, ax
call  page_in_four_pages_starting_at_ax
mov   ax, 72
call  test_four_pages


mov   dx, word ptr ds:[VARIABLE_saved_handle_1]
mov   ax, 04713h
TEST_EMS_REGISTER_CALL_ALL 00013h ; good

xor   ax, ax
call  page_in_four_pages_starting_at_ax
mov   ax, 76
call  test_four_pages

mov   ax, 04824h
TEST_EMS_REGISTER_CALL_ALL 00024h  ; good context

mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
mov   ax, 72
call  test_four_pages
mov   ax, 04824h
TEST_EMS_REGISTER_CALL_ALL 00024h ; good

mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
mov   ax, 68
call  test_four_pages
mov   ax, 04824h
TEST_EMS_REGISTER_CALL_ALL 00024h ; good


mov   dx, word ptr ds:[VARIABLE_saved_handle_4]
mov   ax, 64
call  test_four_pages
mov   ax, 04824h
TEST_EMS_REGISTER_CALL_ALL 00024h ; good


mov   dx, word ptr ds:[VARIABLE_saved_handle_5]
mov   ax, 20
call  test_four_pages






; TEST 11: test random pages in page frame via function 17 map/unmap multiple
PRINT_RUNNING_TEST 11

mov   cx, 8
loop_test_random_four:
public loop_test_random_four
    call test_random_four_5701
    call test_random_four_5700
    loop loop_test_random_four




;; CONVENTIONAL TESTS. SKIP IF NOT SUPPORTED?
;; CONVENTIONAL TESTS. SKIP IF NOT SUPPORTED?
;; CONVENTIONAL TESTS. SKIP IF NOT SUPPORTED?
;; CONVENTIONAL TESTS. SKIP IF NOT SUPPORTED?


; TEST 12: check conventional pagination capabilities
PRINT_RUNNING_TEST 12


;     FUNCTION 25   GET MAPPABLE PHYSICAL ADDRESS ARRAY
; set up conventional. skip conventional tests if the

mov   ax, 05801h
TEST_EMS_REGISTER_CALL_NO_CX 00001h
cmp   cx, 28
jae   continue_conventional


go_skip_conventional:
PRINT_STRING str_no_conventional_tests
jmp   skip_conventional

continue_conventional:
mov   dx, cx
mov   ax, 05800h
mov   di, OFFSET map_1700_page_list_full ; offset by 2 

TEST_EMS_REGISTER_CALL_NO_CX 00000h


cmp   cx, 28
jb    go_skip_conventional
cmp   cx, dx
jne   go_skip_conventional  ; todo implement 4 page card test path
mov   word ptr ds:[VARIABLE_page_count], cx  

mov   si, OFFSET map_1700_page_list_full ; offset by 2 
mov   di, OFFSET map_1701_page_list_full + 2
shl   cx, 1  ; we also write the logical entries, which are garbage for now.
rep   movsw


; TEST 13: test pages in conventional region via function 5 page one
PRINT_RUNNING_TEST 13

mov   dx, word ptr cs:[VARIABLE_saved_handle_5]
mov   cx, 8
mov   si, OFFSET map_1700_page_list_full
loop_random_conventional_pages_4400:
    call  page_random_map_4400
    loop loop_random_conventional_pages_4400

; TEST 14: test random pages in conventional region via function 17 map/unmap multiple
PRINT_RUNNING_TEST 14



; tables creates.

mov   dx, word ptr cs:[VARIABLE_saved_handle_5]
mov   cx, 8
loop_random_conventional_pages:
    call  page_random_map_1700
    call  test_map_1700
    call  page_random_map_1701
    call  test_map_1701
    loop  loop_random_conventional_pages





; TEST 15: test pages in conventional region via function 15 get/set page map
PRINT_RUNNING_TEST 15

;     FUNCTION 15   GET/SET PAGE MAP

mov  di, OFFSET pagemap_1_func_15
mov  si, di

mov  ax, 04E03h
TEST_EMS_REGISTER_CALL_AH 00h

; use al for anything??

; page in something known - 32 and up for conventional pages. afterwards we will page to 0 and test..
mov   ax, 32
xor   bx, bx
call  init_page_map  
call  test_map_1700

mov  ax, 04E00h
TEST_EMS_REGISTER_CALL_ALL 0000h

; ES:DI gets the contents filled.
call  test_map_1700 ; nothing should have changed.

mov   ax, 0
call  init_page_map   ; remap from 32 to 0 
call  test_map_1700   ; confirm thats good

mov  ax, 04E01h
TEST_EMS_REGISTER_CALL_ALL 0001h  ; restore

mov   ax, 32
mov   bx, 1
call  init_page_map   ; init map state without remapping
call  test_map_1700

mov   ax, 16        ; 2nd set for get/set will be 16 indexed.
xor   bx, bx
call  init_page_map  
call  test_map_1700


mov   di, OFFSET pagemap_2_func_15

mov  ax, 04E02h
TEST_EMS_REGISTER_CALL_ALL 0002h  ; restore

mov   ax, 32
mov   bx, 1
call  init_page_map   ; init map state without remapping
call  test_map_1700

mov   si, di  ; restore to the 16 offset one

mov  ax, 04E01h
TEST_EMS_REGISTER_CALL_ALL 0001h  ; restore

mov   ax, 16
mov   bx, 1
call  init_page_map   ; init map state without remapping
call  test_map_1700


; TEST 16: test pages in conventional region via function 16 get/set partial page map
PRINT_RUNNING_TEST 16


;     FUNCTION 16   GET/SET PARTIAL PAGE MAP

mov  ax, 04F02h  ; get size
mov  bx, 8
TEST_EMS_REGISTER_CALL_NO_AL 00h

; initialize page state, 32 and up
mov   ax, 32
xor   bx, bx
call  init_page_map  
call  test_map_1700

; get partial page map.
mov  si, OFFSET  partial_pagemap_1_func_16_pagemap
mov  di, OFFSET  partial_pagemap_1_func_16_save_area
mov  ax, 04F00h  ; save
TEST_EMS_REGISTER_CALL_ALL 00h

; change pagemap
mov   ax, 0
xor   bx, bx
call  init_page_map  
call  test_map_1700

mov  si, di     ; save area 
mov  ax, 04F01h   ; restore
TEST_EMS_REGISTER_CALL_ALL 01h

; test those pages.
call  test_partial_pagemap  


; TEST 17: test map 28 pagination
PRINT_RUNNING_TEST 17

; init memory...
mov   ax, 32
xor   bx, bx
call  init_page_map  
call  test_map_1700



mov   ax, 05B03h
TEST_EMS_REGISTER_CALL_NO_BX 00003h
test  bx, bx
je    no_alternate_register_sets

push  bx

mov   bl, 0FFh  ; probably dont have 255 sets right?
mov   ax, 05B01h
TEST_EMS_REGISTER_CALL_ALL 09D01h
pop   bx

mov   ax, 05B01h
TEST_EMS_REGISTER_CALL_ALL 00001h ; page back

push  bx


mov   ax, 0  ; change pages in this set..
xor   bx, bx
call  init_page_map  
call  test_map_1700

; change back to original set
xor   bx, bx
mov   es, bx
mov   di, bx
mov   ax, 05B01h
TEST_EMS_REGISTER_CALL_ALL 00001h
push  cs
pop   es



mov   ax, 32
mov   bx, 1
call  init_page_map  
call  test_map_1700



pop   bx

mov   ax, 05B04h
TEST_EMS_REGISTER_CALL_ALL 00004h ; deallocate


mov   ax, 05B04h
TEST_EMS_REGISTER_CALL_ALL 09D04h ; re-deallocate


jmp   continue_register_set_testing
no_alternate_register_sets:




mov   ax, 05B01h
mov   bx, 1
TEST_EMS_REGISTER_CALL_ALL 09C01h

mov   bx, 1
mov   ax, 05B04h
TEST_EMS_REGISTER_CALL_ALL 09C04h

continue_register_set_testing:
mov   di, offset pagemap_1_func_15
mov   si, di

mov  ax, 04E00h
TEST_EMS_REGISTER_CALL_ALL 0000h  ; previous state recorded in the spot

mov   ax, 0
xor   bx, bx
call  init_page_map  
call  test_map_1700  ; switch to 0

; bx 0
mov   ax, 05B01h
TEST_EMS_REGISTER_CALL_ALL 00001h  ; write the values at the pointer. 

; should change back to 32.
mov   ax, 32
mov   bx, 1
call  init_page_map  
call  test_map_1700

mov   ax, 0
xor   bx, bx
call  init_page_map  
call  test_map_1700  ; switch to 0


mov   ax,  05B00h
mov   bx, 1
TEST_EMS_REGISTER_CALL_NO_BX 00000h ; does nothing.

mov   ax, 0
mov   bx, 1
call  init_page_map  
call  test_map_1700


xor   bx, bx
mov   ax, 05B00h
TEST_EMS_REGISTER_CALL_NO_BX 00000h  ; store state

mov   ax, 32
mov   bx, 0
call  init_page_map  
call  test_map_1700


mov  ax, 04E01h
TEST_EMS_REGISTER_CALL_ALL 00001h  ; restore the func 28 state

mov   ax, 0
mov   bx, 1
call  init_page_map  
call  test_map_1700





skip_conventional:

; TEST 18: test handle attribute
PRINT_RUNNING_TEST 18

;     FUNCTION 19   GET/SET HANDLE ATTRIBUTE (CONTINUED)
mov   ax, 05202h  ; get capability
TEST_EMS_REGISTER_CALL_ALL 0000h

mov   ax, 05203h  ; bad call
TEST_EMS_REGISTER_CALL_ALL 08F03h 

; we return unsupported instead of bad handle. Is that wrong? who knows, failure either way
;mov   dx, word ptr cs:[VARIABLE_dead_handle]
;mov   ax, 05201h  ; bad handle
;TEST_EMS_REGISTER_CALL_ALL 08301h 
;mov   ax, 05200h  ; bad handle
;TEST_EMS_REGISTER_CALL_ALL 08300h 

mov   dx, word ptr cs:[VARIABLE_saved_handle_5]

; we return unsupported instead of bad attribute. Is that wrong? who knows, failure either way
;mov   bl, 3   ; bad attribute type
;mov   ax, 05201h  
;TEST_EMS_REGISTER_CALL_ALL 09001h 

mov   bl, 1   ; bad attribute type
mov   ax, 05201h  
TEST_EMS_REGISTER_CALL_ALL 09101h  ; unsupported

mov   bl, 1   ; bad attribute type
mov   ax, 05200h  
TEST_EMS_REGISTER_CALL_ALL 09100h  ; unsupported



; TEST 19: test handle name stuff
PRINT_RUNNING_TEST 19

;     FUNCTION 20   GET/SET HANDLE NAME

mov   dx, word ptr cs:[VARIABLE_saved_handle_1]
mov   si, offset HANDLE_NAME_BLANK
mov   ax, 05301h
mov   di, OFFSET EMPTY_HANDLE_LOCATION
TEST_EMS_REGISTER_CALL_ALL 0A101h  ; ehh not sure. null name?

mov   si, offset HANDLE_NAME_0
mov   ax, 05301h
TEST_EMS_REGISTER_CALL_ALL 00001h  ; good

mov   dx, word ptr cs:[VARIABLE_dead_handle]
mov   ax, 05300h
TEST_EMS_REGISTER_CALL_ALL 08300h  ; bad handle
mov   ax, 05301h
TEST_EMS_REGISTER_CALL_ALL 08301h  ; bad handle

mov   dx, word ptr cs:[VARIABLE_saved_handle_2]
mov   ax, 05301h
TEST_EMS_REGISTER_CALL_ALL 0A101h  ; bad handle
mov   si, offset HANDLE_NAME_1
mov   ax, 05301h
TEST_EMS_REGISTER_CALL_ALL 00001h  ; good

mov   dx, word ptr cs:[VARIABLE_saved_handle_3]
mov   si, offset HANDLE_NAME_2
mov   ax, 05301h
TEST_EMS_REGISTER_CALL_ALL 00001h  ; good

mov   dx, word ptr cs:[VARIABLE_saved_handle_4]
mov   si, offset HANDLE_NAME_3
mov   ax, 05301h
TEST_EMS_REGISTER_CALL_ALL 00001h  ; good


mov   dx, word ptr cs:[VARIABLE_saved_handle_5]
mov   si, offset HANDLE_NAME_4
mov   ax, 05301h
TEST_EMS_REGISTER_CALL_ALL 00001h  ; good


mov   dx, word ptr cs:[VARIABLE_saved_handle_1]
mov   ax, 05300h
TEST_EMS_REGISTER_CALL_ALL 00000h  ; good
mov   si, offset HANDLE_NAME_0
call  compare_handle_name

mov   dx, word ptr cs:[VARIABLE_saved_handle_2]
mov   ax, 05300h
TEST_EMS_REGISTER_CALL_ALL 00000h  ; good
mov   si, offset HANDLE_NAME_1
call  compare_handle_name

mov   dx, word ptr cs:[VARIABLE_saved_handle_3]
mov   ax, 05300h
TEST_EMS_REGISTER_CALL_ALL 00000h  ; good
mov   si, offset HANDLE_NAME_2
call  compare_handle_name

mov   dx, word ptr cs:[VARIABLE_saved_handle_4]
mov   ax, 05300h
TEST_EMS_REGISTER_CALL_ALL 00000h  ; good
mov   si, offset HANDLE_NAME_3
call  compare_handle_name

mov   dx, word ptr cs:[VARIABLE_saved_handle_5]
mov   ax, 05300h
TEST_EMS_REGISTER_CALL_ALL 00000h  ; good
mov   si, offset HANDLE_NAME_4
call  compare_handle_name


;     FUNCTION 21   GET HANDLE DIRECTORY


mov   si, offset HANDLE_NAME_4
mov   ax, 05401h
TEST_EMS_REGISTER_CALL_NO_DX 0001h  ; good
mov   ax, word ptr cs:[VARIABLE_saved_handle_5]
TEST_RESULT_DX  AX  ; handle should equal

mov   si, offset HANDLE_NAME_3
mov   ax, 05401h
TEST_EMS_REGISTER_CALL_NO_DX 0001h  ; good
mov   ax, word ptr cs:[VARIABLE_saved_handle_4]
TEST_RESULT_DX  AX  ; handle should equal


mov   si, offset HANDLE_NAME_2
mov   ax, 05401h
TEST_EMS_REGISTER_CALL_NO_DX 0001h  ; good
mov   ax, word ptr cs:[VARIABLE_saved_handle_3]
TEST_RESULT_DX  AX  ; handle should equal

mov   si, offset HANDLE_NAME_1
mov   ax, 05401h
TEST_EMS_REGISTER_CALL_NO_DX 0001h  ; good
mov   ax, word ptr cs:[VARIABLE_saved_handle_2]
TEST_RESULT_DX  AX  ; handle should equal


mov   si, offset HANDLE_NAME_0
mov   ax, 05401h
TEST_EMS_REGISTER_CALL_NO_DX 0001h  ; good
mov   ax, word ptr cs:[VARIABLE_saved_handle_1]
TEST_RESULT_DX  AX  ; handle should equal

mov   ax, 05403h
TEST_EMS_REGISTER_CALL_ALL 08F03h  ; bad subfunc

mov   ax, 05402h
TEST_EMS_REGISTER_CALL_NO_BX 00002h  ; good

mov   ax, 05400h
mov   di, OFFSET func_21_handle_directory 
TEST_EMS_REGISTER_CALL_NO_AL 000h  

mov   bx, word ptr ds:[VARIABLE_handle_directory_count]
add   bx, 5
TEST_RESULT_BX  AX  ; should be the same

; NOTE: kind of hacky, assumed ordering. correct for sqemm though.

add   di, 12 ; skip OS
mov   si, offset HANDLE_NAME_0
call  compare_handle_name
add   di, 10
mov   si, offset HANDLE_NAME_1
call  compare_handle_name
add   di, 10
mov   si, offset HANDLE_NAME_2
call  compare_handle_name
add   di, 10
mov   si, offset HANDLE_NAME_3
call  compare_handle_name
add   di, 10
mov   si, offset HANDLE_NAME_4
call  compare_handle_name

; TEST 20: test OS features
PRINT_RUNNING_TEST 20
;     FUNCTION 30   ENABLE/DISABLE OS/E FUNCTION SET FUNCTIONS

mov   ax, 05D03h
TEST_EMS_REGISTER_CALL_ALL 08F03h ; bad subfunction

mov   ax, 05D02h
TEST_EMS_REGISTER_CALL_ALL 0A402h


mov   ax, 05D00h
TEST_EMS_REGISTER_CALL_NO_BX_CX 0000h

mov   word ptr ds:[VARIABLE_OS_key+0], BX
mov   word ptr ds:[VARIABLE_OS_key+2], CX

mov   ax, 05D00h
TEST_EMS_REGISTER_CALL_ALL 0000h
mov   ax, 05D01h
TEST_EMS_REGISTER_CALL_ALL 0001h

;     FUNCTION 26   GET EXPANDED MEMORY HARDWARE INFORMATION


;      FUNCTION 28   ALTERNATE MAP REGISTER SET



mov   di, offset func_26_hardware_info
mov   ax, 05900h
TEST_EMS_REGISTER_CALL_ALL 0A400h  ; access denied
mov   ax, 05B02h
TEST_EMS_REGISTER_CALL_ALL 0A402h

mov   ax, 05D00h            ; enable access!
TEST_EMS_REGISTER_CALL_ALL 0000h

push  bx

mov   ax, 05900h
TEST_EMS_REGISTER_CALL_ALL 00000h  ; access enabled
; test anything in es:di? seems unimportant.

mov   ax, 05B02h
TEST_EMS_REGISTER_CALL_NO_DX 00002h

mov   ax, 05B03h
TEST_EMS_REGISTER_CALL_NO_BX 00003h
mov   ax, 05B04h
TEST_EMS_REGISTER_CALL_ALL 00004h


mov   ax, 05B05h
TEST_EMS_REGISTER_CALL_NO_BX 00005h
mov   ax, 05B06h
TEST_EMS_REGISTER_CALL_ALL 00006h
mov   bx, 1
mov   ax, 05B07h
TEST_EMS_REGISTER_CALL_ALL 09E07h

; done with func 28 stuff

pop   bx

inc   bx
mov   ax, 05D00h
TEST_EMS_REGISTER_CALL_ALL 0A400h
mov   ax, 05D01h
TEST_EMS_REGISTER_CALL_ALL 0A401h
mov   ax, 05D02h
TEST_EMS_REGISTER_CALL_ALL 0A402h

dec   bx
inc   cx
mov   ax, 05D00h
TEST_EMS_REGISTER_CALL_ALL 0A400h
mov   ax, 05D01h
TEST_EMS_REGISTER_CALL_ALL 0A401h
mov   ax, 05D02h
TEST_EMS_REGISTER_CALL_ALL 0A402h

dec   cx ; key good again


mov   ax, 05D00h
TEST_EMS_REGISTER_CALL_ALL 0000h
mov   ax, 05D01h
TEST_EMS_REGISTER_CALL_ALL 0001h
mov   ax, 05900h
TEST_EMS_REGISTER_CALL_ALL 0A400h
mov   ax, 05B02h
TEST_EMS_REGISTER_CALL_ALL 0A402h



mov   ax, 05D02h
TEST_EMS_REGISTER_CALL_ALL 0002h

mov   ax, 05D01h
TEST_EMS_REGISTER_CALL_NO_BX_CX 0001h ; get new key

mov   ax, 05D00h
TEST_EMS_REGISTER_CALL_ALL 0000h  ; enable access.




mov   ax, 05D02h
TEST_EMS_REGISTER_CALL_ALL 0002h ; release key again







; TEST 21: test -1 paging/unpaging
PRINT_RUNNING_TEST 21



; TEST 22: test function 22 alter and jump
PRINT_RUNNING_TEST 22

;     FUNCTION 22   ALTER PAGE MAP & JUMP




mov   si, OFFSET func_22_struct_1
mov   word ptr ds:[si], offset func_22_function_1
mov   byte ptr ds:[si+4], 8
mov   word ptr ds:[si+5], offset func_22_phys_struct_1
mov   word ptr ds:[si+2], cs
mov   word ptr ds:[si+7], cs

mov   ax, 05502h
TEST_EMS_REGISTER_CALL_ALL 08F02h

mov   dx, word ptr ds:[VARIABLE_dead_handle]
mov   ax, 05500h
TEST_EMS_REGISTER_CALL_ALL 08300h
mov   ax, 05501h
TEST_EMS_REGISTER_CALL_ALL 08301h

mov   dx, word ptr ds:[VARIABLE_saved_handle_5]


mov   ax, 05500h ; 0 = physical page numbers...
TEST_EMS_REGISTER_CALL_ALL 00000h

done_with_function_1:           ; i guess we didnt test anything...? so call in
call do_test_only_func_22

; change pages out.
mov   ax, 10
xor   bx, bx
call  init_page_map   ; init map state without remapping
call  test_map_1700


mov   word ptr ds:[si], offset func_22_function_2
mov   byte ptr ds:[si+4], 0


mov   ax, 05500h ; 0 = physical page numbers...
TEST_EMS_REGISTER_CALL_ALL 00000h
done_with_function_2:
call do_test_only_func_22

mov   byte ptr ds:[si+4], 4
mov   word ptr ds:[si+5], offset func_22_phys_struct_2
mov   word ptr ds:[si], offset func_22_function_3


mov   ax, 05501h ; 1 = segment page numbers...
TEST_EMS_REGISTER_CALL_ALL 00001h

done_with_function_3:
call do_test_only_func_22







; TEST 23: test function 23 alter and call
PRINT_RUNNING_TEST 23
;     FUNCTION 23   ALTER PAGE MAP & CALL

; do tests similar to 22, but selfmodify returns into the functions.

RET_OPCODE = 0C3h
RET_FAR_OPCODE = 0CBh
mov   word ptr ds:[func_22_modify_offset], RET_FAR_OPCODE
mov   word ptr ds:[func_22_modify_offset_2], RET_FAR_OPCODE

mov   si, OFFSET func_22_struct_1
mov   word ptr ds:[si], offset func_22_function_1
mov   byte ptr ds:[si+4], 8
mov   word ptr ds:[si+5], offset func_22_phys_struct_1
mov   word ptr ds:[si+2], cs
mov   word ptr ds:[si+7], cs
mov   byte ptr ds:[si+9], 0
mov   word ptr ds:[si+10], offset func_22_phys_struct_1
mov   word ptr ds:[si+12], cs
mov   word ptr ds:[si+14], 0
mov   word ptr ds:[si+16], 0





mov   ax, 05603h
TEST_EMS_REGISTER_CALL_ALL 08F03h

mov   dx, word ptr ds:[VARIABLE_dead_handle]
mov   ax, 05600h
TEST_EMS_REGISTER_CALL_ALL 08300h
mov   ax, 05601h
TEST_EMS_REGISTER_CALL_ALL 08301h


mov   dx, word ptr ds:[VARIABLE_saved_handle_5]

mov   ax, 05600h ; 0 = physical page numbers...
TEST_EMS_REGISTER_CALL_ALL 00000h




; change pages out.
mov   ax, 10
xor   bx, bx
call  init_page_map   ; init map state without remapping
call  test_map_1700

mov  di, OFFSET func_22_phys_struct_3
mov   byte ptr ds:[si+9], 28
mov   word ptr ds:[si+10], offset func_22_phys_struct_3



mov   word ptr ds:[si], offset func_22_function_2
mov   byte ptr ds:[si+4], 0


mov   ax, 05600h ; 0 = physical page numbers...
TEST_EMS_REGISTER_CALL_ALL 00000h

; should be restored
mov   ax, 10
mov   bx, 1 ; dont remap
call  init_page_map   ; init map state without remapping
call  test_map_1700  



; store old pages for restore.


mov   byte ptr ds:[si+4], 4
mov   word ptr ds:[si+5], offset func_22_phys_struct_2
mov   word ptr ds:[si], offset func_22_function_3



mov   ax, 05601h ; 1 = segment page numbers...
TEST_EMS_REGISTER_CALL_ALL 00001h






; TEST 24: test function 24 move
PRINT_RUNNING_TEST 24
;     FUNCTION 24   MOVE/EXCHANGE MEMORY REGION

; test 



mov   si, OFFSET func_24_struct



COMMENT @
          move_source_dest_struct      STRUC
             region_length             DD  ?
             source_memory_type        DB  ?
             source_handle             DW  ?
             source_initial_offset     DW  ?
             source_initial_seg_page   DW  ?
             dest_memory_type          DB  ?
             dest_handle               DW  ?
             dest_initial_offset       DW  ?
             dest_initial_seg_page     DW  ?
          move_source_dest_struct      ENDS
@

; reset memory.

mov   dx, word ptr ds:[VARIABLE_saved_handle_5]

mov   ax, 32
xor   bx, bx
call  init_page_map   ; init map state without remapping
call  test_map_1700


mov   word ptr ds:[si+0], 0  ; length
mov   word ptr ds:[si+2], 1  ; 65536
mov   byte ptr ds:[si+4], 0  ; source type (conventional)
mov   byte ptr ds:[si+5], dl  ; source handle
mov   word ptr ds:[si+7], 0   ; source offset
mov   word ptr ds:[si+9], 04000h   ; source segment
mov   word ptr ds:[si+11], 0   ; dest type (conventional)
mov   byte ptr ds:[si+12], dl  ; dest handle
mov   word ptr ds:[si+14], 0   ; dest offset
mov   word ptr ds:[si+16], 02800h   ; dest segment

mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 00000h ; test conventional copy


mov   ax, 32
mov   dx, 02800h
call  test_four_pages_from_segment_dx


mov   word ptr ds:[si+0], 16385  ; extra length
mov   byte ptr ds:[si+4], 1  ; source type (extended)
mov   word ptr ds:[si+9], 36   ; source segment
mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 00000h; test larger extended to conventional copy



mov   ax, 36
mov   dx, 02800h
call  test_four_pages_from_segment_dx
mov   ax, 40
mov   dx, 03800h
push  es

mov   es, dx
call  test_page_with_ax

mov   ax, 41
cwd
mov   dl, byte ptr es:[04000h]

TEST_RESULT_DX AX

pop   es

; reallocate!


mov   dx, word ptr ds:[VARIABLE_saved_handle_5]
mov   bx, 128  ; 2MB allocation
mov   ax, 0510Dh
TEST_EMS_REGISTER_CALL_NO_BX 000Dh


mov   word ptr ds:[si+0], 0  ; extra length
mov   word ptr ds:[si+2], 16  ; 1 MB copy
mov   byte ptr ds:[si+11], 1   ; dest type (extended)
mov   word ptr ds:[si+9], 0   ; source segment
mov   word ptr ds:[si+16], 64   ; dest segment

mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 00000h; test larger extended to conventional copy


mov   dx, word ptr ds:[VARIABLE_saved_handle_5]
mov   ax, 64
xor   bx, bx
call  init_page_map   ; init map state without remapping

mov   ax, 0
mov   dx, 04000h
call  test_four_pages_from_segment_dx
mov   ax, 4
mov   dx, 05000h
call  test_four_pages_from_segment_dx

mov   dx, word ptr ds:[VARIABLE_saved_handle_5]
mov   ax, 96
xor   bx, bx
call  init_page_map   ; init map state without remapping

mov   ax, 32
mov   dx, 04000h
call  test_four_pages_from_segment_dx
mov   ax, 36
mov   dx, 05000h
call  test_four_pages_from_segment_dx

mov   dx, word ptr ds:[VARIABLE_saved_handle_5]
mov   ax, 0
xor   bx, bx
call  init_page_map   ; init map state without remapping
call  test_map_1700



; convetional to extended
mov   word ptr ds:[si+2], 1  ; 64kb copy
mov   byte ptr ds:[si+4], 0  ; source type (conventional)
mov   word ptr ds:[si+9], 02800h   ; source segment  ; should be 04000h
mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 00000h; test larger extended to conventional copy

mov   ax, 64
xor   bx, bx
call  init_page_map   ; init map state without remapping


mov   ax, 36
mov   dx, 04000h
call  test_four_pages_from_segment_dx

mov   word ptr ds:[si+2], 17  ; > 1MB copy
mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 09600h; too big

mov   word ptr ds:[si+2], 1  ; 64kb copy
mov   byte ptr ds:[si+4], 2  ; source type (bad)
mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 09800h; bad type

mov   byte ptr ds:[si+4], 0  ; source type (conventional)
mov   word ptr ds:[si+16], 127   ; dest segment
mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 09300h; out of logical range


mov   word ptr ds:[si+16], 64   ; dest segment
mov   ax, 05700h ; 0 = copy
mov   word ptr ds:[si+14], 16384   ; dest offset
TEST_EMS_REGISTER_CALL_ALL 09500h; bad extended offset

mov   byte ptr ds:[si+11], 0   ; dest type (conventiona;)
mov   word ptr ds:[si+16], 02400h   ; dest segment
mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 09200h; successful but overlap 



; test overlaps

mov   word ptr ds:[si+0],  64  ; 64byte copy
mov   word ptr ds:[si+2],  0  
mov   byte ptr ds:[si+11], 0   ; dest type (conventiona;)
mov   byte ptr ds:[si+4],  0  ; source type (conventional)
mov   word ptr ds:[si+16], 02800h   ; dest segment
mov   word ptr ds:[si+9],  02800h   ; source segment
mov   word ptr ds:[si+14], 1   ; dest offset
mov   word ptr ds:[si+7],  0   ; source offset

mov   ax, 02800h
mov   es, ax
call  write_64_bytes_increasing

mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 09200h; successful but overlap

mov   di, 1
call  test_64_bytes_increasing

mov   word ptr ds:[si+14], 0   ; dest offset
mov   word ptr ds:[si+7], 1   ; source offset
mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 09200h; successful but overlap

dec   di ; 0 
call  test_64_bytes_increasing

; now extended. map same page to 4000 and page frame.
mov   byte ptr ds:[si+11], 1   ; dest type (extended;)
mov   byte ptr ds:[si+4], 1  ; source type (extended)

mov   dx, word ptr ds:[VARIABLE_saved_handle_5]
mov   ax, 64
xor   bx, bx
call  init_page_map


mov   word ptr ds:[si+14], 1   ; dest offset
mov   word ptr ds:[si+7],  1   ; source offset
mov   word ptr ds:[si+16], 64   ; dest segment
mov   word ptr ds:[si+9],  64   ; source segment
mov   word ptr ds:[si+14], 03FE1h   ; dest offset
mov   word ptr ds:[si+7],  03FE0h   ; source offset

; write from page 64 to page 65.  This requires extended backwards pagination

mov   ax, 043FEh
mov   es, ax
mov   di, 1
call  write_64_bytes_increasing

mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 09200h; successful but overlap

mov   di, 1
call  test_64_bytes_increasing

mov   word ptr ds:[si+14], 03FE0h   ; dest offset
mov   word ptr ds:[si+7],  03FE1h   ; source offset
mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 09200h; successful but overlap

dec   di ; 0 
call  test_64_bytes_increasing


; test exchanges

mov   word ptr ds:[si+0],  64  ; 64byte copy
mov   word ptr ds:[si+2],  0  
mov   byte ptr ds:[si+11], 0   ; dest type (conventiona;)
mov   byte ptr ds:[si+4],  0  ; source type (conventional)
mov   word ptr ds:[si+16], 02800h   ; dest segment
mov   word ptr ds:[si+9],  02800h   ; source segment
mov   word ptr ds:[si+14], 1   ; dest offset
mov   word ptr ds:[si+7],  0   ; source offset

mov   ax, 02800h
mov   es, ax
call  write_64_bytes_increasing

mov   ax, 05701h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 09701h; successful but overlap

mov   word ptr ds:[si+14], 040h   ; dest offset
mov   ax, 05701h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 00001h; successful 

mov   di, 040h
call  test_64_bytes_increasing

mov   ax, 05701h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 00001h; successful 

xor   di, di
call  test_64_bytes_increasing

mov   byte ptr ds:[si+11], 1   ; dest type (extended;)
mov   word ptr ds:[si+16], 64   ; dest segment
mov   word ptr ds:[si+14], 03FE0h   ; dest offset

mov   ax, 05701h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 00001h; successful 

mov   ax, 043FEh
mov   es, ax
xor   di, di
call  test_64_bytes_increasing

mov   ax, 05701h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 00001h; successful 
mov   ax, 02800h
mov   es, ax
xor   di, di
call  test_64_bytes_increasing


; todo test xchg extended to extended?
; todo test for 94h (overlap conventional + extended)







push  cs
push  cs
pop   ds
pop   es




; TEST 25: Test unmap/-1 pages
PRINT_RUNNING_TEST 25

; page to some garbage
mov   dx, word ptr ds:[VARIABLE_saved_handle_5]
mov   ax, CONVENTIONAL_COPY_PAGE+1
xor   bx, bx
call  init_page_map   ; init map state without remapping


; copy conventional unmapped to ems. page around. unmap again. confirm equality

;     FUNCTION 29   PREPARE EXPANDED MEMORY HARDWARE FOR WARM BOOT
mov   ax, 05C23h
TEST_EMS_REGISTER_CALL_ALL 00023h  ; prepare for warm boot

CONVENTIONAL_COPY_PAGE = 16


mov   word ptr ds:[si+0], 0  ; length
mov   word ptr ds:[si+2], 6  ; 384k
mov   byte ptr ds:[si+4], 0  ; source type (conventional)
mov   word ptr ds:[si+7], 0   ; source offset
mov   word ptr ds:[si+9], 04000h   ; source segment  ; 4000-A000
mov   word ptr ds:[si+11], 1   ; dest type (extended)
mov   byte ptr ds:[si+12], dl  ; dest handle
mov   word ptr ds:[si+14], 0   ; dest offset
mov   word ptr ds:[si+16], CONVENTIONAL_COPY_PAGE   ; dest segment
mov   ax, 05700h ; 0 = copy
TEST_EMS_REGISTER_CALL_ALL 00000h ; copy conventional out

call  check_conventional_copy

mov  ax, 04E00h
TEST_EMS_REGISTER_CALL_ALL 0000h  ; store -1 pages


mov   ax, CONVENTIONAL_COPY_PAGE+1
xor   bx, bx
call  init_page_map   ; garbage pages

mov   ax, 05C23h
TEST_EMS_REGISTER_CALL_ALL 00023h  ; unmap

call  check_conventional_copy ; check

mov   ax, CONVENTIONAL_COPY_PAGE+1
xor   bx, bx
call  init_page_map   ; garbage pages


; set up conventional pages

mov   si, OFFSET map_1700_page_list_full
mov   di, si

; init page map to -1 again..
mov   ax, -1
mov   cx, word ptr ds:[VARIABLE_page_count]
push  cx
loop_unmap_next_page:
    stosw
    add  di, 2
    loop loop_unmap_next_page

pop  cx
mov   ax, 05000h 
TEST_EMS_REGISTER_CALL_ALL 0000h ; unmap those pages via func 17...

call  check_conventional_copy ; check


; deallocate 

; TEST 30: Deallocation
PRINT_RUNNING_TEST 30

mov   dx, word ptr ds:[VARIABLE_saved_handle_1]
mov   ax, 04510h

TEST_EMS_REGISTER_CALL_ALL 0010h
mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
mov   ax, 04510h
TEST_EMS_REGISTER_CALL_ALL 0010h
mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
mov   ax, 04510h
TEST_EMS_REGISTER_CALL_ALL 0010h
mov   dx, word ptr ds:[VARIABLE_saved_handle_4]
mov   ax, 04510h
TEST_EMS_REGISTER_CALL_ALL 0010h
mov   dx, word ptr ds:[VARIABLE_saved_handle_5]

mov   ax, 04510h
TEST_EMS_REGISTER_CALL_ALL 08610h  ; cant delete handle with stack context..

mov   ax, 04823h
TEST_EMS_REGISTER_CALL_ALL 00023h  ; clean context up...

mov   ax, 04510h
TEST_EMS_REGISTER_CALL_ALL 0010h




; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END



; print results
; print results

    std

    mov  di, OFFSET string_ran_tests_decimal_1+3
    mov  cx, 10
    mov  ax, word ptr ds:[VARIABLE_test_count]
    cwd
    call print_four_digits

    mov  ax, word ptr ds:[VARIABLE_error_count]
    cwd
    mov  di, OFFSET string_ran_tests_decimal_2+3
    cwd
    call print_four_digits

    cld


    PRINT_STRING  string_ran_tests





quit_exit_program: ;  detect stack mismatch? probably fine if we made it here
mov   sp, word ptr cs:[VARIABLE_exit_sp]


pop   es
pop   ds

; EXIT PROGRAM

POPA_MACRO
mov   ax, 04C00h
int   021h






;; ACCESSORY FUNCTIONS START
;; ACCESSORY FUNCTIONS START
;; ACCESSORY FUNCTIONS START
;; ACCESSORY FUNCTIONS START
;; ACCESSORY FUNCTIONS START
;; ACCESSORY FUNCTIONS START








show_running_test:
    PUSHA_MACRO
    std
    mov   ax, word ptr ds:[_test_num]
    cwd
    mov   cx, 10
    mov   di, OFFSET test_num_offset + 3

    call print_three_digits


    PRINT_STRING string_running_test

    cld

    POPA_MACRO
    ret




COMMENT @
show_success:

    push  ax
    push  dx
    PRINT_STRING string_success

    pop   dx
    pop   ax
    ret

@


print_hex_word_bx:
    mov  al, bl
    and  al, 0Fh
    cmp  al, 0Ah
    jb   $+4
    add  al, 'A' - '0' - 10
    ; jmp here    
    add  al, '0'
    mov  byte ptr ds:[si+3], al

    mov  al, bl
    shr  al, 1
    shr  al, 1
    shr  al, 1
    shr  al, 1
    cmp  al, 0Ah
    jb   $+4
    add  al, 'A' - '0' - 10
    ; jmp here    
    add  al, '0'
    mov  byte ptr ds:[si+2], al
; fall thru
print_hex_byte_bx:

    mov  al, bh
    and  al, 0Fh
    cmp  al, 0Ah
    jb   $+4
    add  al, 'A' - '0' - 10
    ; jmp here    
    add  al, '0'
    mov  byte ptr ds:[si+1], al

    mov  al, bh
    shr  al, 1
    shr  al, 1
    shr  al, 1
    shr  al, 1
    cmp  al, 0Ah
    jb   $+4
    add  al, 'A' - '0' - 10
    ; jmp here    
    add  al, '0'
    mov  byte ptr ds:[si+0], al

    ret
COMMENT @
print_handle:
    push bx
    push ax
    push dx
    push si
    mov  bh, dl
    mov  si, OFFSET string_hex_handle_offset
    call print_hex_byte_bx

    PRINT_STRING string_hex_handle

    pop  si
    pop  dx
    pop  ax
    pop  bx
    ret
    @

div_digit:
    div   cx
    xchg  ax, dx
    add   ax, '0'
    stosb
    xchg  ax, dx
    cwd
    ret

print_four_digits:
    call div_digit
print_three_digits:
    call div_digit
print_two_digits:
    call div_digit
    call div_digit
    ret

print_page_count:
    PUSHA_MACRO

    std

    mov  di, OFFSET string_page_count_decimal_unallocated+3
    mov  cx, 10
    mov  ax, bx
    mov  si, dx ; store
    cwd

    call print_four_digits

    mov  ax, si  ; previously stored for division
    mov  di, OFFSET string_page_count_decimal_total+3
    cwd
    
    call print_four_digits


    PRINT_STRING  string_page_count_decimal


    cld

    POPA_MACRO
    ret    





print_hex_register:
    PUSHA_MACRO
    
    mov  si, OFFSET string_register_value_offset

    call  print_hex_word_bx 

    mov  si, OFFSET string_expected_value_offset
    mov  bx, word ptr ds:[expected_value]
    call  print_hex_word_bx 


    PRINT_STRING string_register_name
    
    POPA_MACRO

    ret



prompt_for_key:

inc  word ptr ds:[VARIABLE_error_count]

push dx
PRINT_STRING string_paused
pop  dx
xor  ax, ax
int  016h
ret

fill_in_page_with_ax:

    push  di
    push  cx
    xor   di, di
    mov   cx, 16384 / 2
    rep   stosw
    pop   cx
    pop   di
    ret

fill_in_four_pages_increment_ax:

    push  es
    mov   es, word ptr ds:[VARIABLE_page_frame+2]
    call  fill_in_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+6]
    call  fill_in_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+10]
    call  fill_in_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+14]
    call  fill_in_page_with_ax
    inc   ax
    pop   es
    ret

page_in_four_pages_starting_at_ax:
    push  ax
    xor   bx, bx
    mov   bl, al
    mov   ax, 04400h
    TEST_EMS_REGISTER_CALL_ALL 0000h
    
    mov   ax, 04401h
    inc   bx
    TEST_EMS_REGISTER_CALL_ALL 0001h

    mov   ax, 04402h
    inc   bx
    TEST_EMS_REGISTER_CALL_ALL 0002h

    mov   ax, 04403h
    inc   bx
    TEST_EMS_REGISTER_CALL_ALL 0003h

    pop   ax
    ret

fill_in_64_pages:

    push  cx
    push  ax
    xor   ax, ax
    mov   cx, 16

    loop_fill_in_next_four:
    call  page_in_four_pages_starting_at_ax

    call  fill_in_four_pages_increment_ax

    loop  loop_fill_in_next_four

    pop   ax
    pop   cx
    ret

test_four_pages_from_segment_dx:

    push  es
    push  dx
    mov   es, dx
    call  test_page_with_ax
    inc   ax
    add   dh, 4
    mov   es, dx
    call  test_page_with_ax
    inc   ax
    add   dh, 4
    mov   es, dx
    call  test_page_with_ax
    inc   ax
    add   dh, 4
    mov   es, dx
    call  test_page_with_ax
    inc   ax
    pop   dx
    pop   es
    ret



test_page_with_ax:
public  test_page_with_ax

    PUSHA_MACRO
    xor   di, di
    mov   cx, 16384 / 2
    repe  scasw
    jne   print_test_error
    ;mov   si, OFFSET scan_test_success_offset
    ;mov   bx, ax
    ;call  print_hex_word_bx 
    ;mov   si, OFFSET scan_test_success_segment
    ;mov   bx, es
    ;call  print_hex_word_bx 
    ;PRINT_STRING scan_test_success
    return_test_page:
    POPA_MACRO
    ret

    print_test_error:

    mov  si, OFFSET scan_test_error_offset
    call  print_hex_word_bx 
    mov   si, OFFSET scan_test_error_segment
    mov   bx, es
    call  print_hex_word_bx 

    PRINT_STRING scan_test_error

    call  prompt_for_key

    jmp   return_test_page

test_four_pages:

    push  es
    mov   es, word ptr ds:[VARIABLE_page_frame+2]
    call  test_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+6]
    call  test_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+10]
    call  test_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+14]
    call  test_page_with_ax
    inc   ax
    pop   es
    ret


test_64_pages_in_reverse:
public test_64_pages_in_reverse

    push  cx
    push  ax
    mov   ax, 60
    mov   cx, 16

    loop_scan_next_four:
    call  page_in_four_pages_starting_at_ax

    call  test_four_pages
    sub   ax, 8

    loop  loop_scan_next_four

    pop   ax
    pop   cx
    ret








test_random_four_5701:
public  test_random_four_5701

    push   cx
    push   di
    mov    di, offset  map_1701_page_list_four
    mov    cx, 4

    loop_set_random_page:
        call   get_random_in_ax
        ; modulo 64... 
        add    ax, cx
        and    ax, 63
        stosw
        inc    di
        inc    di
        loop loop_set_random_page

    pop    di
    push   si

    mov   cx, 4
    mov   dx, word ptr ds:[VARIABLE_saved_handle_5]
    mov   si, OFFSET map_1701_page_list_four
    mov   ax, 05001h

    TEST_EMS_REGISTER_CALL_ALL 0001h


    push  es
    les   ax, dword ptr ds:[map_1701_page_list_four+0] ; es gets eg, ax gets value...
    call  test_page_with_ax
    les   ax, dword ptr ds:[map_1701_page_list_four+4]
    call  test_page_with_ax
    les   ax, dword ptr ds:[map_1701_page_list_four+8]
    call  test_page_with_ax
    les   ax, dword ptr ds:[map_1701_page_list_four+12]
    call  test_page_with_ax
    pop   es


    pop   si
    pop   cx
    ret


get_random_in_ax:
     push  cx
     push  dx
     xor   ax, ax
     int   01Ah  ; read system clock counter
         
     mov   ax, 30817 ; big prime
     mul   dx
     add   ax, 11177
     pop   dx
     pop   cx
     ret

test_random_four_5700:
public  test_random_four_5700

    push   cx
    push   di
    mov    di, offset  map_1700_page_list_four

    mov    cx, 4
public map_1700_page_list_four
    loop_set_random_page_5700:
        call   get_random_in_ax
        ; modulo 64... 
        add    ax, cx
        and    ax, 63
        stosw
        inc    di
        inc    di
        loop loop_set_random_page_5700

    pop    di
    push   si

    mov   cx, 4
    mov   dx, word ptr ds:[VARIABLE_saved_handle_5]

    mov   si, OFFSET map_1700_page_list_four
    mov   ax, 05000h
    TEST_EMS_REGISTER_CALL_ALL 0000h



    push  es
    mov   ax, word ptr ds:[map_1700_page_list_four+0]
    mov   es, word ptr ds:[VARIABLE_page_frame+2]
    call  test_page_with_ax
    mov   ax, word ptr ds:[map_1700_page_list_four+4]
    mov   es, word ptr ds:[VARIABLE_page_frame+6]
    call  test_page_with_ax
    mov   ax, word ptr ds:[map_1700_page_list_four+8]
    mov   es, word ptr ds:[VARIABLE_page_frame+10]
    call  test_page_with_ax
    mov   ax, word ptr ds:[map_1700_page_list_four+12]
    mov   es, word ptr ds:[VARIABLE_page_frame+14]
    call  test_page_with_ax
    pop   es


    pop   si
    pop   cx
    ret


page_random_map_4400:
public page_random_map_4400
    push  es
    PUSHA_MACRO
    mov   cx, word ptr ds:[VARIABLE_page_count]

    mov   di, OFFSET  map_1701_page_list_full - map_1700_page_list_full - 2
    mov   si, OFFSET  map_1700_page_list_full + 2


    pagemap_loop_next_page_4400:
        ; page in random page map, then test them all
        call   get_random_in_ax
        ; modulo 64... 
        add    ax, cx
        and    ax, 63
        xchg   ax, bx  ; logical page

        lodsw          ; physical page
        push  ax
        add   si, di
        lodsw          ; segment
        mov   es, ax
        sub   si, di
        pop   ax
        mov    ah, 044h

        TEST_EMS_REGISTER_CALL_AH 00

        mov    ax, bx
        call   test_page_with_ax  ; test as we go.

        loop pagemap_loop_next_page_4400


    POPA_MACRO
    pop   es
    ret

; init page map with logical page starting at ax
; bx != 0 means dont actually page
init_page_map:
    push  cx
    push  di
    push  si
    mov   cx, word ptr ds:[VARIABLE_page_count]
    mov   di, OFFSET map_1700_page_list_full
    push   cx
    ; generate random page map
    pagemap_loop_next_page_initmap:
        ; page in random page map, then test them all
        stosw
        inc    di
        inc    di
        inc    ax

        loop pagemap_loop_next_page_initmap

    pop   cx  ; cx is page count again
    test  bx, bx   
    jne   skip_init_page_map_pagination   ; just set the vars for testing, do not actually page
    mov   si, OFFSET map_1700_page_list_full
    mov   ax, 05000h
    TEST_EMS_REGISTER_CALL_ALL 0000h
    skip_init_page_map_pagination:

    pop   si
    pop   di
    pop   cx
    ret    


; this only tests the partial map
test_partial_pagemap:
public test_partial_pagemap

    push  cx
    push  es
    push  bx
    push  ax
    push  si
    push  di

    xchg  ax, di  ; test base
    mov   si, offset partial_pagemap_1_func_16_pagemap
    mov   bx, offset partial_pagemap_1_values - partial_pagemap_1_func_16_pagemap  - 4
    lodsw
    xchg  ax, cx

    loop_next_partialpagemap:
        lodsw
        mov   es, ax
        mov   ax, word ptr ds:[bx+si]
        call  test_page_with_ax

        loop  loop_next_partialpagemap


    pop  di
    pop  si
    pop  ax
    pop  bx
    pop  es
    pop  cx
    ret


page_random_map_1700:
public page_random_map_1700
    push  cx
    push  di
    push  si
    mov   cx, word ptr ds:[VARIABLE_page_count]
    mov   di, OFFSET map_1700_page_list_full
    push   cx
    ; generate random page map
    pagemap_loop_next_page_1700:
        ; page in random page map, then test them all
        call   get_random_in_ax
        ; modulo 64... 
        add    ax, cx
        and    ax, 63
        stosw
        inc    di
        inc    di

        loop pagemap_loop_next_page_1700

    pop   cx  ; cx is page count again
    mov   si, OFFSET map_1700_page_list_full
    mov   ax, 05000h
    TEST_EMS_REGISTER_CALL_ALL 0000h



    pop   si
    pop   di
    pop   cx
    ret



page_random_map_1701:
    push  cx
    push  di
    push  si
    mov   cx, word ptr ds:[VARIABLE_page_count]
    mov   di, OFFSET map_1701_page_list_full
    push   cx
    ; generate random page map
    pagemap_loop_next_page_1701:
        ; page in random page map, then test them all
        call   get_random_in_ax
        ; modulo 64... 
        add    ax, cx
        and    ax, 63
        stosw
        inc    di
        inc    di

        loop pagemap_loop_next_page_1701

    pop   cx  ; cx is page count again
    mov   ax, 05001h
    mov   si, OFFSET map_1701_page_list_full
    TEST_EMS_REGISTER_CALL_ALL 0001h




    pop   si
    pop   di
    pop   cx
    ret

test_map_1700:
public test_map_1700
    push  cx
    push  es
    push  si
    push  di
    mov   di, OFFSET  map_1701_page_list_full - map_1700_page_list_full
    mov   si, OFFSET  map_1700_page_list_full
    do_1701_tests:
    mov   cx, word ptr ds:[VARIABLE_page_count]
    loop_test_next_page_1700:
        lodsw 
        push  ax
        add   si, di
        lodsw 
        mov   es, ax
        sub   si, di
        pop   ax
        call  test_page_with_ax
        loop  loop_test_next_page_1700

    pop  di
    pop  si
    pop  es
    pop  cx
    ret

test_map_1701:
    push  cx
    push  es
    push  si
    mov   si, OFFSET  map_1701_page_list_full
    mov   cx, word ptr ds:[VARIABLE_page_count]
    loop_test_next_page_1701:
        lodsw 
        push ax
        lodsw 
        mov   es, ax
        pop  ax
        call  test_page_with_ax
        loop  loop_test_next_page_1701

    pop  si
    pop  es
    pop  cx
    ret


MACRO_PRINT_BAD_REGISTER MACRO reg, expectedvalueloc
    push  bx
    mov   bx, word ptr ds:[ &expectedvalueloc ]
    mov   word ptr ds:[expected_value], bx
    mov   bx, reg
    call  print_bad_reg_error
    pop   bx
ENDM


    bad_register_ax:
        mov  word ptr ds:[string_register_name_offset], "XA" ; endian
        print_ah:  ; a little weird ok.
        MACRO_PRINT_BAD_REGISTER ax VARIABLE_expected_register_ax
        jmp  continue_after_ax

    do_ah_test:
        cmp  byte ptr ds:[VARIABLE_expected_register_ax+1], ah
        je   continue_after_ax
        mov  word ptr ds:[string_register_name_offset], "HA" ; endian
        jmp  print_ah

    bad_register_dx:
        mov  word ptr ds:[string_register_name_offset], "XD" ; endian
        MACRO_PRINT_BAD_REGISTER dx VARIABLE_expected_register_dx
        jmp  continue_after_dx
    
    bad_register_cx:
        mov  word ptr ds:[string_register_name_offset], "XC" ; endian
        MACRO_PRINT_BAD_REGISTER cx VARIABLE_expected_register_cx
        jmp  continue_after_cx


do_ems_call_and_register_test:

    mov  word ptr ds:[VARIABLE_expected_register_bx], bx
    entry_after_bx:

    mov  word ptr ds:[VARIABLE_expected_register_dx], dx
    entry_after_dx:
    mov  word ptr ds:[VARIABLE_expected_register_cx], cx
    entry_after_cx:
    mov  word ptr ds:[VARIABLE_expected_register_si], si
    mov  word ptr ds:[VARIABLE_expected_register_di], di
    mov  word ptr ds:[VARIABLE_expected_register_bp], bp
    inc  word ptr ds:[VARIABLE_test_count]

    int 067h
    do_test_only_func_22:
    cmp  byte ptr ds:[VARIABLE_skip_al], 0
    jne  do_ah_test
    cmp  word ptr ds:[VARIABLE_expected_register_ax], ax
    jne  bad_register_ax
    continue_after_ax:
    public continue_after_ax
    cmp  byte ptr ds:[VARIABLE_skip_dx], 0
    jne  continue_after_dx
    cmp  word ptr ds:[VARIABLE_expected_register_dx], dx
    jne  bad_register_dx
    continue_after_dx:
    cmp  byte ptr ds:[VARIABLE_skip_cx], 0
    jne  continue_after_cx
    cmp  word ptr ds:[VARIABLE_expected_register_cx], cx
    jne  bad_register_cx
    continue_after_cx:
    cmp  byte ptr ds:[VARIABLE_skip_bx], 0
    jne  continue_after_bx
    cmp  word ptr ds:[VARIABLE_expected_register_bx], bx
    jne  bad_register_bx
    continue_after_bx:
    cmp  word ptr ds:[VARIABLE_expected_register_si], si
    jne  bad_register_si
    continue_after_si:
    cmp  byte ptr ds:[VARIABLE_skip_di], 0
    jne  continue_after_di
    cmp  word ptr ds:[VARIABLE_expected_register_di], di
    jne  bad_register_di
    continue_after_di:
    cmp  word ptr ds:[VARIABLE_expected_register_bp], bp
    jne  bad_register_bp
    continue_after_bp:

    mov  word ptr ds:[VARIABLE_skip_bx], 0
    ;mov  byte ptr ds:[VARIABLE_skip_dx], 0
    mov  word ptr ds:[VARIABLE_skip_cx], 0


    ret



        bad_register_bx:
        mov  word ptr ds:[string_register_name_offset], "XB" ; endian
        MACRO_PRINT_BAD_REGISTER bx VARIABLE_expected_register_bx
        jmp  continue_after_bx

    
    bad_register_si:
        mov  word ptr ds:[string_register_name_offset], "IS" ; endian
        MACRO_PRINT_BAD_REGISTER si VARIABLE_expected_register_si
        jmp  continue_after_si

    bad_register_di:
        mov  word ptr ds:[string_register_name_offset], "ID" ; endian
        MACRO_PRINT_BAD_REGISTER di VARIABLE_expected_register_di
        jmp  continue_after_di
    
    bad_register_bp:
        mov  word ptr ds:[string_register_name_offset], "PB" ; endian
        MACRO_PRINT_BAD_REGISTER bp VARIABLE_expected_register_bp
        jmp  continue_after_bp

print_bad_reg_error:
        push bx

        call print_hex_register
        call prompt_for_key
        dont_print_error:
        pop  bx
        ret

do_ems_call_and_register_test_no_dx:
    mov  byte ptr ds:[VARIABLE_skip_dx], ah ; nonzero
    jmp do_ems_call_and_register_test

do_ems_call_and_register_test_no_bx_cx:
    mov  byte ptr ds:[VARIABLE_skip_bx], ah ; nonzero
    ; dall thru
do_ems_call_and_register_test_no_cx:
    mov  byte ptr ds:[VARIABLE_skip_cx], ah ; nonzero
    jmp do_ems_call_and_register_test


do_ems_call_and_register_test_no_bx_dx:
    mov  byte ptr ds:[VARIABLE_skip_dx], ah ; nonzero
    ; fall thru
do_ems_call_and_register_test_no_bx:
    mov  byte ptr ds:[VARIABLE_skip_bx], ah ; nonzero
    jmp do_ems_call_and_register_test
do_ems_call_and_register_test_no_al:
    mov  byte ptr ds:[VARIABLE_skip_al], ah ; nonzero
    jmp  do_ems_call_and_register_test


do_ems_call_and_register_test_no_di:
    mov  byte ptr ds:[VARIABLE_skip_di], ah ; nonzero
    jmp  do_ems_call_and_register_test



compare_handle_name:

    push  si
    push  di
    cmpsw
    jne   error_non_match
    cmpsw
    jne   error_non_match
    cmpsw
    jne   error_non_match
    cmpsw
    jne   error_non_match

    pop   di
    pop   si
    ret

error_non_match:
    pop   di
    pop   si
    push  ax
    push  dx

    PRINT_STRING  handle_test_error
    pop   dx
    pop   ax
    ret

func_22_function_3:
    push  es
    push  ax
    push  bx
    mov   word ptr ds:[func_22_modify_offset+1], done_with_function_3 - func_22_modify_offset_AFTER
    jmp  jump_into_func_22

func_22_function_1:
    
    ; note note note uses sqemm index values

    push  es
    push  ax
    push  bx

    mov   ax, word ptr ds:[func_22_phys_struct_1+0]
    mov   bx, word ptr ds:[VARIABLE_page_frame+2]
    mov   es, bx
    call  test_page_with_ax

    mov   ax, word ptr ds:[func_22_phys_struct_1+4]
    add   bh, 4
    mov   es, bx
    call  test_page_with_ax

    mov   ax, word ptr ds:[func_22_phys_struct_1+8]
    add   bh, 4
    mov   es, bx
    call  test_page_with_ax

    mov   ax, word ptr ds:[func_22_phys_struct_1+12]
    add   bh, 4
    mov   es, bx
    call  test_page_with_ax

    jump_into_func_22:

    mov   ax, word ptr ds:[func_22_phys_struct_1+16]
    mov   bx, 04000h
    mov   es, bx
    call  test_page_with_ax

    mov   ax, word ptr ds:[func_22_phys_struct_1+20]
    mov   bx, 04400h
    mov   es, bx
    call  test_page_with_ax

    mov   ax, word ptr ds:[func_22_phys_struct_1+24]
    mov   bx, 04800h
    mov   es, bx
    call  test_page_with_ax

    mov   ax, word ptr ds:[func_22_phys_struct_1+28]
    mov   bx, 05000h
    mov   es, bx
    call  test_page_with_ax

    pop   bx
    pop   ax
    pop   es
    func_22_modify_offset:
    jmp  done_with_function_1
    func_22_modify_offset_AFTER:

func_22_function_2:

    ; change pages out.
    push  ax
    push  bx
    
    mov   ax, 10
    mov   bx, 1
    call  init_page_map   ; init map state without remapping
    call  test_map_1700

    pop   bx
    pop   ax
    func_22_modify_offset_2:
    jmp  done_with_function_2

write_64_bytes_increasing:

    push di
    push ax
    push cx

    xor  di, di

    xor  ax, ax
    mov  cx, 64

    loop_write_64:
        stosb
        inc ax
        loop loop_write_64

    pop  cx
    pop  ax
    pop  di
    
    ret

test_64_bytes_increasing:

    push di
    push ax
    push cx




    xor  ax, ax
    mov  cx, 64

    loop_test_64:
        scasb
        jne   print_test_error_64byte
        inc ax
        loop loop_test_64
    return_test_page_64:


    pop  cx
    pop  ax
    pop  di
    
    ret

print_test_error_64byte:
    push  dx
    PRINT_STRING move_64_error
    pop   dx

    call  prompt_for_key
    jmp   return_test_page_64

check_conventional_copy:

    push  ax
    push  cx
    push  bp
    push  ds
    push  es
    push  si
    push  di

    ; use page frame to compare to 4000...A000
    mov   cx, 6
    mov   bp, 04000h
    mov   ax, CONVENTIONAL_COPY_PAGE  ; page frame
    xor   di, di
    xor   si, si


    loop_next_conventional_64k:
        mov   es, bp

        call  page_in_four_pages_starting_at_ax ; set up page frame
        push  ds
        mov   ds, word ptr ds:[VARIABLE_page_frame+2]  ; page frame segment

        push  cx
        mov   cx, 32768
        repe  cmpsw
        pop   cx
        pop   ds
        jne   conventional_non_match


        add   bp, 01000h
        add   ax, 4
        loop  loop_next_conventional_64k

    skip_rest_of_conventional_check:

    pop  di
    pop  si
    pop  es
    pop  ds
    pop  bp
    pop  cx
    pop  ax


    ret

conventional_non_match:  

    push  dx
    PRINT_STRING unmap_error
    pop   dx

    call  prompt_for_key

    jmp   skip_rest_of_conventional_check

;; ACCESSORY FUNCTIONS END
;; ACCESSORY FUNCTIONS END
;; ACCESSORY FUNCTIONS END
;; ACCESSORY FUNCTIONS END
;; ACCESSORY FUNCTIONS END
;; ACCESSORY FUNCTIONS END


; STRINGS START
; STRINGS START
; STRINGS START
; STRINGS START
; STRINGS START

string_running_test:
db  0Dh, 0Ah
db "Running Test: "
test_num_offset:
db '000'
db  "...   ", '$'


COMMENT @
string_success:
db "Test Passed!", 0Dh, 0Ah,'$'

string_hex_handle:
db 0Dh, 0Ah
db "    Handle Recieved: "
string_hex_handle_offset:
db "00", '$'
@

string_hex_page_frame_address:
db 0Dh, 0Ah
db "    Page Frame Address: "
string_hex_page_frame_address_offset:
db "0000", '$'

string_page_count_decimal:
db 0Dh, 0Ah
db "    Unallocated Pages: "
string_page_count_decimal_unallocated:
db "0000"
db "    Total Pages: "
string_page_count_decimal_total:
db "0000", '$'

string_ran_tests:
db 0Dh, 0Ah
db "    Total EMS Interrupts run: "
string_ran_tests_decimal_1:
db "0000"
db "    Errors: "
string_ran_tests_decimal_2:
db "0000", '$'


string_register_name:
db 0Dh, 0Ah
db "    Testing "
string_register_name_offset:
db "AX"
string_register_value:
db " ... Value: "
string_register_value_offset:
db "0000"
string_expected_value:
db "  vs Expected:  "
string_expected_value_offset:
db "0000$"

str_no_conventional_tests:
db 0Dh, 0Ah, "NO CONVENTIONAL MEMORY PAGES DETECTED?  skipping.... $"

string_paused:
db 0Dh, 0Ah
db "Currently paused - press a key to continue. $"

scan_test_error:
db 0Dh, 0Ah
db "    Page "
scan_test_error_offset:
db "0000"
db " failed scan test in segment "
scan_test_error_segment:
db "0000"
db " $"

scan_test_success:
db 0Dh, 0Ah
db "    Page "
scan_test_success_offset:
db "0000"
db " passed scan test in segment "
scan_test_success_segment:
db "0000"
db " $"


move_64_error:
db 0Dh, 0Ah, "    Failed overlap copy!$"

unmap_error:
db 0Dh, 0Ah, "    Failed conventional unmap test!$"

; STRINGS END
; STRINGS END
; STRINGS END
; STRINGS END
; STRINGS END




; DATA START
; DATA START
; DATA START
; DATA START
; DATA START

ALIGN 2
expected_value:
dw 0
_test_num:
dw 0


VARIABLE_exit_sp:
dw 0
VARIABLE_unallocated_page_count:
dw 0
VARIABLE_unallocated_total_page_count:
dw 0
VARIABLE_saved_handle_1:
dw 0
VARIABLE_saved_handle_2:
dw 0
VARIABLE_saved_handle_3:
dw 0
VARIABLE_saved_handle_4:
dw 0
VARIABLE_saved_handle_5:
dw 0
VARIABLE_dead_handle:
dw 0
VARIABLE_page_count:
dw 0
VARIABLE_total_handle_count:
dw 0
VARIABLE_handle_directory_count:
dw 0
VARIABLE_OS_key:
dw 0
dw 0


HANDLE_NAME_0:
db "SEARCHME"
HANDLE_NAME_1:
db "SQUIRTLE"
HANDLE_NAME_2:
db "AAAAAAAA"
HANDLE_NAME_3:
db "AAAA", 0, 0, 0, 0
HANDLE_NAME_4:
db "A"
HANDLE_NAME_BLANK:
db 0, 0, 0, 0, 0, 0, 0, 0


handle_test_error:
db 0Dh, 0Ah
db "Handle name error: "

EMPTY_HANDLE_LOCATION:
db  0, 0, 0, 0, 0, 0, 0, 0, "$"


VARIABLE_page_frame:  ; page frame separated by 4 each
map_1701_page_list_four:
dw  0, 0  ; four pages
dw  0, 0
dw  0, 0
dw  0, 0


map_1700_page_list_four:
dw  0, 0  ; four pages
dw  0, 1
dw  0, 2
dw  0, 3

func_1400_handle_page_list: ; reuse this region...

map_1700_page_list_full:
REPT 64
dw 0, 0
ENDM

map_1701_page_list_full:
REPT 64
dw 0, 0
ENDM

func_21_handle_directory: ; reuse this region
func_26_hardware_info: ; reuse this region

func_22_phys_struct_3:
pagemap_1_func_15:
partial_pagemap_1_func_16_save_area:
REPT 64
dw 0
ENDM
; for get and set
pagemap_2_func_15:

REPT 64
dw 0
ENDM
partial_pagemap_1_func_16_pagemap:
dw 8
dw 04000h, 05000h, 06000h
dw 07000h, 08000h, 09000h
partial_pagemap_1_func_16_page_frame:
dw 0D000h, 0D800h

partial_pagemap_1_values:
dw 32, 36, 40
dw 44, 48, 52
dw 56, 58

func_14_page_counts:
dw 4, 4, 4, 4, 64

dw 0  ; offset by 2

func_22_struct_1:
  dw OFFSET func_22_function_1 , 0
  db 8
  dw OFFSET func_22_phys_struct_1, 0
  db 0
  dw 0, 0
  dw 0, 0


func_22_phys_struct_1:
; logical, page
    dw 8,  0
    dw 9,  1
    dw 10, 2
    dw 11, 3
    dw 20, 4
    dw 20, 5
    dw 21, 6
    dw 0,  8

func_22_phys_struct_2:    
; logical, page
    dw 20, 04000h
    dw 20, 04400h
    dw 21, 04800h
    dw 0, 05000h





COMMENT @
          move_source_dest_struct      STRUC
             region_length             DD  ?
             source_memory_type        DB  ?
             source_handle             DW  ?
             source_initial_offset     DW  ?
             source_initial_seg_page   DW  ?
             dest_memory_type          DB  ?
             dest_handle               DW  ?
             dest_initial_offset       DW  ?
             dest_initial_seg_page     DW  ?
          move_source_dest_struct      ENDS
@

func_24_struct:
  ; length
  dw 0, 0
  ; source
    ; type
    db 0
    ; handle
    dw 0
    ; offset
    dw 0
    ; initial page
    dw 0
  ; dest
    ; type
    db 0
    ; handle
    dw 0
    ; offset
    dw 0
    ; initial page
    dw 0


VARIABLE_expected_register_ax:
dw 0
VARIABLE_expected_register_dx:
dw 0
VARIABLE_expected_register_cx:
dw 0
VARIABLE_expected_register_bx:
dw 0
VARIABLE_expected_register_si:
dw 0
VARIABLE_expected_register_di:
dw 0
VARIABLE_expected_register_bp:
dw 0

VARIABLE_skip_bx:
db 0
VARIABLE_skip_dx:
db 0
VARIABLE_skip_cx:
db 0
VARIABLE_skip_al:
db 0
VARIABLE_skip_di:
db 0
COMMENT @
VARIABLE_skip_si:
db 0
VARIABLE_skip_bp:
db 0
@
VARIABLE_test_count:
dw 0

VARIABLE_error_count:
dw 0
VARIABLE_page_frame_2:

; DATA END
; DATA END
; DATA END
; DATA END
; DATA END
; DATA END

END