  push cx
  push bx
  push si
  push dx


  ; physical page number mode
  cli
  func1701_loop_next_page:
  ; next page in ax....
  lodsw
  mov        bx, ax
  lodsw
  ; read two words - bx and ax
  call util_get_register_for_segment

  mov   dx, HT18_PAGE_SELECT_REGISTER
  
  out   dx, al   ; select EMS page
  mov   dx, HT18_PAGE_SET_REGISTER
  cmp   bx, 0FFFFh   ; -1 check
  je    func17_01_handle_default_page

  mov   ax, HT18_PAGE_OFFSET_AMT   ; offset by default starting page
  add   ax, bx
  out   dx, ax   ; write 16 bit page num. 

  loop       func1701_loop_next_page
  sti

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret

  func17_01_handle_default_page:
  ; mapping to page -1
  mov   ax, HT18_CHIPSET_UNMAP_VALUE
  out   dx, ax   ; write 16 bit page num. 
  loop       func1701_loop_next_page
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret