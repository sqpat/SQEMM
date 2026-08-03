
UTIL_get_page:

; return value at page index (ax) in (ax)
  push  bx
  push  dx

  mov   dx, WD76C10_PAGE_SELECT_REGISTER

  xchg  ax, bx
  xor   ax, ax
  mov   al, byte ptr cs:[WF76C10_api_to_physical_page_lookup+bx]

  out   dx, ax   ; select EMS page

  ; bx has page lookup still;

  mov   dx, WD76C10_PAGE_SET_REGISTER
  in    ax, dx

  cmp   bl, 4
  pop   dx
  jb    handle_page_frame_check
  
  cmp   ax, bx
  je    util_return_unmapped

  SELFMODIFY_WD76C10_add_page_offset_and_enable_5:
  sub   ax, WD76C10_PAGE_OFFSET_AMT 

  pop   bx
  ret

handle_page_frame_check:
  test  ax, ax
  jns   util_return_unmapped
  and   ax, 07FFFh  ; turn off page ON bit
  pop   bx
  ret


util_return_unmapped:
  mov   ax, 0FFFFh
  pop   bx
  ret

 


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
  mov   al, bl
  jmp   util_set_page_do_portwrite


UTIL_unmap_all_pages:
  push  cx
  push  dx
  push  bx
  push  si
  push  di
  
  

  mov   cx, 16
  mov   bx, 16

  mov   di, 0E872h
  mov   si, 0E072h
  
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
    out   dx, ax
    inc   bx
    loop  util_ready_next_default_page_frame


  pop  di
  pop  si
  pop  bx
  pop  dx
  pop  cx
  ret
