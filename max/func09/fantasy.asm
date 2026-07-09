; consider pusha/popa?
; cli/sti? not sure

  push ax  ; restore into bx 
  push cx
  push si



  mov  si, OFFSET page_frame_stack
  mov  cx, 4
  
SELFMODIFY_FANTASY_add_page_frame_offset_7:
  mov   bl, 4 

restore_next_register:
  mov   ax, bx
  out   FANTASY_PAGE_SELECT_REGISTER, al   ; select EMS page

  lods  word ptr cs:[si]
  out   FANTASY_PAGE_SET_REGISTER, ax
  inc   bx
  loop  restore_next_register

  xchg  ax, cx  ; zero out ah for ret

  pop   si
  pop   cx
  pop   bx ; restore from ax


iret