
; note: bx on stack

  ; al and bx are still the args

  push ax
  push dx
  
  xchg ax, dx ; dl gets page.
  xor  dh, dh
  xchg ax, bx

  call UTIL_map_NEAT_write_page_full


  pop   dx
  pop   ax
  pop   bx
  xor   ah, ah
  iret


  
  