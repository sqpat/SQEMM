  push cx
  push si
  push dx
  push bx

  xor  bx, bx
  ; physical page number mode
  cli
  func1700_loop_next_page:
  ; next page in ax....

  lodsw
  xchg  ax, dx ; store...
  lodsw
  mov   bx, ax
  SELFMODIFY_LOTECH_set_page_select_register_7:
  add   ax, LOTECH_BASE_PAGE_REGISTER
  xchg  ax, dx ; put both where they need to be..


  out   dx, al   ; write 8 bit page num. 
  
  mov   byte ptr cs:[bx + _RESIDENT_VARIABLE_driver_local_page_cache], al



  loop       func1700_loop_next_page
  sti


  ; exit fall thru
  xor ax, ax
  pop bx
  pop dx
  pop si
  pop cx
  iret
