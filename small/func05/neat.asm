
  ; page frame's pages are 208, 4208, 8208, c208. 


  
  ; al and bx are still the args

  push dx  
 
  ror ax, 2
  add ax, NEAT_PAGE_REGISTER_0

  ; 0-4 becomes 0208h, 4208h, 8208h, c208h
  mov dx, ax

  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h

  mov   ax, bx
  add   ax, NEAT_PAGE_OFFSET_AMT   ; turn on EMS ON bit
  out   dx, al   ; write 8 bit page num. 
  sti

  pop   dx
  xor   ax, ax
  iret

  handle_default_page_44h:
  ; mapping to page -1
  mov   ax, NEAT_CHIPSET_UNMAP_VALUE ; "turn off ems for this page" value
  out   dx, al   ; write 8 bit page num. 
  sti
  
  pop   dx
  xor   ax, ax  
  iret

