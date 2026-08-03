


; note: bx on stack

  
  ; al and bx are still the args
  push  ax   ; gross, need to store al.
  push  dx  
 
  mov  dx, WD76C10_PAGE_SELECT_REGISTER

  cbw   ; clear ah
  xchg  ax, bx
  mov   bl, byte ptr cs:[WF76C10_api_to_physical_page_lookup+bx]
  xchg  ax, bx

  out   dx, ax   ; select EMS page

  mov   dx, WD76C10_PAGE_SET_REGISTER
  inc   bx    ; -1 check
  jz    handle_default_page_44h
  
SELFMODIFY_WD76C10_add_page_offset_2_minus_1:
  lea   ax, [bx + 01000h - 1]   ; offset by default starting page. include 0x8000 bit
  

  out   dx, ax   ; write 16 bit page num. 

  
  pop   dx
  pop   ax
  pop   bx
  xor   ah, ah

  iret



  handle_default_page_44h:
  ; mapping to page -1
  cmp   al, 32
  jb    write_ax
  xchg  ax, bx  ; zero
  write_ax:
  out   dx, ax   ; write 16 bit page num. 

  
  pop   dx
  pop   ax
  pop   bx
  xor   ah, ah
  iret

