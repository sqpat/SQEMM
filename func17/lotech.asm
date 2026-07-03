  push cx
  push si
  push dx


  ; physical page number mode
  cli
  DO_NEXT_PAGE_5000:
  ; next page in ax....

  lodsw
  add  ax,  LOTECH_PAGE_REGISTER_0
  mov  dx, ax
  lodsw

  out   dx, al   ; write 8 bit page num. 

  loop       DO_NEXT_PAGE_5000
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret
