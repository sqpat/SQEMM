

  
  ; al and bx are still the args

  ; internally c000 - ec00 are pages 0-11 in order.
  ; but only page frame is exposed as indexes 0-4

  cli
  cmp   al, 12
  jae   NOT_CONVENTIONAL_REGISTER
SELFMODIFY_FANTASY_add_page_frame_offset_2:  
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



