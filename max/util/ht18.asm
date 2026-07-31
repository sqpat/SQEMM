
UTIL_get_page:

; return value at page index (ax) in (ax)
  push  dx
  mov   dx, HT18_PAGE_SELECT_REGISTER

  sub   al, HT18_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jae   util_get_page_handle_conventional

SELFMODIFY_HT18_add_page_frame_register_offset_9:
  add   al, HT18_PAGE_C000_REGISTER_OFFSET  ; includes +4 for above sub

  util_get_page_handle_conventional:

  out   dx, al   ; select EMS page

  dec   dx
  dec   dx
  in    ax, dx

; filter out bit nine of ax, or bit 1 of ah
  clc
  rcr   ah, 2 ; bit 1 in carry flag
  jnc   return_unmapped  ; if it was zero return -1 anyway
  rol   ah, 1  ; remove bit 9 to get page number only.

  SELFMODIFY_HT18_add_page_offset_5:
  sub   ax, 01000h

  pop   dx
  ret

  return_unmapped:
  mov   ax, -1
  pop   dx
  ret


UTIL_set_page:

; write page (dx) to page index (ax)

  push  dx ; store
  push  dx ; store
  mov   dx, HT18_PAGE_SELECT_REGISTER

  sub   al, HT18_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jae   util_set_page_handle_conventional
SELFMODIFY_HT18_add_page_frame_register_offset_10:
  add   al, HT18_PAGE_C000_REGISTER_OFFSET  ; includes HT18_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA

  util_set_page_handle_conventional:

  out   dx, al   ; select EMS page
  pop   ax

  dec   dx
  dec   dx

  inc   ax
  jz    write_unmapped

  SELFMODIFY_HT18_add_page_offset_4_minus_1:
  add   ax, 01000h - 1
  ; insert bit 9 on bit
  HT18_ENABLE_ON_MACRO
  write_unmapped:
  out   dx, ax
  pop   dx
  ret




UTIL_unmap_all_pages:
  push  cx
  push  dx
  push  bx
  
  xor   bx, bx ;  HT18_CHIPSET_UNMAP_VALUE
  mov   cx, 24
  mov   ax, 0
  mov   dx, HT18_PAGE_SELECT_REGISTER

  UTIL_loop_unmap_next_page:
   
    out   dx, al
    dec   dx
    dec   dx
    inc   ax
    xchg  ax, bx
    out   dx, ax
    inc   dx
    inc   dx
    xchg  ax, bx
    loop  UTIL_loop_unmap_next_page

  mov  cx, 4
  
SELFMODIFY_HT18_set_page_frame_register_offset_12:
  mov  al, HT18_PAGE_C000_REGISTER_OFFSET

  UTIL_loop_unmap_next_page_frame:
    out   dx, al
    dec   dx
    dec   dx
    xchg  ax, bx
    out   dx, ax
    inc   dx
    inc   dx
    xchg  ax, bx
    loop  UTIL_loop_unmap_next_page_frame

  pop  bx
  pop  dx
  pop  cx
  ret
