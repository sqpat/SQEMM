
UTIL_get_page:
; return value at page index (ax) in (ax)

  cmp   al, SCAMP_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jb    util_get_page_handle_page_frame

  ; normalize to register 0x4000 hw value
  add   al, (SCAMP_CHIPSET_CONVENTIONAL_PAGE_4000 - SCAMP_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA) 

  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page

  in    ax, SCAMP_PAGE_SET_REGISTER
  sub   ax, SCAMP_PAGE_OFFSET_AMT

  ret

  util_get_page_handle_page_frame:

SELFMODIFY_SCAMP_add_page_frame_offset_3:
  add   al, 4

  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
  in    ax, SCAMP_PAGE_SET_REGISTER
  sub   ax, SCAMP_PAGE_OFFSET_AMT


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

  mov   ax, dx
  add   ax, SCAMP_PAGE_OFFSET_AMT
  out   SCAMP_PAGE_SET_REGISTER, ax
  ret
  util_set_page_handle_page_frame:

SELFMODIFY_SCAMP_add_page_frame_offset_4:
  add   al, 4
  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page

  mov   ax, dx
  add   ax, SCAMP_PAGE_OFFSET_AMT
  out   SCAMP_PAGE_SET_REGISTER, ax
  ret


UTIL_unmap_all_pages:
  push  cx

  push  bx
  
  mov   bx, -1
  mov   cx, 24
  mov   ax, 12
  
  UTIL_loop_unmap_next_page:
    out   SCAMP_PAGE_SELECT_REGISTER, al
    inc   ax
    xchg  ax, bx
    out   SCAMP_PAGE_SET_REGISTER, ax
    xchg  ax, bx
    loop  UTIL_loop_unmap_next_page

  mov  cx, 4
SELFMODIFY_SCAMP_add_page_frame_offset_6:
  mov  al, 4

  UTIL_loop_unmap_next_page_frame:
    out   SCAMP_PAGE_SELECT_REGISTER, al
    inc   ax
    xchg  ax, bx
    out   SCAMP_PAGE_SET_REGISTER, ax
    xchg  ax, bx
    loop  UTIL_loop_unmap_next_page_frame

  pop  bx

  pop  cx
  ret
