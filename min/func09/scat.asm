; consider pusha/popa?
; cli/sti? not sure

  push ax  ; restore into bx 
  push dx
  push cx
  push si



  mov  si, OFFSET _RESIDENT_VARIABLE_handle_page_stack:

  mov  cx, 4
  
SELFMODIFY_SCAT_set_page_select_register_5:
  mov   dx, SCAT_PAGE_SELECT_REGISTER
SELFMODIFY_SCAT_add_page_frame_register_offset_3:
  mov   bl, SCAT_PAGE_C000_REGISTER_OFFSET 

restore_next_register:
  mov   ax, bx
  out   dx, al   ; select EMS page

  dec   dx
  dec   dx
  lods  word ptr cs:[si]
  out   dx, ax
  inc   dx
  inc   dx
  inc   bx
  loop  restore_next_register

  xchg  ax, cx  ; zero out ah for ret

  pop   si
  pop   cx
  pop   dx
  pop   bx ; restore from ax


iret