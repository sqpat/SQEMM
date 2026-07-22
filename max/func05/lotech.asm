; note: bx on stack
  ; page frame's pages are 260h, 261h, 262h, 263h

  ; al and bx are still the args

  push dx  
  xor  ah, ah
  xchg ax, bx
  mov   byte ptr cs:[bx + _RESIDENT_VARIABLE_driver_local_page_cache], al
  xchg ax, bx

  push ax
  SELFMODIFY_LOTECH_set_page_select_register_4:
  add  ax, LOTECH_BASE_PAGE_REGISTER
  xchg ax, dx
  xchg ax, bx

  ; since FF works as an unmap, lets just write that.


  out   dx, al   ; write 16 bit page num. 

  pop   ax
  pop   dx
  pop   bx  ;  still ons tack

  iret