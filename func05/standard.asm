
  ; page frame's pages are 258, 4258, 8258, c258. 

  xor        ah, ah
_RESIDENT_VARIABLE_pageable_frame_count:
  cmp        ax, 01000h
  jnb        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        func_44_no_emm_handle_found
  
  ; al and bx are still the args

  push dx  
 
  ror ax, 2
  add ax, STANDARD_BOARD_PAGE_REGISTER_0

  ; 0-4 becomes 258, 4258, 8258, c258
  mov dx, ax
  cli
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h

  mov   ax, bx
  add   ax, STANDARD_BOARD_PAGE_OFFSET_AMT   ; turn on EMS ON bit
  out   dx, al   ; write 8 bit page num. 
  sti

  pop   dx
  xor   ax, ax
  iret

  handle_default_page_44h:
  ; mapping to page -1
  mov   ax, STANDARD_BOARD_CHIPSET_UNMAP_VALUE ; "turn off ems for this page" value
  out   dx, al   ; write 8 bit page num. 
  sti
  
  pop   dx
  
  ;xor   ax, ax   ; set to 0 above
  iret

  
  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret

