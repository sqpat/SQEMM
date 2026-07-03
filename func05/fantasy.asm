  xor        ah, ah
_RESIDENT_VARIABLE_pageable_frame_count:
  cmp        ax, 01000h
  jnb        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        func_44_no_emm_handle_found
  
  ; al and bx are still the args

  ; dumb hack. internally c000 - ec00 are pages 0-11 in order.
  ; but if you want d000 to be page frame, outwardly we must expose it as 0-4.
  ; so we are assuming 0-4 and adding by 4 to get the real internal offset
  ; and assume 4-12 not used.

  cli
  cmp   al, 12
  jae   NOT_CONVENTIONAL_REGISTER
  add   al, 4 ; need to add 4 for d000 case for scamp...  we do this branch knowing it may need to undone eventually
  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h
  lea   ax, [bx + FANTASY_PAGE_OFFSET_AMT]   ; offset by default starting page
  out   FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  sti
  xor   ax, ax
  iret

  NOT_CONVENTIONAL_REGISTER:


  ; write ems port... select chipset register
  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page
  mov   ax, bx
  out   FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  sti


  RETURN_RESULT_00:

  xor   ax, ax
  iret
  
  handle_default_page_44h:
  ; mapping to page -1
  ; add four to get the default page value for the page 
  out   FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  sti
  xor   ax, ax
  iret




  
  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret