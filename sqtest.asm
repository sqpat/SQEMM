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
int   067h
TEST_RESULT_AX 0001h


;     FUNCTION 2    GET PAGE FRAME ADDRESS

PRINT_RUNNING_TEST 2
mov   ax, 04102h
int   067h
PRINT_HEX_VALUE_BX string_hex_page_frame_address string_hex_page_frame_address_offset
mov   word ptr ds:[VARIABLE_page_frame+0], bx
add   bh, 04h
mov   word ptr ds:[VARIABLE_page_frame+2], bx
add   bh, 04h
mov   word ptr ds:[VARIABLE_page_frame+4], bx
add   bh, 04h
mov   word ptr ds:[VARIABLE_page_frame+6], bx
TEST_RESULT_AX 0002h


;     FUNCTION 7    GET VERSION
PRINT_RUNNING_TEST 3
mov   ax, 04607h
int   067h
TEST_RESULT_AX 0040h


;     FUNCTION 3    GET UNALLOCATED PAGE COUNT

PRINT_RUNNING_TEST 4
mov   ax, 04203h
int   067h

mov   word ptr ds:[VARIABLE_unallocated_page_count], bx
mov   word ptr ds:[VARIABLE_unallocated_total_page_count], dx

call  print_page_count
TEST_RESULT_AX 0003h

;     FUNCTION 4    ALLOCATE PAGES


PRINT_RUNNING_TEST 5
mov   ax, 04304h
mov   bx, 1
int   067h
call  print_handle
TEST_RESULT_AX 0004h

; dx maintains index


;     FUNCTION 6    DEALLOCATE PAGES


PRINT_RUNNING_TEST 6
mov   word ptr ds:[expected_value], dx
mov   ax, 04505h
int   067h
TEST_RESULT_DX_NO_VAL
TEST_RESULT_AX 0005h




; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END


call prompt_for_key


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
int   067h
call  print_handle
TEST_RESULT_AX 0007h
mov   word ptr ds:[VARIABLE_saved_handle_1], dx

mov   ax, 04308h
mov   bx, cx
int   067h
call  print_handle
TEST_RESULT_AX 0008h
mov   word ptr ds:[VARIABLE_saved_handle_2], dx

mov   ax, 04309h
mov   bx, cx
int   067h
call  print_handle
TEST_RESULT_AX 0009h
mov   word ptr ds:[VARIABLE_saved_handle_3], dx

mov   ax, 0420Ah
int   067h
TEST_RESULT_AX 000Ah
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
int   067h
TEST_RESULT_AX 000Bh
mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
mov   ax, 0510Ch
mov   bx, cx
int   067h
TEST_RESULT_AX 000Ch
mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
mov   ax, 0510Dh
mov   bx, cx
int   067h
TEST_RESULT_AX 000Dh

mov   ax, 0420Ah
int   067h
TEST_RESULT_AX 000Ah
mov   ax, word ptr ds:[VARIABLE_unallocated_page_count]
sub   ax, 9
mov   word ptr ds:[expected_value], ax
mov   dx, bx
TEST_RESULT_DX_NO_VAL

mov   cx, 0
mov   dx, word ptr ds:[VARIABLE_saved_handle_1]
mov   ax, 0510Bh
mov   bx, cx
int   067h
TEST_RESULT_AX 000Bh
mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
mov   ax, 0510Ch
mov   bx, cx
int   067h
TEST_RESULT_AX 000Ch
mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
mov   ax, 0510Dh
mov   bx, cx
int   067h
TEST_RESULT_AX 000Dh

mov   ax, 0420Ah
int   067h
TEST_RESULT_AX 000Ah
mov   ax, word ptr ds:[VARIABLE_unallocated_page_count]
mov   word ptr ds:[expected_value], ax
mov   dx, bx
TEST_RESULT_DX_NO_VAL


mov   cx, 12
mov   dx, word ptr ds:[VARIABLE_saved_handle_1]
mov   ax, 0510Bh
mov   bx, cx
int   067h
TEST_RESULT_AX 000Bh
mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
mov   ax, 0510Ch
mov   bx, cx
int   067h
TEST_RESULT_AX 000Ch
mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
mov   ax, 0510Dh
mov   bx, cx
int   067h
TEST_RESULT_AX 000Dh

mov   ax, 0420Ah
int   067h
TEST_RESULT_AX 000Ah
mov   ax, word ptr ds:[VARIABLE_unallocated_page_count]
sub   ax, 36
mov   word ptr ds:[expected_value], ax
mov   dx, bx
TEST_RESULT_DX_NO_VAL





; deallocate

mov   dx, word ptr ds:[VARIABLE_saved_handle_1]
mov   ax, 0450Eh
int   067h
TEST_RESULT_AX 000Eh
mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
mov   ax, 0450Eh
int   067h
TEST_RESULT_AX 000Eh
mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
mov   ax, 0450Eh
int   067h
TEST_RESULT_AX 000Eh



call prompt_for_key


; TEST 9: allocate pages and put stuff in them. then page around and confirm their contents are ok
PRINT_RUNNING_TEST 9


;     FUNCTION 5    MAP/UNMAP HANDLE PAGES
mov   cx, 4
mov   ax, 04307h
mov   bx, cx
int   067h
call  print_handle
TEST_RESULT_AX 0007h
mov   word ptr ds:[VARIABLE_saved_handle_1], dx

mov   ax, 04308h
mov   bx, cx
int   067h
call  print_handle
TEST_RESULT_AX 0008h
mov   word ptr ds:[VARIABLE_saved_handle_2], dx

