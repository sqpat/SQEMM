
  ; page frame's pages are 260h, 261h, 262h, 263h

  xor        ah, ah
_RESIDENT_VARIABLE_pageable_frame_count:
  cmp        ax, 01000h
  jnb        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        func_44_no_emm_handle_found
  
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



  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret