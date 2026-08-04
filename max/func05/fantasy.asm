; note: bx on stack
  push       ax   ; gross, need to store al.


  ; al and bx are still the args

  ; internally c000 - ec00 are pages 0-11 in order.
  ; but only page frame is exposed as indexes 0-4


  cmp   al, FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jae   func_05_conventional_register
SELFMODIFY_FANTASY_add_page_frame_offset_2:  
  add   al, 4 ; need to offset by proper chipset page frame to hardward amount
  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page
  inc   bx   ; -1 check
  jz    handle_default_page_44h
SELFMODIFY_FANTASY_set_page_offset_1:
  lea   ax, [bx + 01000h - 1]   ; offset by default starting page
  out   FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 

  pop   ax
  pop   bx
  xor   ah, ah

  iret

  func_05_conventional_register:
  ; normalize to register 0x4000 hw value
  add   al, (FANTASY_CHIPSET_CONVENTIONAL_PAGE_4000 - FANTASY_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA) 

  ; write ems port... select chipset register
  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page
  inc   bx   ; -1 check
  je    handle_default_page_44h
SELFMODIFY_FANTASY_set_page_offset_2:
  lea   ax, [bx + 01000h - 1]   ; offset by default starting page
  out   FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 



  RETURN_RESULT_00:

  pop   ax
  pop   bx
  xor   ah, ah

  iret
  
  handle_default_page_44h:
  ; mapping to page -1
  ; add four to get the default page value for the page 
  xchg  ax, bx
  dec   ax
  out   FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 

  pop   ax
  pop   bx
  xor   ah, ah

  iret



