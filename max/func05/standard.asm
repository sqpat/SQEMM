
; note: bx on stack



  
  ; al and bx are still the args
  push ax  ; store al
  push dx  
 
  cbw  ; zero ah
  SHIFT_MACRO ror ax 2

  SELFMODIFY_STANDARD_set_page_select_register_4:
  add ax, STANDARD_BOARD_PAGE_REGISTER_0

  ; 0-4 becomes 0208h, 4208h, 8208h, c208h
  xchg  ax, dx  ; dx gets port.
  xchg  ax, bx  ; get page


  inc   ax    ; -1 check
  jz    handle_unmap_page_44h

  add   al, STANDARD_BOARD_PAGE_ON_BIT - 1

handle_unmap_page_44h:  ; ksut write zero.

  out   dx, al   ; write 8 bit page num. 

  pop   dx
  pop   ax
  pop   bx
  xor   ah, ah
  iret


  
  