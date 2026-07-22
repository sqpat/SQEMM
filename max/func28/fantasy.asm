
do_func_5b01:

test  bl, bl
jnz   func_5b01_nonzero_register_set

; If the alternate map register set specified is zero, map register set zero is activated.

mov   al, 0
out   FANTASY_CONTEXT_SET_REGISTER, al

;    Regardless of its value, the map register context restore area
;    pointer is saved within the memory manager.  It will be used
;    during the Get Alternate Map Register Set subfunction.

mov   word ptr cs:[_RESIDENT_VARIABLE_alternate_register_set_default+0], di
mov   word ptr cs:[_RESIDENT_VARIABLE_alternate_register_set_default+2], es ; save pointer.

;    If the map register context restore area
;    pointer is not equal to zero, the contents of the restore area
;    pointed to by ES:DI are copied into register set zero on each
;    expanded memory board in the system.  If the pointer is equal to
;    zero, the contents are not copied.

mov   ax, es
or    ax, di
jz    skip_pointer_record




;    If the map register context restore area
;    pointer is not equal to zero, the contents of the restore area
;    pointed to by ES:DI are copied into register set zero on each
;    expanded memory board in the system.

push  ds
push  si
push  cx
push  bx

push  es
pop   ds
mov   si, di  ; function uses ds:si

call  FUNCTION_15_SAVE_PAGE_MAP

pop   bx
pop   cx
pop   si
pop   ds


skip_pointer_record:

func_5b00_nonzero_register_set:
pop        ax

iret





;          28 Get Alternate Map Register Set                 5B00h     112
;             Set Alternate Map Register Set                 5B01h     117
;             Get Alternate Map Save Array Size              5B02h     120
;             Allocate Alternate Map Register Set            5B03h     122
;             Deallocate Alternate Map Register Set          5B04h     124
;             Allocate DMA Register Set                      5B05h     126
;             Enable DMA on Alternate Map Register Set       5B06h     128
;             Disable DMA on Alternate Map Register Set      5B07h     130
;             Deallocate DMA Register Set                    5B08h     132
EMS_FUNCTION_05Bh:
public EMS_FUNCTION_05Bh

xchg  ax, bx
pop   ax     ; restore subfunction
mov   ah, 0  ; default success
cmp   byte ptr cs:[_RESIDENT_VARIABLE_access_blocked], ah  ; 0 
jne   func_28_access_denied

cmp   al, 8
ja    func_28_bad_subfunction
je    do_func_5b08
push  ax
dec   ax
js    do_func_5b00
je    do_func_5b01
sub   al, 2
js    do_func_5b02
je    do_func_5b03
sub   al, 2
js    do_func_5b04
je    do_func_5b05
dec   ax
js    do_func_5b06
; fall thru
do_func_5b07:
do_func_5b08:
do_func_5b06:
pop   ax
test  bl, bl
jz    func_28_return_ok ; value 0 is fine.
func_28_return_dma_not_supported:
mov   ah, 09Eh ; Dedicated DMA channels are not supported.
func_28_return_ok:
iret
func_5b01_nonzero_register_set:
pop   ax
cmp   bl, MAX_CONTEXT_COUNT
jae   func_28_bad_register_set
push  bx
xor   bh, bh
cmp   byte ptr cs:[_RESIDENT_VARIABLE_context_is_allocated+bx], ah
je    func_28_unallocated_register_set_pop_bx
mov   al, bl
out   FANTASY_CONTEXT_SET_REGISTER, al

mov   al, 1 ; for 5b01...
pop   bx
iret

do_func_5b00:
in    al, FANTASY_CONTEXT_SET_REGISTER
mov   bl, al
test  al, al
jnz   func_5b00_nonzero_register_set

les   di, dword ptr cs:[_RESIDENT_VARIABLE_alternate_register_set_default]  ; return pointer.
mov   ax, es
or    ax, di
jz    func_28_skip_restore


func_5b00_nonzero:

;  If the context save area pointer returned is not equal to
;   zero, this subfunction copies the contents of the mapping
;   registers on each expanded memory board in the system into
;   the save area specified by the pointer.  The format of
;   this save area is the same as that returned by Function 15
;   (Get Page Map subfunction).  This is intended to simulate
;   getting an alternate map register set.  Note that the
;   memory manager does not allocate the space for the
;   context: the operating system must do so.

push  di
push  cx
push  bx

call  FUNCTION_15_GET_PAGE_MAP ; record into es:di

pop   bx
pop   cx
pop   di
; ah should be 0
func_28_skip_restore:
pop        ax

iret
do_func_5b02:
pop   ax
mov   dx, LENGTH_OF_STACK
iret


func_28_access_denied:
mov   ah, 0A4h
iret
func_28_bad_subfunction:

mov        ah, 08fh
iret
do_func_5b05:
pop   ax
xor   bx, bx ; no dma register sets.
iret

do_func_5b04:
pop   ax
; ah is zero
cmp   bl, MAX_CONTEXT_COUNT
jae   func_28_bad_register_set
push  ax
in    al, FANTASY_CONTEXT_SET_REGISTER
cmp   bl, al
pop   ax
je    func_28_bad_register_set  ; different error?
push  bx
xor   bh, bh
cmp   byte ptr cs:[_RESIDENT_VARIABLE_context_is_allocated+bx], ah
je    func_28_unallocated_register_set_pop_bx
mov   byte ptr cs:[_RESIDENT_VARIABLE_context_is_allocated+bx], ah  ; mark zero
pop   bx
iret
func_28_unallocated_register_set_pop_bx:
pop   bx
func_28_bad_register_set:
mov   ah, 09Dh ;  Alternate map register sets are supported, but the alternate map register set specified is either not defined or not allocated.
iret
do_func_5b03:
pop   ax
; note ah is 0
mov   bx, MAX_CONTEXT_COUNT - 1
cmp   byte ptr cs:[_RESIDENT_VARIABLE_context_is_allocated+bx], ah
je    found_register_set
dec   bx
cmp   byte ptr cs:[_RESIDENT_VARIABLE_context_is_allocated+bx], ah
je    found_register_set
dec   bx
cmp   byte ptr cs:[_RESIDENT_VARIABLE_context_is_allocated+bx], ah
je    found_register_set
dec   bx  ; 0
iret
found_register_set:
mov   byte ptr cs:[_RESIDENT_VARIABLE_context_is_allocated+bx], bl  ; mark nonzero 
; we need to copy current context's state to this future context.
push  cx
push  ax
push  dx
push  bx

; bl = new context.
; bh = current context.
in    al, FANTASY_CONTEXT_SET_REGISTER
mov   bh, al

test  bh, bh
jns   func_28_not_first_call
;  ok.. we default the above value to FF, even though the current context is actually 0.
; 
inc   bh  
func_28_not_first_call:
cwd   ; dx = 0
mov   cx, 40

cli

loop_copy_new_context_to_allocated_register_set:
    mov   al, bh
    out   FANTASY_CONTEXT_SET_REGISTER, al
    mov   al, dl
    out   FANTASY_PAGE_SELECT_REGISTER, al
    in    al, FANTASY_PAGE_SET_REGISTER ; read
    mov   dh, al  ; store current value in dh
    mov   al, bl
    out   FANTASY_CONTEXT_SET_REGISTER, al
    mov   al, dh
    out   FANTASY_PAGE_SET_REGISTER, ax
    inc   dx ; increment register
    loop  loop_copy_new_context_to_allocated_register_set

mov   al, bh
out   FANTASY_CONTEXT_SET_REGISTER, al

sti


pop   bx 
pop   dx
pop   ax ; restore ah = 0
pop   cx


iret
