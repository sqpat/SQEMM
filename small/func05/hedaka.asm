
  ; page frame's pages are 208, 4208, 8208, c208. Technicaly x209 works too.

 
  
  ; al and bx are still the args

  push dx  
 
  ror ax, 2
  add ax, HEDAKA_PAGE_REGISTER_0

  ; 0-4 becomes 0208h, 4208h, 8208h, c208h
  mov dx, ax
  cli
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h

  mov ax, bx
  add    ax, HEDAKA_PAGE_OFFSET_AMT   ; turn on EMS ON bit and add conventional offset
  out   dx, al   ; write 16 bit page num. 
  sti

  pop   dx
  xor   ax, ax
  iret


  handle_default_page_44h:
  ; mapping to page -1
  mov   ax, HEDAKA_CHIPSET_UNMAP_VALUE ; "turn off ems for this page" value
  out   dx, al   ; write 16 bit page num. 
  sti
  
  pop   dx
  ;xor   ax, ax   ; already 0 above
  iret
