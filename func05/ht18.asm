  ; note: ht18 like scat maps 0-4 not to the page frame but rather to 4000-4c00
  ; which is unfortunate. its not really backward compatible with 0-3 = page frame 3.2 style programming...
  ; for now in sqemm, call 44h (a 3.2 call) will map 0-4 to the page frame and ignore backfill register addresses.

  xor        ah, ah
_RESIDENT_VARIABLE_pageable_frame_count:
  cmp        ax, 01000h
  jnb        RETURN_RESULT_8B

  ENOUGH_PAGES:
  cmp        dx,  1
  jne        func_44_no_emm_handle_found
  
  ; al and bx are still the args

  push dx  
 
  mov   dx, HT18_PAGE_SELECT_REGISTER
  add   al, HT18_PAGE_REGISTER_OFFSET ; convert 0-4 to 1c-1f
  cli
  out   dx, al   ; select EMS page
  mov   dx, HT18_PAGE_SET_REGISTER
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_44h
  
  mov   ax, HT18_PAGE_OFFSET_AMT   ; offset by default starting page
  add   ax, bx
  out   dx, ax   ; write 16 bit page num. 
  sti
  
  pop   dx
  xor   ax, ax
  iret


  handle_default_page_44h:
  ; mapping to page -1
  mov   ax, HT18_CHIPSET_UNMAP_VALUE ; "turn off ems for this page" value
  out   dx, ax   ; write 16 bit page num. 
  sti
  
  pop   dx
  xor   ax, ax
  iret



  
  RETURN_RESULT_8B:
  mov        ah, 08Bh
  iret