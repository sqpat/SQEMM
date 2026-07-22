  push cx
  push si
  push dx


  ; physical page number mode
  cli
  func1700_loop_next_page:
  ; next page in ax....

  lodsw
  SELFMODIFY_LOTECH_set_page_select_register_7:
  add  ax, LOTECH_BASE_PAGE_REGISTER
  xchg ax, dx
  lodsw

  out   dx, al   ; write 8 bit page num. 

  loop       func1700_loop_next_page
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret
