
UTIL_get_page:

; return value at page index (ax) in (ax)
  push  dx
SELFMODIFY_LOTECH_set_page_select_register_1:
  mov   dx, LOTECH_BASE_PAGE_REGISTER
  add   dx, ax

  in    al, dx
  xor   ah, ah
  pop   dx
  ret



UTIL_set_page_reverse_arg:
; write page (ax) to page index (dx)
   xchg  ax, dx
UTIL_set_page:
public UTIL_set_page
; write page (dx) to page index (ax)

  xchg  ax, dx

SELFMODIFY_LOTECH_set_page_select_register_2:
  add   dx, LOTECH_BASE_PAGE_REGISTER  

  out   dx, al   ; select EMS page

SELFMODIFY_LOTECH_set_page_select_register_9:
  sub   dx, LOTECH_BASE_PAGE_REGISTER  

  xchg  ax, dx


  ret


UTIL_unmap_all_pages:

  push  dx
  push  ax
SELFMODIFY_LOTECH_set_page_select_register_3:
  mov   dx, LOTECH_BASE_PAGE_REGISTER
  mov   al, -1
  out   dx, al
  inc   dx
  out   dx, al
  inc   dx
  out   dx, al
  inc   dx
  out   dx, al
  pop   ax
  pop   dx
  ret
