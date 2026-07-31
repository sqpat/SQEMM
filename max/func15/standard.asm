FUNCTION_15_GET_PAGE_MAP:


  push  dx
SELFMODIFY_STANDARD_set_page_select_register_6:
  mov   dx, STANDARD_BOARD_PAGE_REGISTER_0

  xor   ah, ah
  in    al, dx
  stosw
  
  mov   dh, 042h
  in    al, dx
  stosw

  mov   dh, 082h
  in    al, dx
  stosw

  mov   dh, 0C2h
  in    al, dx
  stosw

  sub   di, 8

  pop   dx



  ret



; fall thru and run this one

FUNCTION_15_SAVE_PAGE_MAP:
public FUNCTION_15_SAVE_PAGE_MAP
  push  dx


SELFMODIFY_STANDARD_set_page_select_register_5:
  mov   dx, STANDARD_BOARD_PAGE_REGISTER_0

  lodsw
  out   dx, al
  mov   dh, 042h
  lodsw
  out   dx, al
  mov   dh, 082h
  lodsw
  out   dx, al
  mov   dh, 0C2h
  lodsw
  out   dx, al
  xor   ah, ah
  sub   si, 4

  pop   dx
  ret


