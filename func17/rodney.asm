  push cx
  push bx
  push si


  ; physical page number mode
  cli
  DO_NEXT_PAGE_5000:
  ; next page in ax....
  lodsw
  xchg  ax, bx
  lodsw
  ; read two words - bx and ax

  
  out   RODNEY_PAGE_SELECT_REGISTER, al   ; select EMS page
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page

  lea   ax, [bx + RODNEY_PAGE_OFFSET_AMT]   ; offset by default starting page
  out   RODNEY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 

  loop       DO_NEXT_PAGE_5000
  sti

  ; exit fall thru
  xor ax, ax
  pop si
  pop bx
  pop cx
  iret

  handle_default_page:
  ; mapping to page -1
  xor   ax, ax ; turn off bit 15
  out   RODNEY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  loop  DO_NEXT_PAGE_5000
  sti
  ; fall thru if done..


  ; exit fall thru
  xor ax, ax
  pop si
  pop bx
  pop cx
  iret