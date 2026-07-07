  push cx
  push bx
  push si


  ; physical page number mode
  cli
  func1700_loop_next_page:
  ; next page in ax....
  lodsw
  mov        bx, ax
  lodsw
  ; read two words - bx and ax

  cmp   ax, 12
  ; default, lets assume backfill
  jb func_17_0_pageframe_register

  out SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
 
  cmp   bx, 0FFFFh   ; -1 check
  je    handle_default_page_with_add
  ; default is not the -1 case
  mov   ax, bx
  add   ax, SCAMP_PAGE_OFFSET_AMT   ; offset by default starting page
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 


  loop       func1700_loop_next_page
  sti
  ; exits if we fall thru loop with no error
  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret


  func_17_0_pageframe_register:
  
  add   ax, 4 ; need to add 4 for d000 case for scamp...  c000, e000  not supported
  out   SCAMP_PAGE_SELECT_REGISTER, al   ; select EMS page
  cmp   bx, 0FFFFh   ; -1 check
  je    func17_00_handle_default_page
  mov   ax, bx
  add   ax, SCAMP_PAGE_OFFSET_AMT   ; offset by default starting page
  out   SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 

  loop       func1700_loop_next_page
  sti

  ; exits if we fall thru loop with no error
  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret

  handle_default_page_with_add:
  add   ax, 4
  
  func17_00_handle_default_page:
  ; mapping to page -1
  out  SCAMP_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  loop       func1700_loop_next_page
  ; fall thru if done..
  sti

  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret