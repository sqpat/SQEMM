; note: bx on stack
  push       ax   ; gross, need to store al.


  ; al and bx are still the args

  ; internally c000 - ec00 are pages 0-11 in order.
  ; but only page frame is exposed as indexes 0-4


  cmp   al, SCAMP_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA
  jae   func_05_conventional_register
SELFMODIFY_SCAMP_add_page_frame_offset_2:  
  add   al, 4 ; need to offset by proper chipset page frame to hardware amount
  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
  inc   bx   ; -1 check
  jz    handle_default_page_44h_frame
SELFMODIFY_SCAMP_add_page_offset_1:  
  lea   ax, [bx + 01000h - 1]   ; offset by default starting page
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 

  pop        ax
  pop        bx
  xor        ah, ah

  iret

  func_05_conventional_register:
  ; normalize to register 0x4000 hw value
  add   al, (SCAMP_CHIPSET_CONVENTIONAL_PAGE_4000 - SCAMP_CHIPSET_CONVENTIONAL_PAGEFRAME_DELTA) 

  ; write ems port... select chipset register
  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
  inc   bx   ; -1 check
  jz    handle_default_page_44h
SELFMODIFY_SCAMP_add_page_offset_2:
  lea   ax, [bx + 01000h - 1]   ; offset by default starting page
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 



  RETURN_RESULT_00:

  pop        ax
  pop        bx
  xor        ah, ah

  iret
  
  handle_default_page_44h_frame:
  SELFMODIFY_SCAMP_add_page_offset_minus4_1:
  add   ax, 01000h - SCAMP_CONVENTIONAL_UNMAP_OFFSET_AMT ; we add 4 right after this..

  handle_default_page_44h:
  ; mapping to page -1
  ; add four to get the default page value for the page 
  add   ax, SCAMP_CONVENTIONAL_UNMAP_OFFSET_AMT
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 

  pop        ax
  pop        bx
  xor        ah, ah

  iret



