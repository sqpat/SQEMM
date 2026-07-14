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
add   bh, 040h
mov   word ptr ds:[VARIABLE_page_frame+2], bx
add   bh, 040h
mov   word ptr ds:[VARIABLE_page_frame+4], bx
add   bh, 040h
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

; dx maintains index


; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END
; BASIC TESTS END


;     FUNCTION 5    MAP/UNMAP HANDLE PAGES




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


; DATA END
; DATA END
; DATA END
; DATA END
; DATA END
; DATA END

END