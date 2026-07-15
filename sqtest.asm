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
    call show_error
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
    call show_error
    pop  bx
ENDM

TEST_RESULT_DX_NO_VAL MACRO testdx
    push bx
    mov  word ptr ds:[string_register_name_offset], "XD" ; endian
    mov  bx, dx
    call print_hex_register
    cmp  dx, word ptr ds:[expected_value]
    je   $+5
    call show_error
    pop  bx
ENDM


TEST_RESULT_BX MACRO testbx

    mov  word ptr ds:[expected_value], testbx
    mov  word ptr ds:[string_register_name_offset], "XB" ; endian

    call print_hex_register
    cmp  bx, word ptr ds:[expected_value]
    je   $+5
    call show_error

ENDM

TEST_EMS_REGISTER_CALL_ALL MACRO testax
    mov  word ptr ds:[VARIABLE_expected_register_ax], testax
    call do_ems_call_and_register_test
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
add   bh, 04h
mov   word ptr ds:[VARIABLE_page_frame+6], bx
add   bh, 04h
mov   word ptr ds:[VARIABLE_page_frame+10], bx
add   bh, 04h
mov   word ptr ds:[VARIABLE_page_frame+14], bx
TEST_RESULT_AX 0002h


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


;     FUNCTION 4    ALLOCATE PAGES


PRINT_RUNNING_TEST 5
mov   ax, 04304h
mov   bx, 1

TEST_EMS_REGISTER_CALL_NO_DX 0004h
call  print_handle

; dx maintains index


;     FUNCTION 6    DEALLOCATE PAGES


PRINT_RUNNING_TEST 6
mov   ax, 04505h
TEST_EMS_REGISTER_CALL_ALL 0005h




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
call  print_handle
mov   word ptr ds:[VARIABLE_saved_handle_1], dx

mov   ax, 04308h
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_DX 0008h
call  print_handle
mov   word ptr ds:[VARIABLE_saved_handle_2], dx

mov   ax, 04309h
mov   bx, cx
TEST_EMS_REGISTER_CALL_NO_DX 0009h
call  print_handle
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






; TEST 9: allocate pages and put stuff in them. then page around and confirm their contents are ok
PRINT_RUNNING_TEST 9


;     FUNCTION 5    MAP/UNMAP HANDLE PAGES
mov   cx, 4
mov   ax, 04307h
mov   bx, cx

TEST_EMS_REGISTER_CALL_NO_DX 0007h
call  print_handle
mov   word ptr ds:[VARIABLE_saved_handle_1], dx

mov   ax, 04308h
mov   bx, cx
TEST_EMS_REGISTER_CALL_NO_DX 0008h
call  print_handle
mov   word ptr ds:[VARIABLE_saved_handle_2], dx

mov   ax, 04309h
mov   bx, cx
TEST_EMS_REGISTER_CALL_NO_DX 0009h
call  print_handle
mov   word ptr ds:[VARIABLE_saved_handle_3], dx

mov   ax, 04309h
mov   bx, cx
TEST_EMS_REGISTER_CALL_NO_DX 0009h
call  print_handle
mov   word ptr ds:[VARIABLE_saved_handle_4], dx

mov   ax, 04309h
mov   bx, 64
TEST_EMS_REGISTER_CALL_NO_DX 0009h
call  print_handle
mov   word ptr ds:[VARIABLE_saved_handle_5], dx

mov   ax, 0420Ah

TEST_EMS_REGISTER_CALL_NO_BX_DX 000Ah
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

call  print_handle
mov   word ptr ds:[VARIABLE_dead_handle], dx  ; dx handle should be unallocated and bad as long as we dont allocate any more after this.

mov   ax, 04511h
TEST_EMS_REGISTER_CALL_ALL 0011h

; TODO various bad handle tests





; TEST 10: test pages in page frame via function 8/9 stack
PRINT_RUNNING_TEST 10


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
jne   go_skip_conventional  ; todo better error string
mov   word ptr ds:[VARIABLE_page_count], cx  

