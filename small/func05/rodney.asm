
  xor        ah, ah

  
  ; al and bx are the args

  add   al, RODNEY_PAGE_REGISTER_OFFSET   ; convert 0-4 to 34h-37h

  cli
  out   RODNEY_PAGE_SELECT_REGISTER, al   ; select EMS page
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h
  lea   ax, [bx + RODNEY_PAGE_OFFSET_AMT]   ; offset by default starting page
  out   RODNEY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  sti
  RETURN_RESULT_00:
  xor   ax, ax
  iret


  handle_default_page_44h:
  ; undo mapping by turning off bit 7 in EBh
  xor   ax, ax
  out   RODNEY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  sti
  ; return 0
  iret

