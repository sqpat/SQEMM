
UTIL_get_page:

; return value at page index (ax) in (ax)
  push  dx
SELFMODIFY_SCAT_set_page_select_register_9:
  mov   dx, SCAT_PAGE_SELECT_REGISTER

  sub   al, SCAT_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jae   util_get_page_handle_conventional

SELFMODIFY_SCAT_add_page_frame_register_offset_9:
  add   al, SCAT_PAGE_C000_REGISTER_OFFSET  ; includes 00Ch

  util_get_page_handle_conventional:

  out   dx, al   ; select EMS page

  dec   dx
  dec   dx
  in    ax, dx
  SELFMODIFY_SCAT_add_page_offset_and_enable_5:
  sub   ax, SCAT_PAGE_OFFSET_AMT
  and   ax, 07FFFh ; turn off page ON bit

  pop   dx
  ret


UTIL_set_page_reverse_arg:
; write page (ax) to page index (dx)
   xchg  ax, dx
UTIL_set_page:

; write page (dx) to page index (ax)

  push  dx ; store
SELFMODIFY_SCAT_set_page_select_register_10:
  mov   dx, SCAT_PAGE_SELECT_REGISTER


  sub   al, SCAT_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jae   util_set_page_handle_conventional
SELFMODIFY_SCAT_add_page_frame_register_offset_10:
  add   al, SCAT_PAGE_C000_REGISTER_OFFSET  ; includes SCAT_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA

  util_set_page_handle_conventional:

  out   dx, al   ; select EMS page
  pop   ax

  dec   dx
  dec   dx
  SELFMODIFY_SCAT_add_page_offset_and_enable_4:
  add   ax, SCAT_PAGE_OFFSET_AMT
  out   dx, ax
  ret




UTIL_unmap_all_pages:
  push  cx
  push  dx
  push  bx
  
  mov   bx, SCAT_CHIPSET_UNMAP_VALUE
  mov   cx, 24
  mov   ax, 12
SELFMODIFY_SCAT_set_page_select_register_5:
  mov   dx, SCAT_PAGE_SELECT_REGISTER

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
SELFMODIFY_SCAT_set_page_select_register_12:
  mov  al, SCAT_PAGE_C000_REGISTER_OFFSET

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