mov   si, OFFSET map_1700_page_list_full ; offset by 2 
mov   di, OFFSET map_1701_page_list_full + 2
shl   cx, 1  ; we also write the logical entries, which are garbage for now.
rep   movsw


; TEST 13: test pages in conventional region via function 5 page one
PRINT_RUNNING_TEST 13

; TODO page one conventional

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

; TEST 16: test pages in conventional region via function 16 get/set partial page map
PRINT_RUNNING_TEST 16


skip_conventional:



; deallocate


; deallocate

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
TEST_EMS_REGISTER_CALL_ALL 0010h




; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END


; todo test all registers after each call to detect trashing.

quit_exit_program: ; todo detect stack mismatch?
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

    ; todo show expected values?

show_error:

    push  ax
    push  dx
    PRINT_STRING string_error_found

    call  prompt_for_key


    pop   dx
    pop   ax
    ret

show_success:

    push  ax
    push  dx
    PRINT_STRING string_success

    pop   dx
    pop   ax
    ret




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




test_page_with_ax:
public  test_page_with_ax

    PUSHA_MACRO
    xor   di, di
    mov   cx, 16384 / 2
    repe  scasw
    jne   print_test_error
    mov   si, OFFSET scan_test_success_offset
    mov   bx, ax
    call  print_hex_word_bx 
    mov   si, OFFSET scan_test_success_segment
    mov   bx, es
    call  print_hex_word_bx 
    PRINT_STRING scan_test_success
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
        MACRO_PRINT_BAD_REGISTER ax VARIABLE_expected_register_ax
        jmp  continue_after_ax

    bad_register_dx:
        mov  word ptr ds:[string_register_name_offset], "XD" ; endian
        MACRO_PRINT_BAD_REGISTER dx VARIABLE_expected_register_dx
        jmp  continue_after_dx
    
    bad_register_cx:
        mov  word ptr ds:[string_register_name_offset], "XC" ; endian
        MACRO_PRINT_BAD_REGISTER cx VARIABLE_expected_register_cx
        jmp  continue_after_cx
    bad_register_bx:
        mov  word ptr ds:[string_register_name_offset], "XB" ; endian
        MACRO_PRINT_BAD_REGISTER bx VARIABLE_expected_register_bx
        jmp  continue_after_bx


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

    int 067h

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
        mov  word ptr ds:[expected_value], bx
        call print_hex_register
        call show_error
        dont_print_error:
        pop  bx
        ret

do_ems_call_and_register_test_no_dx:
    mov  byte ptr ds:[VARIABLE_skip_dx], 1
    mov  word ptr ds:[VARIABLE_expected_register_bx], bx
    jmp entry_after_dx

do_ems_call_and_register_test_no_cx:
    mov  byte ptr ds:[VARIABLE_skip_cx], 1
    mov  word ptr ds:[VARIABLE_expected_register_bx], bx
    mov  word ptr ds:[VARIABLE_expected_register_dx], dx
    jmp entry_after_cx

do_ems_call_and_register_test_no_bx_dx:
    mov  byte ptr ds:[VARIABLE_skip_dx], 1
    ; fall thru
do_ems_call_and_register_test_no_bx:
    mov  byte ptr ds:[VARIABLE_skip_bx], 1
    jmp entry_after_bx




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



string_error_found:
db "Error: "
error_num:
db '00'
db  0Dh, 0Ah,'$'

string_success:
db "Test Passed!", 0Dh, 0Ah,'$'

string_hex_handle:
db 0Dh, 0Ah
db "    Handle Recieved: "
string_hex_handle_offset:
db "00", '$'

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


map_1700_page_list_full:
REPT 64
dw 0, 0
ENDM

map_1701_page_list_full:
REPT 64
dw 0, 0
ENDM

dw 0  ; offset by 2

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
VARIABLE_skip_di:
db 0
VARIABLE_skip_si:
db 0
VARIABLE_skip_bp:
db 0


; DATA END
; DATA END
; DATA END
; DATA END
; DATA END
; DATA END

END