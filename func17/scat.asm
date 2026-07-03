  push cx
  push bx
  push si
  push dx


  ; physical page number mode
  cli
  DO_NEXT_PAGE_5000:
  ; next page in ax....
  lodsw
  xchg  ax, bx
  lodsw
  ; read two words - bx and ax

SELFMODIFY_SCAT_set_page_select_register_3:
  mov   dx, SCAT_PAGE_SELECT_REGISTER
  
  out   dx, al   ; select EMS page
SELFMODIFY_SCAT_set_page_set_register_3:
  mov   dx, SCAT_PAGE_SET_REGISTER
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page
  SELFMODIFY_SCAT_add_page_offset_and_enable_1:
  lea   ax, [BX + SCAT_PAGE_OFFSET_AMT]   ; offset by default starting page

  out   dx, ax   ; write 16 bit page num. 

  loop       DO_NEXT_PAGE_5000
  sti

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret

  handle_default_page:
  ; mapping to page -1
  mov   ax, SCAT_CHIPSET_UNMAP_VALUE
  out   dx, ax   ; write 16 bit page num. 
  loop       DO_NEXT_PAGE_5000
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret