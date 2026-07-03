  push cx
  push bx
  push si
  push dx


  ; physical page number mode
  cli
  DO_NEXT_PAGE_5000:
  ; next page in ax....
  lodsw
  mov        bx, ax
  lodsw
  ; read two words - bx and ax

  mov   dx, HT18_PAGE_SELECT_REGISTER
  
  out   dx, al   ; select EMS page
  mov   dx, HT18_PAGE_SET_REGISTER
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page

  mov   ax, HT18_PAGE_OFFSET_AMT   ; offset by default starting page
  add   ax, bx
  out   dx, ax   ; write 16 bit page num. 

  loop       DO_NEXT_PAGE_5000
  sti

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret

  handle_default_page:
  ; mapping to page -1
  mov   ax, HT18_CHIPSET_UNMAP_VALUE
  out   dx, ax   ; write 16 bit page num. 
  loop       DO_NEXT_PAGE_5000
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret