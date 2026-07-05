  push cx
  push bx
  push si


  ; physical page number mode
  cli
  func1701_loop_next_page:
  ; next page in ax....
  lodsw
  xchg  ax, bx
  lodsw
  ; read two words - bx and ax

  call util_get_register_for_segment

  cmp   al, 12  ; after 12 is conventional backfill
  ; default, lets assume backfill
  jb PAGEFRAME_REGISTER_5000

  out FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page
 
  cmp   bx, 0FFFFh   ; -1 check
  je    func_1701_handle_default_page
  ; default is not the -1 case
  lea   ax, [bx + FANTASY_PAGE_OFFSET_AMT]   ; offset by default starting page
  out   FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 


  loop       func1701_loop_next_page
  sti
  ; exits if we fall thru loop with no error
  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret


  PAGEFRAME_REGISTER_5000:

SELFMODIFY_FANTASY_add_page_frame_offset_1:  
  add   al, 4 ; need to add 4 for d000 case for FANTASY...  c000, e000  not supported
  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page
  cmp   bx, 0FFFFh   ; -1 check
  je    func_1701_handle_default_page
  lea   ax, [bx + FANTASY_PAGE_OFFSET_AMT]   ; offset by default starting page
  out   FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 

  loop       func1701_loop_next_page
  sti

  ; exits if we fall thru loop with no error
  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret

  func_1701_handle_default_page:
  ; mapping to page -1
  xchg ax, bx
  out  FANTASY_PAGE_SET_REGISTER, ax   ; write 16 bit page num. 
  loop       func1701_loop_next_page
  sti
  ; fall thru if done..

  xor        ax, ax
  pop si
  pop bx
  pop cx
  iret