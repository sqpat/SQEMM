UTIL_get_page: ; written by zero318
; return value at page index (ax) in (ax)
  PUSH  DX
  PUSH  BX
  MOV   AH, 080h ; set enabled bit for later comparison
  CMP   AL, 4 ; preserve flags until JB
  MOV   BX, OFFSET WF76C10_api_to_physical_page_lookup
  XLAT  CS:[BX]
  MOV   DX, WD76C10_PAGE_SELECT_REGISTER
  OUT   DX, AX ; select EMS page (high byte ignores writes)
  XCHG  AX, BX
  MOV   DH, 0E8h ; WD76C10_PAGE_SET_REGISTER
  IN    AX, DX
  JB    util_getpage_handle_page_frame_check
  CMP   AX, BX
  POP   BX
  POP   DX
  JE    util_return_unmapped
util_getpage_subtract_page_offset:
  and   ax, 07FFFh
SELFMODIFY_WD76C10_add_page_offset_and_enable_5:
  SUB   AX, WD76C10_PAGE_OFFSET_AMT  ; todo 
  RET
util_return_unmapped:
  MOV   AX, 0FFFFh
  RET
util_getpage_handle_page_frame_check:
  XOR   AH, BH ; BH has only the high bit set from earlier
  CWD
  OR    AX, DX ; Set -1 if AX had high bit off
  POP   BX
  POP   DX
  JNS   util_getpage_subtract_page_offset
  RET
 


UTIL_set_page:

; write page (dx) to page index (ax)

  push  dx ; store
  push  bx ; store

  push  dx ; store
  mov   dx, WD76C10_PAGE_SELECT_REGISTER

  xchg  ax, bx
  xor   ax, ax
  mov   al, byte ptr cs:[WF76C10_api_to_physical_page_lookup+bx]

  out   dx, ax   ; select EMS page
  pop   ax

  mov   dx, WD76C10_PAGE_SET_REGISTER
  inc   ax
  jz    handle_unmapped_set

SELFMODIFY_WD76C10_add_page_offset_and_enable_4:
  add   ax, WD76C10_PAGE_OFFSET_AMT + WD76C10_PAGE_OFFSET_AMT -1  ; include ON bit
util_set_page_do_portwrite:
  out   dx, ax
  pop   bx
  pop   dx
  ret

handle_unmapped_set:
  cmp   bl, 4
  jb    util_set_page_do_portwrite; write zero 
  cmp   bl, 20  ; catch page 8000-9fff
  ja    util_adjust_08000h
  mov   al, bl
  jmp   util_set_page_do_portwrite
util_adjust_08000h:
  mov   al, bl
  add   al, 12 ; 32-40 not 20-28
  jmp   util_set_page_do_portwrite


UTIL_unmap_all_pages:
public  UTIL_unmap_all_pages
  PUSHA_MACRO
  
  

  mov   cx, 16
  mov   bx, 16

  mov   si, WD76C10_PAGE_SELECT_REGISTER
  mov   di, WD76C10_PAGE_SET_REGISTER
  
util_ready_next_default_4000_8000:
    mov   dx, si
    mov   ax, bx
    out   dx, ax
    mov   dx, di
    out   dx, ax
    inc   bx
    loop  util_ready_next_default_4000_8000

  mov   cx, 8
  xor   bx, bx

util_ready_next_default_8000_A000:
    mov   dx, si
    mov   ax, bx
    out   dx, ax
    mov   dx, di
    add   ax, 32
    out   dx, ax
    inc   bx
    loop  util_ready_next_default_8000_A000

  mov   cx, 4
SELFMODIFY_WD76C10_set_page_select_register_12:
  mov  bx, WD76C10_PAGE_C000_REGISTER_OFFSET


  util_ready_next_default_page_frame:
    mov   dx, si
    mov   ax, bx
    out   dx, ax
    mov   dx, di
    xor   ax, ax
    out   dx, ax
    inc   bx
    loop  util_ready_next_default_page_frame


  POPA_MACRO
  ret
