
; still only working in page frame version..
_RESIDENT_VARIABLE_pageable_frame_count_1:
  cmp        al, 010h
  jae        func_05_page_too_high

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        func_44_no_emm_handle_found
  
  ; al and bx are still the args

  push dx  
 
  ror  ax, 1
  ror  ax, 1
  add  ax, INTEL_AB_PAGE_REGISTER_0
  mov  dx, ax


  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h

  mov   ax, bx
  add   al, INTEL_AB_PAGE_OFFSET_AMT
  cli
  jnc   intel_ab_not_overflow_2
  add   al, 088h  ; page ON 080h + 8 to get gap pages
  intel_ab_not_overflow_2:

  out   dx, al   ; write 16 bit page num. 
  sti
  
  pop   dx
  xor   ax, ax  
  iret

  handle_default_page_44h:
  ; mapping to page -1
  mov   ax, INTEL_AB_CHIPSET_UNMAP_VALUE ; "turn off ems for this page" value
  out   dx, al   ; write 8 bit page num. 
  sti
  
  pop   dx
  xor   ax, ax  
  iret

