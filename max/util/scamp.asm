
UTIL_get_page:
; return value at page index (ax) in (ax)

  cmp   al, SCAMP_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jb    util_get_page_handle_page_frame

  ; normalize to register 0x4000 hw value
  add   al, (SCAMP_CHIPSET_CONVENTIONAL_PAGE_4000 - SCAMP_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA) 

  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page

  in    ax, SCAMP_PAGE_SET_REGISTER
SELFMODIFY_SCAMP_add_page_offset_6:
  sub   ax, 01000h
  jb    return_negative

  ret
  return_negative:
  mov   ax, -1
  ret

  util_get_page_handle_page_frame:

SELFMODIFY_SCAMP_add_page_frame_offset_3:
  add   al, 4

  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
  in    ax, SCAMP_PAGE_SET_REGISTER
SELFMODIFY_SCAMP_add_page_offset_7:
  sub   ax, 01000h
  jb    return_negative


  ret
  
UTIL_set_page_reverse_arg:
; write page (ax) to page index (dx)
   xchg  ax, dx
UTIL_set_page:
; write page (dx) to page index (ax)

  cmp   al, SCAMP_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jb    util_set_page_handle_page_frame

  ; normalize to register 0x4000 hw value
  add   al, (SCAMP_CHIPSET_CONVENTIONAL_PAGE_4000 - SCAMP_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA) 

  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
  inc   dx
  jz    util_setpage_handle_default_conventional
  util_set_page_not_unmap:
  dec   dx
  mov   ax, dx
SELFMODIFY_SCAMP_add_page_offset_8:
  add   ax, 01000h
  out   SCAMP_PAGE_SET_REGISTER, ax
  ret
util_set_page_handle_page_frame:

SELFMODIFY_SCAMP_add_page_frame_offset_4:
  add   al, 4
  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page

  inc   dx
  jnz   util_set_page_not_unmap

util_setpage_handle_default_page_frame:
  dec   dx
SELFMODIFY_SCAMP_add_page_frame_offset_12:
  sub   al, 4
SELFMODIFY_SCAMP_add_page_offset_minus4_4:
  add   ax, 01000h
  out   SCAMP_PAGE_SET_REGISTER, ax
  ret


util_setpage_handle_default_conventional:
  dec   dx
  add   al, SCAMP_CONVENTIONAL_UNMAP_OFFSET_AMT
  out   SCAMP_PAGE_SET_REGISTER, ax
  ret




UTIL_unmap_all_pages:
  push  cx


  
  mov   cx, 24
  mov   ax, 12

  
  UTIL_loop_unmap_next_page:
    out   SCAMP_PAGE_SELECT_REGISTER, al
    add   al, SCAMP_CONVENTIONAL_UNMAP_OFFSET_AMT
    out   SCAMP_PAGE_SET_REGISTER, ax
    sub   al, (SCAMP_CONVENTIONAL_UNMAP_OFFSET_AMT - 1)
    loop  UTIL_loop_unmap_next_page

  mov  cx, 4
SELFMODIFY_SCAMP_add_page_frame_offset_6:
  mov  al, 4


  UTIL_loop_unmap_next_page_frame:
    out   SCAMP_PAGE_SELECT_REGISTER, al
  SELFMODIFY_SCAMP_add_page_offset_minus4_5:
    add   ax, 01000h

    out   SCAMP_PAGE_SET_REGISTER, ax
  SELFMODIFY_SCAMP_add_page_offset_minus4_6:
    sub   ax, (01000h - 1)

    loop  UTIL_loop_unmap_next_page_frame


  pop  cx
  ret
