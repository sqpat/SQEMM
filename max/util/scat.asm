
UTIL_get_page:
; return value at page index (ax) in (ax)
  push  dx
SELFMODIFY_SCAT_set_page_select_register_9:
  mov   dx, SCAT_PAGE_SELECT_REGISTER

  sub   al, 0Ch
  jb    util_get_page_handle_page_frame
  ; pre-incremented by 2
  out   dx, al   ; select EMS page

  dec   dx
  dec   dx
  in    ax, dx

  pop   dx
  ret

  util_get_page_handle_page_frame:

SELFMODIFY_SCAT_add_page_frame_register_offset_9:
  add   al, SCAT_PAGE_C000_REGISTER_OFFSET  ; includes 00Ch

  ; pre-incremented by 2
  out   dx, al   ; select EMS page

  dec   dx
  dec   dx
  in    ax, dx

  pop   dx
  ret
  
UTIL_set_page:
; write page (dx) to page index (ax)

  push  dx ; store
SELFMODIFY_SCAT_set_page_select_register_10:
  mov   dx, SCAT_PAGE_SELECT_REGISTER


  sub   al, 0Ch
  jb    util_set_page_handle_page_frame
  ; pre-incremented by 2
  out   dx, al   ; select EMS page

  dec   dx
  dec   dx
  pop   ax
  out   dx, ax
  ret
  util_set_page_handle_page_frame:

SELFMODIFY_SCAT_add_page_frame_register_offset_10:
  add   al, SCAT_PAGE_C000_REGISTER_OFFSET  ; includes 00Ch

  dec   dx
  dec   dx
  pop   ax
  out   dx, ax
  ret