mov   ax, 04309h
mov   bx, cx
int   067h
call  print_handle
TEST_RESULT_AX 0009h
mov   word ptr ds:[VARIABLE_saved_handle_3], dx

mov   ax, 04309h
mov   bx, cx
int   067h
call  print_handle
TEST_RESULT_AX 0009h
mov   word ptr ds:[VARIABLE_saved_handle_4], dx

mov   ax, 04309h
mov   bx, 64
int   067h
call  print_handle
TEST_RESULT_AX 0009h
mov   word ptr ds:[VARIABLE_saved_handle_5], dx

mov   ax, 0420Ah
int   067h
TEST_RESULT_AX 000Ah
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
call  fill_in_four_pages_increment_ax

mov   dx, word ptr ds:[VARIABLE_saved_handle_3]
xor   ax, ax
call  page_in_four_pages_starting_at_ax
call  fill_in_four_pages_increment_ax


mov   dx, word ptr ds:[VARIABLE_saved_handle_2]
xor   ax, ax
call  page_in_four_pages_starting_at_ax
call  fill_in_four_pages_increment_ax


mov   dx, word ptr ds:[VARIABLE_saved_handle_1]
xor   ax, ax
call  page_in_four_pages_starting_at_ax
call  fill_in_four_pages_increment_ax

call prompt_for_key

mov   dx, word ptr ds:[VARIABLE_saved_handle_5]
call  test_64_pages_in_reverse

;;;; done testing pages one by one. now random!

; TEST 10: test random pages in page frame via function 17 map/unmap multiple
PRINT_RUNNING_TEST 10




; TEST 11: test pages in page frame via function 8/9 stack
PRINT_RUNNING_TEST 11


; TEST 12: test pages in page frame via function 15 get/set page map
PRINT_RUNNING_TEST 12

; TEST 13: test pages in page frame via function 16 get/set partial page map
PRINT_RUNNING_TEST 13


; TEST 14: test pages in conventional region via function 5 page one
PRINT_RUNNING_TEST 14


; TEST 15: test pages in conventional region via function 17 map/unmap multiple
PRINT_RUNNING_TEST 15

; TEST 16: test pages in conventional region via function 15 get/set page map
PRINT_RUNNING_TEST 16

; TEST 17: test pages in conventional region via function 16 get/set partial page map
PRINT_RUNNING_TEST 17



; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END
; HANDLE MAPPING STRESS TESTS END




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





ALIGN 2
_test_num:
dw 0

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

expected_value:
dw 0

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

string_paused:
db 0Dh, 0Ah
db "Currently paused - press a key to continue. $"



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
    mov   es, word ptr ds:[VARIABLE_page_frame+0]
    call  fill_in_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+2]
    call  fill_in_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+4]
    call  fill_in_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+6]
    call  fill_in_page_with_ax
    inc   ax
    pop   es
    ret

page_in_four_pages_starting_at_ax:
    push  ax
    xor   bx, bx
    mov   bl, al
    mov   ax, 04400h
    int   067h
    TEST_RESULT_AX 0000h

    mov   ax, 04401h
    inc   bx
    int   067h
    TEST_RESULT_AX 0001h

    mov   ax, 04402h
    inc   bx
    int   067h
    TEST_RESULT_AX 0002h

    mov   ax, 04403h
    inc   bx
    int   067h
    TEST_RESULT_AX 0003h

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
    cmp   ax, 20
    je    do_pause
    cmp   ax, 40
    je    do_pause
    cmp   ax, 60
    je    do_pause
    done_pausing_back_to_looping:
    loop  loop_fill_in_next_four

    pop   ax
    pop   cx
    ret

do_pause:
    push ax
    call prompt_for_key
    pop  ax
    jmp  done_pausing_back_to_looping

scan_test_error:
db 0Dh, 0Ah
db "    Page "
scan_test_error_offset:
db "0000"
db " failed scan test $"


test_page_with_ax:

    push  di
    push  cx
    xor   di, di
    mov   cx, 16384 / 2
    repe  scasw
    jne   print_test_error
    pop   cx
    pop   di
    ret

    print_test_error:
    push  si

    mov  si, OFFSET scan_test_error_offset
    call  print_hex_word_bx 

    PRINT_STRING scan_test_error
    pop   si
    pop   cx
    pop   di
    ret


test_four_pages:

    push  es
    mov   es, word ptr ds:[VARIABLE_page_frame+0]
    call  test_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+2]
    call  test_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+4]
    call  test_page_with_ax
    inc   ax
    mov   es, word ptr ds:[VARIABLE_page_frame+6]
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
    cmp   ax, 4
    je    do_pause_scan
    cmp   ax, 24
    je    do_pause_scan
    cmp   ax, 44
    je    do_pause_scan
    done_pausing_back_to_looping_scan:
    loop  loop_scan_next_four

    pop   ax
    pop   cx
    ret

do_pause_scan:
    push ax
    call prompt_for_key
    pop  ax
    jmp  done_pausing_back_to_looping_scan


;; ACCESSORY FUNCTIONS END
;; ACCESSORY FUNCTIONS END
;; ACCESSORY FUNCTIONS END
;; ACCESSORY FUNCTIONS END
;; ACCESSORY FUNCTIONS END
;; ACCESSORY FUNCTIONS END




; DATA START
; DATA START
; DATA START
; DATA START
; DATA START

VARIABLE_exit_sp:
dw 0
VARIABLE_page_frame:
dw 0, 0, 0, 0  ; four segments
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


; DATA END
; DATA END
; DATA END
; DATA END
; DATA END
; DATA END

END