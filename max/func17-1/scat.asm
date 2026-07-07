  push cx
  push bx
  push si
  push dx


  ; physical page number mode
  cli

  func1701_loop_next_page:
    ; next page in ax....
    lodsw
    xchg  ax, bx
    lodsw
    ; read two words - bx and ax

    call util_get_register_for_segment

SELFMODIFY_SCAT_set_page_select_register_8:
  mov   dx, SCAT_PAGE_SELECT_REGISTER
  sub   al, 0Ch
  jae   func_1701_do_conventional_map
  SELFMODIFY_SCAT_add_page_frame_register_offset_8:
  add   al, SCAT_PAGE_C000_REGISTER_OFFSET ; convert 0-4 to page frame. adds back subtracted 0Ch too
  func_1701_do_conventional_map:   ; conventional page should be good.

  
  out   dx, al   ; select EMS page
SELFMODIFY_SCAT_set_page_set_register_4:
  mov   dx, SCAT_PAGE_SET_REGISTER
  cmp   bx, 0FFFFh   ; -1 check
  je    func_1701_handle_default_page
  SELFMODIFY_SCAT_add_page_offset_and_enable_3:
  lea   ax, [BX + SCAT_PAGE_OFFSET_AMT]   ; offset by default starting page

  out   dx, ax   ; write 16 bit page num. 

  loop  func1701_loop_next_page
  func1701_done:
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret

  func_1701_handle_default_page:
  ; mapping to page -1
  mov   ax, SCAT_CHIPSET_UNMAP_VALUE
  out   dx, ax   ; write 16 bit page num. 
  loop  func1701_loop_next_page
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret
