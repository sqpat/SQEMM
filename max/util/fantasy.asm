
UTIL_get_page:
; return value at page index (ax) in (ax)
  push  dx

  mov   dx, FANTASY_PAGE_SELECT_REGISTER

  cmp   al, FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jb    util_get_page_handle_page_frame

  ; normalize to register 0x4000 hw value
  add   al, (FANTASY_CHIPSET_CONVENTIONAL_PAGE_4000 - FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA) 

  out   dx, al   ; select EMS page

  inc   dx
  inc   dx
  in    ax, dx

  pop   dx
  ret

  util_get_page_handle_page_frame:

SELFMODIFY_FANTASY_add_page_frame_offset_3:
  add   al, 4

  out   dx, al   ; select EMS page

  dec   dx
  dec   dx
  in    ax, dx

  pop   dx
  ret
  
UTIL_set_page:
; write page (dx) to page index (ax)

  push  dx ; store

  mov   dx, FANTASY_PAGE_SELECT_REGISTER


  cmp   al, FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jb    util_set_page_handle_page_frame

  ; normalize to register 0x4000 hw value
  add   al, (FANTASY_CHIPSET_CONVENTIONAL_PAGE_4000 - FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA) 

  out   dx, al   ; select EMS page

  inc   dx
  inc   dx
  pop   ax
  out   dx, ax
  ret
  util_set_page_handle_page_frame:

SELFMODIFY_FANTASY_add_page_frame_offset_4:
  add   al, 4

  dec   dx
  dec   dx
  pop   ax
  out   dx, ax
  ret
