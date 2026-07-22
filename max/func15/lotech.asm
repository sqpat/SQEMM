FUNCTION_15_GET_PAGE_MAP:


  push  si
  mov   si, OFFSET _RESIDENT_VARIABLE_driver_local_page_cache
  xor   ah, ah
  lods  byte ptr cs:[si]
  stosw
  lods  byte ptr cs:[si]
  stosw
  lods  byte ptr cs:[si]
  stosw
  lods  byte ptr cs:[si]
  stosw
  sub   di, 8

  pop   si



  ret



; fall thru and run this one

FUNCTION_15_SAVE_PAGE_MAP:
public FUNCTION_15_SAVE_PAGE_MAP
  push  dx


SELFMODIFY_LOTECH_set_page_select_register_5:
  mov   dx, LOTECH_BASE_PAGE_REGISTER

  lodsw
  out   dx, al
  mov   byte ptr cs:[_RESIDENT_VARIABLE_driver_local_page_cache+0], al
  inc   dx
  lodsw
  out   dx, al
  mov   byte ptr cs:[_RESIDENT_VARIABLE_driver_local_page_cache+1], al
  inc   dx
  lodsw
  out   dx, al
  mov   byte ptr cs:[_RESIDENT_VARIABLE_driver_local_page_cache+2], al
  inc   dx
  lodsw
  out   dx, al
  mov   byte ptr cs:[_RESIDENT_VARIABLE_driver_local_page_cache+3], al
  xor   ah, ah
  sub   si, 4

  pop   dx
  ret


