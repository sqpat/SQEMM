
  ; page frame's pages are 260h, 261h, 262h, 263h

  ; al and bx are still the args

  push dx  
  xor  ah, ah
  push ax
  SELFMODIFY_LOTECH_set_page_select_register_4:
  add  ax, LOTECH_BASE_PAGE_REGISTER
  xchg ax, dx
  mov ax, bx 

  ; since FF works as an unmap, lets just write that.


  out   dx, al   ; write 16 bit page num. 
  
  pop   dx
  pop   ax
  iret