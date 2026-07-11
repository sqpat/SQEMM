  push cx
  push si
  push dx


  ; physical page number mode
  cli
  func1701_loop_next_page:

  ; next page in ax....
  lodsw
  mov        dx, ax
  lodsw
  ; read two words - bx and ax
  call COMMON_util_get_register_for_segment

  ror   ax, 2
  ; 0-4 becomes 0208, 4208, 8208, c208
  add   ax, NEAT_PAGE_REGISTER_0

  xchg  dx, ax

  cmp   ax, 0FFFFh   ; -1 check
  je    func17_01_handle_default_page

  add   ax, NEAT_PAGE_OFFSET_AMT   ; turn on EMS ON bit
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
  mov   ax, NEAT_CHIPSET_UNMAP_VALUE
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