
  ; note: scat maps 0-4 not to the page frame but rather to 4000-4c00
  ; which is unfortunate. its not really backward compatible with 0-3 = page frame 3.2 style programming...
  ; for now in sqemm, call 44h (a 3.2 call) will map 0-4 to the page frame and ignore backfill register addresses.




  
  ; al and bx are still the args

  push dx  
 
SELFMODIFY_SCAT_set_page_select_register_2:
  mov   dx, SCAT_PAGE_SELECT_REGISTER
  sub   al, SCAT_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jae   func_05_do_conventional_map
  SELFMODIFY_SCAT_add_page_frame_register_offset_1:
  add   al, SCAT_PAGE_C000_REGISTER_OFFSET ; convert 0-4 to page frame. adds back subtracted 04h too
  func_05_do_conventional_map:   ; conventional page should be good.
  cli
  out   dx, al   ; select EMS page
SELFMODIFY_SCAT_set_page_set_register_2:
  mov   dx, SCAT_PAGE_SET_REGISTER
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h
  
  SELFMODIFY_SCAT_add_page_offset_and_enable_2:
  lea   ax, [BX + SCAT_PAGE_OFFSET_AMT]   ; offset by default starting page
  out   dx, ax   ; write 16 bit page num. 
  sti
  
  pop   dx
  xor   ax, ax

  iret


  handle_default_page_44h:
  ; mapping to page -1
  mov   ax, SCAT_CHIPSET_UNMAP_VALUE ; "turn off ems for this page" value
  out   dx, ax   ; write 16 bit page num. 
  sti
  
  pop   dx
  xor   ax, ax
  iret

