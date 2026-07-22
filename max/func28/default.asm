
do_func_5b01:

mov   byte ptr cs:[_RESIDENT_VARIABLE_current_alternate_register_set], bl
test  bl, bl
jnz   func_5b01_nonzero_register_set

;    Regardless of its value, the map register context restore area
;    pointer is saved within the memory manager.  It will be used
;    during the Get Alternate Map Register Set subfunction.

mov   word ptr cs:[_RESIDENT_VARIABLE_alternate_register_set_default+0], di
mov   word ptr cs:[_RESIDENT_VARIABLE_alternate_register_set_default+2], es ; save pointer.
mov   ax, es
or    ax, di
jz    skip_pointer_record


func_5b01_nonzero:

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

; ah should be 0
func_5b00_nonzero_register_set:
pop        ax

iret


func_5b01_nonzero_register_set:
pop   ax
mov   ah, 09Ch ; Alternate DMA register sets are not supported, and the DMA register set specified is not zero.
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
iret
func_28_return_not_supported:
mov   ah, 09Ch ; Alternate DMA register sets are not supported, and the DMA register set specified is not zero.
func_28_return_ok:
iret

do_func_5b00:
mov   bl, byte ptr cs:[_RESIDENT_VARIABLE_current_alternate_register_set]
test  bl, bl
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

test  bl, bl
jnz   func_28_return_not_supported 

iret
do_func_5b03:
pop   ax
xor   bx, bx ; no alternate register sets supported (for now)
iret