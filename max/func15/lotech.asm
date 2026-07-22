FUNCTION_15_GET_PAGE_MAP:
  push  dx

SELFMODIFY_LOTECH_set_page_select_register_6:
  mov   dx, LOTECH_BASE_PAGE_REGISTER
  xor   ah, ah
  in    al, dx
  stosw
  inc   dx
  in    al, dx
  stosw
  inc   dx
  in    al, dx
  stosw
  inc   dx
  in    al, dx
  stosw



  pop   dx
  ret



; fall thru and run this one

FUNCTION_15_SAVE_PAGE_MAP:
  push  dx

SELFMODIFY_LOTECH_set_page_select_register_5:
  mov   dx, LOTECH_BASE_PAGE_REGISTER

  lodsw
  out  dx, al
  inc  dx
  lodsw
  out  dx, al
  inc  dx
  lodsw
  out  dx, al
  inc  dx
  lodsw
  out  dx, al
  xchg  ax, cx  ; zero out ah for ret

  pop   dx
  ret


