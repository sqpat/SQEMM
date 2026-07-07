  push cx
  push si
  push dx


  ; physical page number mode
  cli
  func1700_loop_next_page:
  ; next page in ax....
  lodsw
  mov        dx, ax
  lodsw
  ; read two words - bx and ax

  ror   ax, 2
  ; 0-4 becomes 0208, 4208, 8208, c208
  add   ax, STANDARD_BOARD_PAGE_REGISTER_0

  xchg  dx, ax

  cmp   ax, 0FFFFh   ; -1 check
  je    func17_00_handle_default_page

  add   ax, STANDARD_BOARD_PAGE_OFFSET_AMT   ; turn on EMS ON bit
  out   dx, al   ; write 8 bit page num. 

  loop       func1700_loop_next_page
  sti

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret

  func17_00_handle_default_page:
  ; mapping to page -1
  mov   ax, STANDARD_BOARD_CHIPSET_UNMAP_VALUE
  out   dx, al   ; write 8 bit page num. 
  loop       func1700_loop_next_page
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret