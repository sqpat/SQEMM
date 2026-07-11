
UTIL_get_page:
; return value at page index (ax) in (ax)

  cmp   al, FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jb    util_get_page_handle_page_frame

  ; normalize to register 0x4000 hw value
  add   al, (FANTASY_CHIPSET_CONVENTIONAL_PAGE_4000 - FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA) 

  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page

  in    ax, FANTASY_PAGE_SET_REGISTER
  sub   ax, FANTASY_PAGE_OFFSET_AMT

  ret

  util_get_page_handle_page_frame:

SELFMODIFY_FANTASY_add_page_frame_offset_3:
  add   al, 4

  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page
  in    ax, FANTASY_PAGE_SET_REGISTER
  sub   ax, FANTASY_PAGE_OFFSET_AMT


  ret
  
UTIL_set_page:
; write page (dx) to page index (ax)




  cmp   al, FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jb    util_set_page_handle_page_frame

  ; normalize to register 0x4000 hw value
  add   al, (FANTASY_CHIPSET_CONVENTIONAL_PAGE_4000 - FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA) 

  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page

  mov   ax, dx
  add   ax, FANTASY_PAGE_OFFSET_AMT
  out   FANTASY_PAGE_SET_REGISTER, ax
  ret
  util_set_page_handle_page_frame:

SELFMODIFY_FANTASY_add_page_frame_offset_4:
  add   al, 4
  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page

  mov   ax, dx
  add   ax, FANTASY_PAGE_OFFSET_AMT
  out   FANTASY_PAGE_SET_REGISTER, ax
  ret
