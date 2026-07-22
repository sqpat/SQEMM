  xchg   ax, bx
  push cx
  push si
  push dx
  push bx

  xor  bx, bx


  ; physical page number mode
  cli
  func1701_loop_next_page:
  ; next page in ax....

  lodsw
  xchg ax, dx
  lodsw
  call COMMON_util_get_register_for_segment
  mov  bx, ax
  SELFMODIFY_LOTECH_set_page_select_register_8:
  add   ax, LOTECH_BASE_PAGE_REGISTER
  xchg  ax, dx

  out   dx, al   ; write 8 bit page num. 
  mov   byte ptr cs:[bx + _RESIDENT_VARIABLE_driver_local_page_cache], al

  loop       func1701_loop_next_page
  sti


  ; exit fall thru

  pop bx
  pop dx
  pop si
  pop cx
  pop ax
  xor ah, ah
  iret
