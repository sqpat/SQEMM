  push cx
  push si
  push dx


  ; physical page number mode
  cli
  func1701_loop_next_page:

  ; next page in ax....
  lodsw
  xchg  dx, ax

  lodsw
  ; read two words - bx and ax
  call COMMON_util_get_register_for_segment

  ror   ax, 2
  ; 0-4 becomes 0208, 4208, 8208, c208
  SELFMODIFY_NEAT_set_page_select_register_2:
  add   ax, NEAT_PAGE_REGISTER_0

  xchg  dx, ax

  inc   ax   ; -1 check
  jz    func17_01_handle_default_page

  SELFMODIFY_NEAT_set_page_offset_3:
  add   ax, NEAT_PAGE_OFFSET_AMT - 1   ; turn on EMS ON bit
  out   dx, al   ; write 8 bit page num. 

  loop       func1701_loop_next_page
  sti

  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop cx
  iret

  func17_01_handle_default_page:
  ; mapping to page -1
  ; already 0
  out   dx, al   ; write 8 bit page num. 
  loop       func1701_loop_next_page
  sti


  ; exit fall thru
  xor ax, ax
  pop dx
  pop si
  pop bx
  pop cx
  iret