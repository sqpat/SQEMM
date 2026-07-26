  push cx
  push si
  push dx


  ; physical page number mode
  cli
  func1700_loop_next_page:

  ; next page in ax....
  lodsw
  xchg  ax, dx
  lodsw
  ; read two words - bx and ax

  ror   ax, 2
  ; 0-4 becomes 0208, 4208, 8208, c208
  SELFMODIFY_NEAT_set_page_select_register_1:
  add   ax, NEAT_PAGE_REGISTER_0

  xchg  dx, ax

  inc   ax    ; -1 check
  jz    func17_00_handle_default_page
  
  SELFMODIFY_NEAT_set_page_offset_2:
  add   ax, NEAT_PAGE_OFFSET_AMT - 1   ; turn on EMS ON bit
  out   dx, al   ; write 8 bit page num. 

  loop  func1700_loop_next_page
  sti

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret

  func17_00_handle_default_page:
  ; mapping to page -1
  ; just write zero
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