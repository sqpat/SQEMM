  push cx
  push si
  push dx


  ; physical page number mode
  cli
  func1700_loop_next_page:
  ; next page in ax....

  lodsw
  add  ax,  LOTECH_PAGE_REGISTER_0
  mov  dx, ax
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
