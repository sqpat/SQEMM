  push cx
  push bx
  push si


  ; physical page number mode
  cli
  DO_NEXT_PAGE_5000:
  ; next page in ax....
  lodsw
  mov        bx, ax
  lodsw
  ; read two words - bx and ax

  cmp   ax, 12
  ; default, lets assume backfill
  jb PAGEFRAME_REGISTER_5000

  out SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
 
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_with_add
  ; default is not the -1 case
  mov   ax, bx
  add   ax, SCAMP_PAGE_OFFSET_AMT   ; offset by default starting page
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 


  loop       DO_NEXT_PAGE_5000
  sti
  ; exits if we fall thru loop with no error
  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret


  PAGEFRAME_REGISTER_5000:
  
  add   ax, 4 ; need to add 4 for d000 case for scamp...  c000, e000  not supported
  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page
  mov   ax, bx
  add   ax, SCAMP_PAGE_OFFSET_AMT   ; offset by default starting page
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 

  loop       DO_NEXT_PAGE_5000
  sti

  ; exits if we fall thru loop with no error
  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret

  handle_default_page_with_add:
  add   ax, 4
  
  handle_default_page:
  ; mapping to page -1
  out  SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  loop       DO_NEXT_PAGE_5000
  ; fall thru if done..
  sti

  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret