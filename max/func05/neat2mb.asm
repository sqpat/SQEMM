
; note: bx on stack



  
  ; al and bx are still the args
  push ax  ; store al
  push dx  
 
  cbw  ; zero ah
  SHIFT_MACRO ror ax 2

  SELFMODIFY_NEAT_set_page_select_register_4:
  add ax, NEAT_PAGE_REGISTER_0

  ; 0-4 becomes 0208h, 4208h, 8208h, c208h
  xchg  ax, dx  ; dx gets port.
  xchg  ax, bx  ; get page


  inc   ax    ; -1 check
  jz    handle_unmap_page_44h
handle_default_page_44h:
  ; mapping to page -1
  

  ; add back -1
SELFMODIFY_NEAT_set_page_offset_1:
  add   ax, NEAT_PAGE_OFFSET_AMT - 1   ; turn on EMS ON bit

handle_unmap_page_44h:  ; ksut write zero.
  cli 
  out   dx, al   ; write 8 bit page num. 
  sti

  pop   dx
  pop   ax
  pop   bx
  xor   ah, ah
  iret


  
  