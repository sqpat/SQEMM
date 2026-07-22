  xchg   ax, bx
  push cx
  push si
  push dx


  ; physical page number mode
  cli
  func1701_loop_next_page:
  ; next page in ax....

  lodsw
  xchg ax, dx
  lodsw
  call COMMON_util_get_register_for_segment
  SELFMODIFY_LOTECH_set_page_select_register_8:
  add  ax, LOTECH_BASE_PAGE_REGISTER
  xchg ax, dx

  out   dx, al   ; write 8 bit page num. 

  loop       func1701_loop_next_page
  sti


  ; exit fall thru

  pop dx
  pop si
  pop cx
  pop ax
  xor ah, ah
  iret
