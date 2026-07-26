FUNCTION_15_GET_PAGE_MAP:


  push  dx
SELFMODIFY_NEAT_set_page_select_register_6:
  mov   dx, NEAT_PAGE_REGISTER_0

  xor   ah, ah
  in    al, dx
  stosw
  
  add   dh, 040h
  in    al, dx
  stosw

  add   dh, 040h
  in    al, dx
  stosw

  add   dh, 040h
  in    al, dx
  stosw

  sub   di, 8

  pop   dx



  ret



; fall thru and run this one

FUNCTION_15_SAVE_PAGE_MAP:
public FUNCTION_15_SAVE_PAGE_MAP
  push  dx


SELFMODIFY_NEAT_set_page_select_register_5:
  mov   dx, NEAT_PAGE_REGISTER_0

  lodsw
  out   dx, al
  add   dh, 040h
  lodsw
  out   dx, al
  add   dh, 040h
  lodsw
  out   dx, al
  add   dh, 040h
  lodsw
  out   dx, al
  xor   ah, ah
  sub   si, 4

  pop   dx
  ret


