
  ; page frame's pages are 260h, 261h, 262h, 263h


  
  ; al and bx are still the args

  push dx  
 
  add ax, LOTECH_PAGE_REGISTER_0
  mov dx, ax
  mov ax, bx

  ; since FF works as an unmap, lets just write that.

  cli
  out   dx, al   ; write 16 bit page num. 
  
  pop   dx
  xor   ax, ax  
  iret