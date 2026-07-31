
UTIL_get_page:

; return value at page index (ax) in (ax)
  push  dx


  SHIFT_MACRO ror ax 2

  SELFMODIFY_STANDARD_set_page_select_register_7:
  add   ax, STANDARD_BOARD_PAGE_REGISTER_0
  xchg  ax, dx 
  in    al, dx  ; ah 0
  pop   dx
  test  al, al
  jns   return_page_unmapped ; bit 7 off = unmapped.

  and   ax, 07Fh ; turn off the mapped bit. 
  ret
  return_page_unmapped:
  mov   ax, 0FFFFh
  ret



UTIL_set_page:
public UTIL_set_page
; write page (dx) to page index (ax)

  push  dx
  SHIFT_MACRO ror ax 2

  SELFMODIFY_STANDARD_set_page_select_register_8:
  add   ax, STANDARD_BOARD_PAGE_REGISTER_0
  xchg  ax, dx

  inc   ax
  jz    do_unmap_write ; FFFF writes as zero

  add   al, STANDARD_BOARD_PAGE_ON_BIT - 1


  do_unmap_write:
  out   dx, al   ; select EMS page

  pop   dx
  ret


UTIL_unmap_all_pages:

  push  dx
  push  ax
SELFMODIFY_STANDARD_set_page_select_register_3:
  mov   dx, STANDARD_BOARD_PAGE_REGISTER_0
  xor   ax, ax ; STANDARD_BOARD_UNMAP_VALUE
  
  out   dx, al

  mov   dh, 042h
  out   dx, al

  mov   dh, 082h
  out   dx, al

  mov   dh, 0C2h
  out   dx, al

  pop   ax
  pop   dx
  ret

; sigh. so neat maps A14-A20 on bits 0-6 of the page register.
; then a21/a22 are two bits (for each of the 4 page registers) of 8 bit chipset register 0x6E


